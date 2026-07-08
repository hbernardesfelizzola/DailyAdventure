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

    /// Últimos 7 dias (do mais antigo para o mais recente), com nível de conclusão e categoria dominante.
    var last7Days: [(date: Date, level: DayCompletionLevel, dominantCategory: QuestCategory?)] {
        let cal = Calendar.current
        let today = Date()
        return (0..<7).map { daysAgo -> (Date, DayCompletionLevel, QuestCategory?) in
            let date = cal.date(byAdding: .day, value: -daysAgo, to: today)!
            let adventure: DailyAdventure?
            if cal.isDate(todayAdventure.date, inSameDayAs: date) {
                adventure = todayAdventure
            } else {
                adventure = history.first(where: { cal.isDate($0.date, inSameDayAs: date) })
            }
            let level = adventure?.completionLevel ?? .empty
            let dominant = level == .partial ? adventure.flatMap(dominantCompletedCategory) : nil
            return (date, level, dominant)
        }.reversed()
    }

    private func dominantCompletedCategory(in adventure: DailyAdventure) -> QuestCategory? {
        var counts: [QuestCategory: Int] = [:]
        for quest in adventure.sideQuests where quest.isCompleted {
            guard let cat = quest.category else { continue }
            counts[cat, default: 0] += 1
        }
        return counts.max(by: { $0.value < $1.value })?.key
    }

    /// Taxa de adição e conclusão de quests por categoria, considerando todo o histórico + hoje.
    var categoryStats: [CategoryStat] {
        var counts: [QuestCategory: (added: Int, completed: Int)] = [:]
        for cat in QuestCategory.allCases { counts[cat] = (0, 0) }

        let allDays = history + [todayAdventure]
        for day in allDays {
            for quest in day.sideQuests {
                guard let cat = quest.category else { continue }
                counts[cat]?.added += 1
                if quest.isCompleted {
                    counts[cat]?.completed += 1
                }
            }
        }

        return QuestCategory.allCases.map { cat in
            let c = counts[cat]!
            return CategoryStat(category: cat, totalAdded: c.added, totalCompleted: c.completed)
        }
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
