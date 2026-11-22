import Foundation
import Testing
@testable import DailyAdventure

@Suite struct AdventureLogTests {

    // MARK: - Helpers

    /// Calendário fixo (GMT, semana começando na segunda) para os testes não dependerem do aparelho.
    private func calendar() -> Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(secondsFromGMT: 0)!
        cal.firstWeekday = 2
        return cal
    }

    /// Sábado, 21/11/2026, 12:00 GMT.
    private var reference: Date {
        calendar().date(from: DateComponents(year: 2026, month: 11, day: 21, hour: 12))!
    }

    private func day(
        _ daysAgo: Int,
        completed: Int = 1,
        total: Int = 2,
        feedback: DayFeedback = .none
    ) -> DailyAdventure {
        let quests = (0..<total).map { Quest(title: "Q\($0)") }
        return DailyAdventure(
            date: calendar().date(byAdding: .day, value: -daysAgo, to: reference)!,
            sideQuests: quests,
            completedQuests: Array(quests.prefix(completed)),
            feedback: feedback
        )
    }

    // MARK: - Agrupamento

    @Test func groupsDaysByWeekNewestFirst() {
        // Sáb 21, Seg 16 (mesma semana); Dom 15, Seg 9 (semana anterior); Sex 6 (duas semanas antes)
        let days = [day(0), day(5), day(6), day(12), day(15)]
        let weeks = AdventureLog.weeks(from: days, calendar: calendar())

        #expect(weeks.count == 3)
        #expect(weeks.map(\.days.count) == [2, 2, 1])
        #expect(weeks[0].interval.start > weeks[1].interval.start)
    }

    @Test func daysInsideAWeekAreNewestFirst() {
        let weeks = AdventureLog.weeks(from: [day(5), day(0), day(3)], calendar: calendar())
        let dates = weeks[0].days.map(\.date)
        #expect(dates == dates.sorted(by: >))
    }

    @Test func weekCountsCompletionLevels() {
        let days = [day(0, completed: 2, total: 2), day(1, completed: 1, total: 2), day(2, completed: 0, total: 2)]
        let week = AdventureLog.weeks(from: days, calendar: calendar())[0]

        #expect(week.daysWithCompletion == 2)
        #expect(week.completeDays == 1)
    }

    @Test func stripHasSevenDaysWithLevelsOnLoggedDays() {
        let days = [day(0, completed: 2, total: 2), day(2, completed: 1, total: 2)]
        let strip = AdventureLog.weeks(from: days, calendar: calendar())[0].strip(calendar: calendar())

        #expect(strip.count == 7)
        // Semana de seg 16 a dom 22: qui 19 parcial, sáb 21 completo, demais sem registro.
        #expect(strip[3].level == .partial)
        #expect(strip[5].level == .complete)
        #expect(strip[0].level == nil)
        #expect(strip[6].level == nil)
    }

    @Test func emptyInputGivesNoWeeks() {
        #expect(AdventureLog.weeks(from: [], calendar: calendar()).isEmpty)
    }

    // MARK: - Filtros

    @Test func completeFilterKeepsOnlyFullDays() {
        let days = [day(0, completed: 2, total: 2), day(1, completed: 1, total: 2)]
        let weeks = AdventureLog.weeks(from: days, filter: .complete, calendar: calendar())
        #expect(weeks.flatMap(\.days).count == 1)
        #expect(weeks.flatMap(\.days).allSatisfy { $0.completionLevel == .complete })
    }

    @Test func feedbackFiltersMatchFeedback() {
        let days = [day(0, feedback: .positive), day(1, feedback: .negative), day(2, feedback: .neutral), day(3)]

        let great = AdventureLog.weeks(from: days, filter: .greatDays, calendar: calendar()).flatMap(\.days)
        let tough = AdventureLog.weeks(from: days, filter: .toughDays, calendar: calendar()).flatMap(\.days)

        #expect(great.map(\.feedback) == [.positive])
        #expect(tough.map(\.feedback) == [.negative])
    }

    @Test func filterDropsWeeksWithoutMatches() {
        let days = [day(0, feedback: .positive), day(12)]
        let weeks = AdventureLog.weeks(from: days, filter: .greatDays, calendar: calendar())
        #expect(weeks.count == 1)
    }
}
