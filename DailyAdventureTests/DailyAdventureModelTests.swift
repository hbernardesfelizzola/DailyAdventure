//
//  DailyAdventureModelTests.swift
//  DailyAdventureTests
//

import Foundation
import Testing
@testable import DailyAdventure

@Suite struct DailyAdventureModelTests {

    @Test func totalQuestsCountsMainQuestWhenPresent() {
        let adventure = DailyAdventure(mainQuest: "Ride the ferry")
        #expect(adventure.totalQuests == 1)
        #expect(adventure.hasAnyQuest)
    }

    @Test func totalQuestsZeroWhenNothingDefined() {
        let adventure = DailyAdventure()
        #expect(adventure.totalQuests == 0)
        #expect(adventure.completionPercentage == 0)
        #expect(!adventure.hasAnyQuest)
    }

    @Test func completionPercentageScalesWithCompletions() {
        let quests = [
            Quest(title: "Cook", category: nil),
            Quest(title: "Read", category: nil),
        ]
        let adventure = DailyAdventure(sideQuests: quests, completedQuests: [quests[0]])
        #expect(adventure.totalQuests == 2)
        #expect(adventure.completionPercentage == 0.5)
    }

    @Test @MainActor func codableRoundTripKeepsStableIdentityFields() throws {
        let adventure = DailyAdventure(
            mainQuest: "Rest",
            sideQuests: [Quest(title: "Walk")],
            completedQuests: []
        )
        let data = try JSONEncoder().encode(adventure)
        let decoded = try JSONDecoder().decode(DailyAdventure.self, from: data)
        #expect(decoded.id == adventure.id)
        #expect(decoded.mainQuest == "Rest")
        #expect(decoded.sideQuests.count == 1)
    }
}
