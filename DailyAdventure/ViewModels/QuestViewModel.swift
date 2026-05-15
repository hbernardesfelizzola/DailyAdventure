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
