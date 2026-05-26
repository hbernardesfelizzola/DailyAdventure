import Foundation

struct StreakCalculator {
    let calendar: Calendar

    /// Computes streak and excellence in a single pass.
    /// - Parameters:
    ///   - today: The current day's adventure.
    ///   - history: Past days, expected newest-first.
    ///   - referenceNow: Anchor for "today" — injectable for testing.
    func streakInfo(
        today: DailyAdventure,
        history: [DailyAdventure],
        referenceNow: Date = Date()
    ) -> (streak: Int, excellence: Int) {
        var streak = 0
        var excellence = 0
        var expectedDate = referenceNow

        for day in [today] + history {
            guard calendar.isDate(day.date, inSameDayAs: expectedDate) else { break }
            guard day.completionLevel != .empty else { break }
            streak += 1
            if day.completionLevel == .complete { excellence += 1 }
            expectedDate = calendar.date(byAdding: .day, value: -1, to: expectedDate)!
        }
        return (streak, excellence)
    }
}
