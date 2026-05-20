//
//  QuestViewModel.swift
//  DailyAdventure
//
//  Created by Henrique Bernardes on 19/04/26.
//


import SwiftUI

@Observable
@MainActor
class QuestViewModel {
    var todayAdventure: DailyAdventure
    var history: [DailyAdventure] = []
    private let storage = StorageService.shared
    private let dayBoundary = AdventureDayBoundary(calendar: .current)
    
    init() {
        self.history = storage.loadHistory()

        let now = Date()

        guard let loaded = storage.loadTodayAdventure() else {
            self.todayAdventure = DailyAdventure()
            return
        }

        if dayBoundary.isSameCalendarDayAsToday(loaded.date, referenceNow: now) {
            self.todayAdventure = loaded
            return
        }

        self.todayAdventure = DailyAdventure()

        if loaded.shouldArchiveToAdventureLog {
            history = dayBoundary.historyReplacingCalendarDay(existingHistory: history, archivedDay: loaded)
            storage.saveHistory(history)
        }

        storage.saveTodayAdventure(todayAdventure)
    }
    
    // MARK: - Reset
    func checkAndResetIfNeeded() {
        let now = Date()
        guard !dayBoundary.isSameCalendarDayAsToday(todayAdventure.date, referenceNow: now) else {
            return
        }

        let previous = todayAdventure

        if previous.shouldArchiveToAdventureLog {
            history = dayBoundary.historyReplacingCalendarDay(existingHistory: history, archivedDay: previous)
            storage.saveHistory(history)
        }

        todayAdventure = DailyAdventure()
        storage.saveTodayAdventure(todayAdventure)
    }
    
    private func save() {
        storage.saveTodayAdventure(todayAdventure)
    }
    
    func updateMainQuest(_ text: String) {
        todayAdventure.mainQuest = text
        save()
    }
    
    // MARK: - Side Quests
    func addSideQuest(category: QuestCategory, title: String) {
        if !title.isEmpty {
            let newQuest = Quest(title: title, category: category)
            todayAdventure.sideQuests.append(newQuest)
            save()
        }
    }
    
    func deleteSideQuest(_ quest: Quest) {
        todayAdventure.sideQuests.removeAll { $0.id == quest.id }
        todayAdventure.completedQuests.removeAll { $0.id == quest.id }
        save()
    }
    
    func getSideQuests(for category: QuestCategory) -> [Quest] {
        todayAdventure.sideQuests.filter { $0.category == category }
    }
    
    // MARK: - Completed Quests
    func completeMainQuest() {
        if !todayAdventure.mainQuest.isEmpty {
            if !todayAdventure.completedQuests.contains(where: { $0.isMainQuest }) {
                let mainQuestObj = Quest(title: todayAdventure.mainQuest, category: nil, isMainQuest: true)
                todayAdventure.completedQuests.append(mainQuestObj)
                save()
            }
        }
    }
    
    func toggleMainQuest() {
        if isMainQuestCompleted() {
            todayAdventure.completedQuests.removeAll { $0.isMainQuest }
        } else {
            completeMainQuest()
        }
        save()
    }
    
    func completeSideQuest(_ quest: Quest) {
        if todayAdventure.completedQuests.contains(where: { $0.id == quest.id }) {
            todayAdventure.completedQuests.removeAll { $0.id == quest.id }
        } else {
            todayAdventure.completedQuests.append(quest)
        }
        save()
    }
    
    func uncompleteQuest(_ quest: Quest) {
        todayAdventure.completedQuests.removeAll { $0.id == quest.id }
        save()
    }
    
    func isQuestCompleted(_ quest: Quest) -> Bool {
        todayAdventure.completedQuests.contains { $0.id == quest.id }
    }
    
    func isMainQuestCompleted() -> Bool {
        todayAdventure.completedQuests.contains { $0.isMainQuest }
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
        for quest in adventure.completedQuests {
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
                if day.completedQuests.contains(where: { $0.id == quest.id }) {
                    counts[cat]?.completed += 1
                }
            }
        }

        return QuestCategory.allCases.map { cat in
            let c = counts[cat]!
            return CategoryStat(category: cat, totalAdded: c.added, totalCompleted: c.completed)
        }
    }

    // Calcula streak e excelência em uma única passagem para evitar duplicação.
    private var streakInfo: (streak: Int, excellence: Int) {
        let cal = Calendar.current
        var streak = 0
        var excellence = 0
        var expectedDate = Date()

        // Considera hoje + histórico (já ordenado do mais recente)
        let allDays = [todayAdventure] + history

        for day in allDays {
            guard cal.isDate(day.date, inSameDayAs: expectedDate) else { break }
            guard day.completionLevel != .empty else { break }
            streak += 1
            if day.completionLevel == .complete { excellence += 1 }
            expectedDate = cal.date(byAdding: .day, value: -1, to: expectedDate)!
        }
        return (streak, excellence)
    }

    func updateFeedback(_ feedback: DayFeedback, for adventure: DailyAdventure) {
        if adventure.isToday {
            todayAdventure.feedback = feedback
            save()
        } else {
            if let index = history.firstIndex(where: { $0.id == adventure.id }) {
                history[index].feedback = feedback
                storage.saveHistory(history)
            }
        }
    }
}
