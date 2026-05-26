import Foundation
import Testing
@testable import DailyAdventure

@Suite struct DayCompletionLevelTests {

    @Test func completionLevelEmptyWhenNoQuestsDefined() {
        #expect(DailyAdventure().completionLevel == .empty)
    }

    @Test func completionLevelEmptyWhenQuestsDefinedButNoneCompleted() {
        let q = Quest(title: "Run a mile")
        let adventure = DailyAdventure(sideQuests: [q], completedQuests: [])
        #expect(adventure.completionLevel == .empty)
    }

    @Test func completionLevelPartialWhenSomeCompleted() {
        let q1 = Quest(title: "Run")
        let q2 = Quest(title: "Read")
        let adventure = DailyAdventure(sideQuests: [q1, q2], completedQuests: [q1])
        #expect(adventure.completionLevel == .partial)
    }

    @Test func completionLevelCompleteWhenAllSideQuestsCompleted() {
        let q1 = Quest(title: "Run")
        let q2 = Quest(title: "Read")
        let adventure = DailyAdventure(sideQuests: [q1, q2], completedQuests: [q1, q2])
        #expect(adventure.completionLevel == .complete)
    }

    @Test func completionLevelCompleteWhenOnlyMainQuestAndItIsDone() {
        // Main quest contributes 1 to totalQuests; the completed wrapper triggers .complete
        let completedMain = Quest(title: "Conquer the summit", isMainQuest: true)
        let adventure = DailyAdventure(mainQuest: "Conquer the summit", completedQuests: [completedMain])
        #expect(adventure.totalQuests == 1)
        #expect(adventure.completionLevel == .complete)
    }

    @Test func completionLevelPartialWhenMainDoneButSideQuestsPending() {
        let side = Quest(title: "Read")
        let completedMain = Quest(title: "Run", isMainQuest: true)
        let adventure = DailyAdventure(mainQuest: "Run", sideQuests: [side], completedQuests: [completedMain])
        #expect(adventure.completionLevel == .partial)
    }

    // MARK: - DayFeedback.neutral

    @Test func feedbackNeutralQualifiesForAdventureLogArchive() {
        var adventure = DailyAdventure()
        adventure.feedback = .neutral
        #expect(adventure.shouldArchiveToAdventureLog)
    }

    @Test func feedbackNegativeQualifiesForAdventureLogArchive() {
        var adventure = DailyAdventure()
        adventure.feedback = .negative
        #expect(adventure.shouldArchiveToAdventureLog)
    }

    @Test func feedbackNoneAloneDoesNotQualifyForArchive() {
        let adventure = DailyAdventure()
        #expect(!adventure.shouldArchiveToAdventureLog)
    }
}
