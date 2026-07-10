//
//  WidgetEntry.swift
//  DailyAdventureWidget
//

import WidgetKit
import SwiftUI
import SwiftData

// MARK: - Timeline Entry

struct DailyAdventureEntry: TimelineEntry {
    let date: Date
    let adventure: DailyAdventure

    var isMainQuestCompleted: Bool {
        adventure.completedQuests.contains { $0.isMainQuest }
    }
    var completedCount: Int { adventure.completedQuests.count }
    var totalCount: Int { adventure.totalQuests }

    /// Próxima quest incompleta para o widget de lembrete (small).
    /// Prioriza side quests (têm categoria) sobre a main quest.
    var reminderQuest: (title: String, category: QuestCategory?)? {
        let incompleteSide = adventure.sideQuests.filter { quest in
            !adventure.completedQuests.contains { $0.id == quest.id }
        }
        if let first = incompleteSide.first {
            return (first.title, first.category)
        }
        if !adventure.mainQuest.isEmpty,
           !adventure.completedQuests.contains(where: { $0.isMainQuest }) {
            return (adventure.mainQuest, nil)
        }
        return nil
    }

    static var placeholder: DailyAdventureEntry {
        let q1 = Quest(title: "Weekly team report", category: .work)
        let q2 = Quest(title: "Evening jog", category: .health)
        let q3 = Quest(title: "Call mom", category: .relationship)
        let adventure = DailyAdventure(
            mainQuest: "Finish the WidgetKit presentation",
            sideQuests: [q1, q2, q3],
            completedQuests: [q1]
        )
        return DailyAdventureEntry(date: Date(), adventure: adventure)
    }
}

// MARK: - Shared Timeline Provider

struct DailyAdventureProvider: TimelineProvider {
    func placeholder(in context: Context) -> DailyAdventureEntry { .placeholder }

    func getSnapshot(in context: Context, completion: @escaping (DailyAdventureEntry) -> Void) {
        completion(context.isPreview ? .placeholder : loadEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<DailyAdventureEntry>) -> Void) {
        let entry = loadEntry()
        let midnight = Calendar.current.startOfDay(
            for: Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        )
        completion(Timeline(entries: [entry], policy: .after(midnight)))
    }

    private func loadEntry() -> DailyAdventureEntry {
        let context = ModelContext(PersistenceController.shared)
        let todayStart = Calendar.current.startOfDay(for: Date())

        let todayDescriptor = FetchDescriptor<DailyAdventure>(
            predicate: #Predicate { $0.calendarDay == todayStart }
        )
        let adventure = (try? context.fetch(todayDescriptor))?.first ?? DailyAdventure()

        return DailyAdventureEntry(date: Date(), adventure: adventure)
    }
}

// MARK: - DayCompletionLevel widget helpers

extension DayCompletionLevel {
    var widgetIcon: String {
        switch self {
        case .complete: return "star.fill"
        case .partial:  return "star.leadinghalf.filled"
        case .empty:    return "circle"
        }
    }

    var widgetColor: Color {
        switch self {
        case .complete: return Color(hex: "F5C518")
        case .partial:  return Color.orange
        case .empty:    return Color(.systemGray4)
        }
    }
}

// MARK: - Shared widget background (MeshGradient estático com as cores do app)

struct WidgetBackground: View {
    @Environment(\.colorScheme) var colorScheme

    private var lightColors: [Color] {[
        Theme.backgroundVanilla, Theme.relationshipCeladon,       Theme.backgroundVanilla,
        Theme.relationshipCeladon, Theme.titleDenim.opacity(0.25), Theme.workBlue.opacity(0.25),
        Theme.backgroundVanilla,   Theme.workBlue.opacity(0.15),   Theme.backgroundVanilla
    ]}

    private var darkColors: [Color] {[
        Color(hex: "011936"), Color(hex: "0D2847"),             Color(hex: "011936"),
        Color(hex: "0D2847"), Theme.titleDenim.opacity(0.25),  Theme.workBlue.opacity(0.18),
        Color(hex: "011936"), Theme.workBlue.opacity(0.12),    Color(hex: "011936")
    ]}

    var body: some View {
        if #available(iOS 18.0, *) {
            MeshGradient(
                width: 3, height: 3,
                points: [
                    [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
                    [0.0, 0.5], [0.5, 0.5], [1.0, 0.5],
                    [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]
                ],
                colors: colorScheme == .dark ? darkColors : lightColors
            )
        } else {
            LinearGradient(
                colors: colorScheme == .dark
                    ? [Color(hex: "011936"), Color(hex: "0D2847")]
                    : [Theme.backgroundVanilla, Theme.relationshipCeladon],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}
