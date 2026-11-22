//
//  QuestViewModel.swift
//  DailyAdventure
//
//  Created by Henrique Bernardes on 19/04/26.
//


import SwiftUI
import SwiftData
import WidgetKit

@Observable
@MainActor
class QuestViewModel {
    var todayAdventure: DailyAdventure
    var history: [DailyAdventure] = []
    private let context: ModelContext
    private let streakCalculator = StreakCalculator(calendar: .current)

    init(context: ModelContext) {
        self.context = context
        LegacyDataMigrator.migrateIfNeeded(context: context)

        let now = Date()
        let todayStart = Calendar.current.startOfDay(for: now)

        if let existing = Self.fetchAdventure(calendarDay: todayStart, context: context) {
            self.todayAdventure = existing
        } else {
            if let stale = Self.fetchMostRecent(context: context), !stale.shouldArchiveToAdventureLog {
                context.delete(stale)
            }
            let fresh = DailyAdventure(date: now)
            context.insert(fresh)
            try? context.save()
            self.todayAdventure = fresh
        }

        self.history = Self.fetchHistory(context: context, excludingCalendarDay: self.todayAdventure.calendarDay)
    }

    // MARK: - Reset
    func checkAndResetIfNeeded() {
        let now = Date()
        let todayStart = Calendar.current.startOfDay(for: now)

        // Recarrega do armazenamento para pegar mudanças feitas pelo widget (hoje é um no-op, já que não há
        // App Intent de escrita no widget, mas mantido por paridade com o comportamento anterior).
        if let fresh = Self.fetchAdventure(calendarDay: todayStart, context: context) {
            todayAdventure = fresh
            return
        }

        if !todayAdventure.shouldArchiveToAdventureLog {
            context.delete(todayAdventure)
        }

        let fresh = DailyAdventure(date: now)
        context.insert(fresh)
        try? context.save()
        todayAdventure = fresh
        history = Self.fetchHistory(context: context, excludingCalendarDay: fresh.calendarDay)
    }

    private func save() {
        try? context.save()
        WidgetCenter.shared.reloadAllTimelines()
    }

    func updateMainQuest(_ text: String) {
        todayAdventure.mainQuest = text
        save()
    }

    // MARK: - Side Quests
    func addSideQuest(category: QuestCategory, title: String) {
        if !title.isEmpty {
            let newQuest = Quest(title: title, category: category)
            context.insert(newQuest)
            todayAdventure.quests?.append(newQuest)
            save()
        }
    }

    func deleteSideQuest(_ quest: Quest) {
        todayAdventure.quests?.removeAll { $0.id == quest.id }
        context.delete(quest)
        save()
    }

    func getSideQuests(for category: QuestCategory) -> [Quest] {
        todayAdventure.sideQuests.filter { $0.category == category }
    }

    // MARK: - Completed Quests
    func completeMainQuest() {
        guard !todayAdventure.mainQuest.isEmpty, !todayAdventure.isMainQuestCompleted else { return }
        todayAdventure.isMainQuestCompleted = true
        todayAdventure.mainQuestCompletedAt = Date()
        save()
    }

    func toggleMainQuest() {
        if todayAdventure.isMainQuestCompleted {
            todayAdventure.isMainQuestCompleted = false
            todayAdventure.mainQuestCompletedAt = nil
            save()
        } else {
            completeMainQuest()
        }
    }

    func completeSideQuest(_ quest: Quest) {
        quest.isCompleted.toggle()
        quest.completedAt = quest.isCompleted ? Date() : nil
        save()
    }

    func uncompleteQuest(_ quest: Quest) {
        quest.isCompleted = false
        quest.completedAt = nil
        save()
    }

    func isQuestCompleted(_ quest: Quest) -> Bool {
        quest.isCompleted
    }

    func isMainQuestCompleted() -> Bool {
        todayAdventure.isMainQuestCompleted
    }

    // MARK: - Analytics

    /// Dias consecutivos com ≥1 quest completada, contando de hoje para trás.
    var currentStreak: Int {
        streakInfo.streak
    }

    /// Quantos dias dentro da sequência atual tiveram 100% de conclusão.
    var excellenceInStreak: Int {
        streakInfo.excellence
    }

    /// Total de dias no histórico com ≥1 quest completada.
    var totalDaysAdventured: Int {
        let historyCount = history.filter { $0.completionLevel != .empty }.count
        let todayCount = todayAdventure.completionLevel != .empty ? 1 : 0
        return historyCount + todayCount
    }

    /// Todos os dias registrados: hoje (se tiver algo) + histórico, sem duplicar o dia atual.
    private var allLoggedDays: [DailyAdventure] {
        let cal = Calendar.current
        let past = history.filter { !cal.isDate($0.date, inSameDayAs: todayAdventure.date) }
        return todayAdventure.hasAnyQuest ? [todayAdventure] + past : past
    }

    /// Total de quests concluídas (aventura do dia + secundárias) em todos os dias.
    var totalQuestsCompleted: Int {
        allLoggedDays.reduce(0) { $0 + $1.completedQuests.count }
    }

    /// Fração dos dias com aventura do dia definida em que ela foi concluída. `nil` se nunca houve uma.
    var dailyAdventureCompletionRate: Double? {
        let withMainQuest = allLoggedDays.filter { !$0.mainQuest.isEmpty }
        guard !withMainQuest.isEmpty else { return nil }
        return Double(withMainQuest.filter(\.isMainQuestCompleted).count) / Double(withMainQuest.count)
    }

    /// Nível de conclusão de um dia qualquer (`nil` = nada registrado nesse dia).
    func completionLevel(on date: Date) -> DayCompletionLevel? {
        let cal = Calendar.current
        return allLoggedDays.first { cal.isDate($0.date, inSameDayAs: date) }?.completionLevel
    }

    /// Data do dia registrado mais antigo, para limitar a navegação do calendário.
    var firstLoggedDate: Date? {
        allLoggedDays.map(\.date).min()
    }

    private var streakInfo: (streak: Int, excellence: Int) {
        streakCalculator.streakInfo(today: todayAdventure, history: history)
    }

    func updateFeedback(_ feedback: DayFeedback, for adventure: DailyAdventure) {
        if adventure.isToday {
            todayAdventure.feedback = feedback
            save()
        } else {
            adventure.feedback = feedback
            try? context.save()
        }
    }

    // MARK: - Fetch helpers

    private static func fetchAdventure(calendarDay: Date, context: ModelContext) -> DailyAdventure? {
        let descriptor = FetchDescriptor<DailyAdventure>(
            predicate: #Predicate { $0.calendarDay == calendarDay }
        )
        return try? context.fetch(descriptor).first
    }

    private static func fetchMostRecent(context: ModelContext) -> DailyAdventure? {
        var descriptor = FetchDescriptor<DailyAdventure>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        descriptor.fetchLimit = 1
        return try? context.fetch(descriptor).first
    }

    private static func fetchHistory(context: ModelContext, excludingCalendarDay: Date) -> [DailyAdventure] {
        let descriptor = FetchDescriptor<DailyAdventure>(
            predicate: #Predicate { $0.calendarDay != excludingCalendarDay },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }
}

extension QuestViewModel {
    /// Factory for SwiftUI `#Preview` blocks — backed by an in-memory store, never used in production.
    static var preview: QuestViewModel {
        let container = try! ModelContainer(
            for: DailyAdventure.self, Quest.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        return QuestViewModel(context: ModelContext(container))
    }
}
