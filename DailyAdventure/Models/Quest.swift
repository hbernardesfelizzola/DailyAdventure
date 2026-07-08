//
//  Quest.swift
//  DailyAdventure
//
//  Created by Henrique Bernardes on 19/04/26.
//


import Foundation
import SwiftData

@Model
final class Quest {
    var id: UUID = UUID()
    var title: String = ""
    var category: QuestCategory?  // Opcional para main quest
    var isMainQuest: Bool = false
    var isCompleted: Bool = false
    var completedAt: Date?
    var createdAt: Date = Date()

    var day: DailyAdventure?

    init(id: UUID = UUID(), title: String, category: QuestCategory? = nil, isMainQuest: Bool = false) {
        self.id = id
        self.title = title
        self.category = category
        self.isMainQuest = isMainQuest
    }
}
