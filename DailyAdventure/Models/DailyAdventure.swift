//
//  DailyAdventure.swift
//  DailyAdventure
//
//  Created by Henrique Bernardes on 19/04/26.
//

import Foundation

enum DayFeedback: String, Codable {
    case positive = "positive"
    case negative = "negative"
    case none = "none"
}

struct DailyAdventure: Identifiable, Codable {
    let id: UUID
    var date: Date
    var mainQuest: String
    var sideQuests: [Quest]
    var completedQuests: [Quest]
    var drawingType: DrawingType
    var feedback: DayFeedback
    
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        mainQuest: String = "",
        sideQuests: [Quest] = [],
        completedQuests: [Quest] = [],
        drawingType: DrawingType = .random(),
        feedback: DayFeedback = .none
    ) {
        self.id = id
        self.date = date
        self.mainQuest = mainQuest
        self.sideQuests = sideQuests
        self.completedQuests = completedQuests
        self.drawingType = drawingType
        self.feedback = feedback
    }
    
    var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
    
    var totalQuests: Int {
        let mainCount = mainQuest.isEmpty ? 0 : 1
        return mainCount + sideQuests.count
    }
    
    var completionPercentage: Double {
        guard totalQuests > 0 else { return 0 }
        return Double(completedQuests.count) / Double(totalQuests)
    }
    
    var hasAnyQuest: Bool {
        !mainQuest.isEmpty || !sideQuests.isEmpty
    }
}
