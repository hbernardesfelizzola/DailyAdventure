//
//  DailyAdventureModelTests.swift
//  DailyAdventureTests
//

import Foundation
import SwiftData
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

    @Test @MainActor func identitySurvivesPersistenceRoundTrip() throws {
        let container = try ModelContainer(
            for: DailyAdventure.self, Quest.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = ModelContext(container)

        let adventure = DailyAdventure(
            mainQuest: "Rest",
            sideQuests: [Quest(title: "Walk")],
            completedQuests: []
        )
        let id = adventure.id
        context.insert(adventure)
        try context.save()

        let descriptor = FetchDescriptor<DailyAdventure>(predicate: #Predicate { $0.id == id })
        let fetched = try context.fetch(descriptor)
        #expect(fetched.count == 1)
        #expect(fetched.first?.mainQuest == "Rest")
        #expect(fetched.first?.sideQuests.count == 1)
    }
}
