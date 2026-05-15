//
//  AdventureDayBoundaryTests.swift
//  DailyAdventureTests
//

import Foundation
import Testing
@testable import DailyAdventure

@Suite struct AdventureDayBoundaryTests {

    private func gmtCalendar() -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }

    private func fixedDate(year: Int, month: Int, day: Int, hour: Int, calendar: Calendar) -> Date {
        var comps = DateComponents()
        comps.year = year
        comps.month = month
        comps.day = day
        comps.hour = hour
        return calendar.date(from: comps)!
    }

    @Test func sameCalendarDayTrueForDifferentClockTimesOnSameGMTDay() {
        let calendar = gmtCalendar()
        let boundary = AdventureDayBoundary(calendar: calendar)
        let dawn = fixedDate(year: 2026, month: 5, day: 10, hour: 1, calendar: calendar)
        let dusk = fixedDate(year: 2026, month: 5, day: 10, hour: 23, calendar: calendar)

        #expect(boundary.isSameCalendarDayAsToday(dawn, referenceNow: dusk))
    }

    @Test func notSameCalendarDayAcrossMidnightGMT() {
        let calendar = gmtCalendar()
        let boundary = AdventureDayBoundary(calendar: calendar)
        let evening = fixedDate(year: 2026, month: 5, day: 10, hour: 23, calendar: calendar)
        let nextMorning = fixedDate(year: 2026, month: 5, day: 11, hour: 1, calendar: calendar)

        #expect(!boundary.isSameCalendarDayAsToday(evening, referenceNow: nextMorning))
    }

    @Test func historyReplaceRemovesOlderEntryOnMatchingCalendarDay() {
        let calendar = gmtCalendar()
        let boundary = AdventureDayBoundary(calendar: calendar)

        let may1Morning = fixedDate(year: 2026, month: 5, day: 1, hour: 9, calendar: calendar)
        let may1Evening = fixedDate(year: 2026, month: 5, day: 1, hour: 21, calendar: calendar)

        let stale = DailyAdventure(id: UUID(), date: may1Morning, mainQuest: "Stale")
        let canonical = DailyAdventure(id: UUID(), date: may1Evening, mainQuest: "Canonical")

        let merged = boundary.historyReplacingCalendarDay(existingHistory: [stale], archivedDay: canonical)
        #expect(merged.count == 1)
        #expect(merged[0].mainQuest == "Canonical")
    }

    @Test func emptyAdventureDoesNotQualifyForLogArchiveFlag() {
        #expect(!DailyAdventure().shouldArchiveToAdventureLog)
    }

    @Test func archivesWhenThereIsMainQuestFeedbackOrCompletion() {
        let withMain = DailyAdventure(mainQuest: "Run")
        #expect(withMain.shouldArchiveToAdventureLog)

        var withCompletion = DailyAdventure()
        withCompletion.completedQuests.append(Quest(title: "Hydrate"))
        #expect(withCompletion.shouldArchiveToAdventureLog)

        var withFeedback = DailyAdventure()
        withFeedback.feedback = .positive
        #expect(withFeedback.shouldArchiveToAdventureLog)
    }
}
