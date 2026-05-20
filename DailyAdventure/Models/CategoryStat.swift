//
//  CategoryStat.swift
//  DailyAdventure
//

import Foundation

struct CategoryStat {
    let category: QuestCategory
    let totalAdded: Int
    let totalCompleted: Int

    var completionRate: Double {
        guard totalAdded > 0 else { return 0 }
        return Double(totalCompleted) / Double(totalAdded)
    }

    var hasData: Bool { totalAdded > 0 }
}
