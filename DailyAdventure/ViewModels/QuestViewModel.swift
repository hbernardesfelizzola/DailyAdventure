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
    
    init() {
        self.history = storage.loadHistory()
        
        let loaded = storage.loadTodayAdventure()
        
        if let saved = loaded, saved.isToday {
            self.todayAdventure = saved
        } else {
            self.todayAdventure = DailyAdventure()
            
            if let saved = loaded {
                self.history.insert(saved, at: 0)
                storage.saveHistory(self.history)
            }
        }
    }
    
    // MARK: - Reset
    func checkAndResetIfNeeded() {
        if !todayAdventure.isToday {
            history.insert(todayAdventure, at: 0)
            storage.saveHistory(history)
            todayAdventure = DailyAdventure()
            storage.saveTodayAdventure(todayAdventure)
        }
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
    
    func updateSideQuest(_ quest: Quest, newTitle: String) {
        if let index = todayAdventure.sideQuests.firstIndex(where: { $0.id == quest.id }) {
            todayAdventure.sideQuests[index].title = newTitle
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
}
