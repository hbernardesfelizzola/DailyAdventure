import Foundation
import Testing
@testable import DailyAdventure

@Suite struct StreakCalculatorTests {

    // MARK: - Helpers

    private func gmtCalendar() -> Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(secondsFromGMT: 0)!
        return cal
    }

    private func date(daysAgo: Int, from referenceNow: Date, calendar: Calendar) -> Date {
        calendar.date(byAdding: .day, value: -daysAgo, to: referenceNow)!
    }

    private func emptyDay(daysAgo: Int, referenceNow: Date, calendar: Calendar) -> DailyAdventure {
        DailyAdventure(date: date(daysAgo: daysAgo, from: referenceNow, calendar: calendar))
    }

    private func partialDay(daysAgo: Int, referenceNow: Date, calendar: Calendar) -> DailyAdventure {
        let done = Quest(title: "Task A")
        let pending = Quest(title: "Task B")
        return DailyAdventure(
            date: date(daysAgo: daysAgo, from: referenceNow, calendar: calendar),
            sideQuests: [done, pending],
            completedQuests: [done]
        )
    }

    private func completeDay(daysAgo: Int, referenceNow: Date, calendar: Calendar) -> DailyAdventure {
        let q1 = Quest(title: "Task A")
        let q2 = Quest(title: "Task B")
        return DailyAdventure(
            date: date(daysAgo: daysAgo, from: referenceNow, calendar: calendar),
            sideQuests: [q1, q2],
            completedQuests: [q1, q2]
        )
    }

    // MARK: - Tests

    @Test func streakZeroWhenTodayIsEmpty() {
        let cal = gmtCalendar()
        let now = Date()
        let calc = StreakCalculator(calendar: cal)
        let today = emptyDay(daysAgo: 0, referenceNow: now, calendar: cal)

        let (streak, excellence) = calc.streakInfo(today: today, history: [], referenceNow: now)

        #expect(streak == 0)
        #expect(excellence == 0)
    }

    @Test func streakOneWhenOnlyTodayHasCompletion() {
        let cal = gmtCalendar()
        let now = Date()
        let calc = StreakCalculator(calendar: cal)
        let today = partialDay(daysAgo: 0, referenceNow: now, calendar: cal)

        let (streak, excellence) = calc.streakInfo(today: today, history: [], referenceNow: now)

        #expect(streak == 1)
        #expect(excellence == 0) // partial doesn't count as excellence
    }

    @Test func streakCountsConsecutiveHistoryDays() {
        let cal = gmtCalendar()
        let now = Date()
        let calc = StreakCalculator(calendar: cal)
        let today = partialDay(daysAgo: 0, referenceNow: now, calendar: cal)
        let yesterday = completeDay(daysAgo: 1, referenceNow: now, calendar: cal)
        let twoDaysAgo = completeDay(daysAgo: 2, referenceNow: now, calendar: cal)

        let (streak, excellence) = calc.streakInfo(
            today: today,
            history: [yesterday, twoDaysAgo],
            referenceNow: now
        )

        #expect(streak == 3)
        #expect(excellence == 2) // yesterday + twoDaysAgo are complete; today is partial
    }

    @Test func streakBreaksAtGapInHistory() {
        let cal = gmtCalendar()
        let now = Date()
        let calc = StreakCalculator(calendar: cal)
        let today = completeDay(daysAgo: 0, referenceNow: now, calendar: cal)
        let yesterday = completeDay(daysAgo: 1, referenceNow: now, calendar: cal)
        // daysAgo 2 is missing (gap)
        let threeDaysAgo = completeDay(daysAgo: 3, referenceNow: now, calendar: cal)

        let (streak, _) = calc.streakInfo(
            today: today,
            history: [yesterday, threeDaysAgo],
            referenceNow: now
        )

        #expect(streak == 2) // breaks at the missing day 2
    }

    @Test func streakZeroWhenTodayEmptyEvenWithConsecutiveHistory() {
        let cal = gmtCalendar()
        let now = Date()
        let calc = StreakCalculator(calendar: cal)
        let today = emptyDay(daysAgo: 0, referenceNow: now, calendar: cal)
        let yesterday = completeDay(daysAgo: 1, referenceNow: now, calendar: cal)
        let twoDaysAgo = completeDay(daysAgo: 2, referenceNow: now, calendar: cal)

        let (streak, _) = calc.streakInfo(
            today: today,
            history: [yesterday, twoDaysAgo],
            referenceNow: now
        )

        #expect(streak == 0)
    }

    @Test func excellenceCountsOnlyCompleteDays() {
        let cal = gmtCalendar()
        let now = Date()
        let calc = StreakCalculator(calendar: cal)
        let today = completeDay(daysAgo: 0, referenceNow: now, calendar: cal)
        let yesterday = partialDay(daysAgo: 1, referenceNow: now, calendar: cal)
        let twoDaysAgo = completeDay(daysAgo: 2, referenceNow: now, calendar: cal)

        let (streak, excellence) = calc.streakInfo(
            today: today,
            history: [yesterday, twoDaysAgo],
            referenceNow: now
        )

        #expect(streak == 3)
        #expect(excellence == 2) // today + twoDaysAgo; yesterday is partial
    }

    @Test func streakBreaksAtEmptyDayInsideHistory() {
        let cal = gmtCalendar()
        let now = Date()
        let calc = StreakCalculator(calendar: cal)
        let today = completeDay(daysAgo: 0, referenceNow: now, calendar: cal)
        let yesterday = emptyDay(daysAgo: 1, referenceNow: now, calendar: cal) // present but empty
        let twoDaysAgo = completeDay(daysAgo: 2, referenceNow: now, calendar: cal)

        let (streak, _) = calc.streakInfo(
            today: today,
            history: [yesterday, twoDaysAgo],
            referenceNow: now
        )

        #expect(streak == 1) // breaks at yesterday (empty day present in history)
    }
}
