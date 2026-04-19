//
//  Quest.swift
//  DailyAdventure
//
//  Created by Henrique Bernardes on 19/04/26.
//


import Foundation

struct Quest: Identifiable, Codable {
    let id: UUID
    var title: String
    var category: QuestCategory?  // Opcional para main quest
    var createdAt: Date
    var isMainQuest: Bool = false
    
    init(id: UUID = UUID(), title: String, category: QuestCategory? = nil, createdAt: Date = Date(), isMainQuest: Bool = false) {
        self.id = id
        self.title = title
        self.category = category
        self.createdAt = createdAt
        self.isMainQuest = isMainQuest
    }
}