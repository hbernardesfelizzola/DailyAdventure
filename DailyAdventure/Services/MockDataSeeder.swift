import Foundation

/// Populates UserDefaults with 30 days of realistic fake history.
/// Triggered by the `--mock-data` launch argument (development only).
@MainActor
struct MockDataSeeder {

    static func seed() {
        let calendar = Calendar.current
        let now = Date()

        var history: [DailyAdventure] = []
        for daysAgo in 1...30 {
            guard let date = calendar.date(byAdding: .day, value: -daysAgo, to: now) else { continue }
            let adventure = makeAdventure(date: date, index: daysAgo)
            if adventure.shouldArchiveToAdventureLog {
                history.append(adventure)
            }
        }

        let today = makeTodayAdventure(date: now)

        let defaults = UserDefaults(suiteName: StorageService.appGroupID) ?? .standard
        if let historyData = try? JSONEncoder().encode(history) {
            defaults.set(historyData, forKey: "adventureHistory")
        }
        if let todayData = try? JSONEncoder().encode(today) {
            defaults.set(todayData, forKey: "todayAdventure")
        }
        defaults.set(true, forKey: "hasSeenOnboarding")
    }

    // MARK: - Day builders

    private static func makeTodayAdventure(date: Date) -> DailyAdventure {
        let workQuest = Quest(title: "Finish sprint retrospective", category: .work)
        let healthQuest = Quest(title: "Evening walk", category: .health)
        return DailyAdventure(
            id: UUID(),
            date: date,
            mainQuest: "Explore the Digital Realm",
            sideQuests: [workQuest, healthQuest],
            completedQuests: []
        )
    }

    private static func makeAdventure(date: Date, index: Int) -> DailyAdventure {
        if index == 15 {
            // Intentional gap — breaks the streak to show realistic history
            return DailyAdventure(id: UUID(), date: date)
        }
        if index % 8 == 0 && index > 14 {
            return DailyAdventure(id: UUID(), date: date)
        }
        return makeActiveDay(date: date, index: index)
    }

    private static func makeActiveDay(date: Date, index: Int) -> DailyAdventure {
        let workQuest = Quest(title: workTitles[index % workTitles.count], category: .work)
        let healthQuest = Quest(title: healthTitles[index % healthTitles.count], category: .health)
        let relQuest = Quest(title: relTitles[index % relTitles.count], category: .relationship)
        let mainTitle = mainTitles[index % mainTitles.count]

        let completedMain = Quest(title: mainTitle, category: nil, isMainQuest: true)

        let feedbacks: [DayFeedback] = [.positive, .positive, .neutral, .positive, .negative, .positive, .neutral]
        let feedback = feedbacks[index % feedbacks.count]

        // Every 5th active day is partial; the rest are complete
        let completedQuests: [Quest] = index % 5 == 3
            ? [completedMain, workQuest]
            : [completedMain, workQuest, healthQuest, relQuest]

        return DailyAdventure(
            id: UUID(),
            date: date,
            mainQuest: mainTitle,
            sideQuests: [workQuest, healthQuest, relQuest],
            completedQuests: completedQuests,
            feedback: feedback
        )
    }

    // MARK: - Content pools

    private static let mainTitles = [
        "Conquer the mountain",
        "Chart the unexplored path",
        "Forge new alliances",
        "Master the craft",
        "Overcome the challenge",
        "Seize the moment",
        "Build something meaningful",
    ]

    private static let workTitles = [
        "Ship the feature",
        "Review pull requests",
        "Lead the standup",
        "Update documentation",
        "Fix the critical bug",
        "Plan next sprint",
        "Pair program with teammate",
    ]

    private static let healthTitles = [
        "30-min run",
        "Morning stretch",
        "Drink 2L of water",
        "Meditate for 10 min",
        "Evening walk",
        "Go to the gym",
        "Sleep before midnight",
    ]

    private static let relTitles = [
        "Call a friend",
        "Family dinner",
        "Send a kind message",
        "Coffee with colleague",
        "Check in on a loved one",
        "Write a letter",
        "Make time for someone",
    ]
}
