//
//  AdventureDayBoundary.swift
//  DailyAdventure
//

import Foundation

/// Calendar-day semantics for rollover and history consistency (timezone-aware via `calendar`).
struct AdventureDayBoundary {
    let calendar: Calendar

    init(calendar: Calendar) {
        self.calendar = calendar
    }

    /// Whether `adventureDate` falls on the same calendar day as `referenceNow`.
    func isSameCalendarDayAsToday(_ adventureDate: Date, referenceNow: Date) -> Bool {
        calendar.isDate(adventureDate, inSameDayAs: referenceNow)
    }

    /// Puts `archivedDay` at the front (newest first) and removes any other entries from the **same calendar day**.
    func historyReplacingCalendarDay(existingHistory: [DailyAdventure], archivedDay: DailyAdventure)
        -> [DailyAdventure] {
        let others = existingHistory.filter { existing in
            !calendar.isDate(existing.date, inSameDayAs: archivedDay.date)
        }
        return [archivedDay] + others
    }
}

extension DailyAdventure {
    /// When the persisted “today” slot is stale, archive it only if the user recorded something meaningful.
    var shouldArchiveToAdventureLog: Bool {
        hasAnyQuest || !completedQuests.isEmpty || feedback != .none
    }
}
