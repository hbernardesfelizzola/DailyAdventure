//
//  DailyQuestWidget.swift
//  DailyAdventureWidget
//
//  Small: lembrete de quest por categoria.
//  Medium: lista de quests + donut por categoria (espelho do DrawingProgressView).

import WidgetKit
import SwiftUI
import Charts

struct DailyQuestWidget: Widget {
    let kind = "DailyQuestWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DailyAdventureProvider()) { entry in
            DailyQuestWidgetView(entry: entry)
        }
        .configurationDisplayName("Today's Quest")
        .description("Your main quest and progress at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Router

struct DailyQuestWidgetView: View {
    let entry: DailyAdventureEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        Group {
            switch family {
            case .systemMedium: MediumQuestView(entry: entry)
            default:            SmallReminderView(entry: entry)
            }
        }
        .containerBackground(for: .widget) { WidgetBackground() }
    }
}

// MARK: - Small: Reminder

struct SmallReminderView: View {
    let entry: DailyAdventureEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack(spacing: 4) {
                Image(systemName: "bell.fill")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(Theme.titleDenim)
                Text("REMINDER")
                    .font(.system(size: 9, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.titleDenim)
                    .tracking(1)
            }

            Spacer(minLength: 10)

            if let reminder = entry.reminderQuest {
                reminderContent(title: reminder.title, category: reminder.category)
            } else if entry.totalCount == 0 {
                emptyContent
            } else {
                allDoneContent
            }

            Spacer(minLength: 0)
        }
        .padding(14)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .widgetURL(URL(string: "dailyadventure://today"))
    }

    // Categoria encontrada: mostra ícone + nome da categoria + título da quest
    private func reminderContent(title: String, category: QuestCategory?) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                categoryCircle(icon: category?.icon ?? "star.fill",
                               color: category?.color ?? Theme.titleDenim)
                Text(category?.rawValue ?? "Main Quest")
                    .font(.caption.bold())
                    .foregroundStyle(category?.color ?? Theme.titleDenim)
            }
            Text(title)
                .font(.footnote.bold())
                .foregroundStyle(Color.primary)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var allDoneContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            categoryCircle(icon: "star.fill", color: Color(hex: "F5C518"))
            Text("All done\ntoday!")
                .font(.footnote.bold())
                .foregroundStyle(Color.primary)
        }
    }

    private var emptyContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: "scroll")
                .font(.system(size: 26))
                .foregroundStyle(Theme.titleDenim.opacity(0.3))
            Text("No adventure\nset today")
                .font(.footnote.bold())
                .foregroundStyle(Theme.titleDenim)
        }
    }

    private func categoryCircle(icon: String, color: Color) -> some View {
        ZStack {
            Circle()
                .fill(color.opacity(0.2))
                .frame(width: 38, height: 38)
            Image(systemName: icon)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(color)
        }
    }
}

// MARK: - Medium: Quest list + Category sector chart

struct MediumQuestView: View {
    let entry: DailyAdventureEntry

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            questColumn
            if entry.totalCount > 0 {
                Divider().overlay(Theme.titleDenim.opacity(0.15))
                chartColumn
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .widgetURL(URL(string: "dailyadventure://today"))
    }

    // MARK: Quest column

    private var questColumn: some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack(spacing: 5) {
                Image(systemName: "star.fill")
                    .font(.caption.bold())
                    .foregroundStyle(entry.adventure.completionLevel.widgetColor)
                Text("Today's Adventure")
                    .font(.subheadline.bold())
                    .foregroundStyle(Color.primary)
            }

            Divider().overlay(Theme.titleDenim.opacity(0.15))

            if entry.adventure.mainQuest.isEmpty && entry.adventure.sideQuests.isEmpty {
                Spacer()
                VStack(alignment: .leading, spacing: 5) {
                    Image(systemName: "scroll").foregroundStyle(Theme.titleDenim.opacity(0.3))
                    Text("No adventure\nset for today")
                        .font(.caption.bold())
                        .foregroundStyle(Theme.titleDenim)
                }
                Spacer()
            } else {
                // Main quest
                if !entry.adventure.mainQuest.isEmpty {
                    HStack(alignment: .firstTextBaseline, spacing: 5) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(entry.isMainQuestCompleted
                                ? Color(hex: "F5C518") : Theme.titleDenim.opacity(0.35))
                        Text(entry.adventure.mainQuest)
                            .font(.headline)
                            .foregroundStyle(entry.isMainQuestCompleted
                                ? Color.primary.opacity(0.45) : Color.primary)
                            .lineLimit(2)
                            .strikethrough(entry.isMainQuestCompleted)
                    }
                }
                // Side quests
                ForEach(entry.adventure.sideQuests.prefix(3)) { quest in
                    questRow(quest)
                }
                if entry.adventure.sideQuests.count > 3 {
                    Text("+ \(entry.adventure.sideQuests.count - 3) more")
                        .font(.caption2)
                        .foregroundStyle(Theme.titleDenim.opacity(0.5))
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func questRow(_ quest: Quest) -> some View {
        let done = entry.adventure.completedQuests.contains { $0.id == quest.id }
        return HStack(spacing: 6) {
            Image(systemName: done ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 13))
                .foregroundStyle(done
                    ? (quest.category?.color ?? Theme.titleDenim)
                    : Theme.titleDenim.opacity(0.4))
            Text(quest.title)
                .font(.caption.bold())
                .foregroundStyle(done ? Color.primary.opacity(0.45) : Color.primary)
                .lineLimit(1)
                .strikethrough(done)
            Spacer(minLength: 0)
            if let cat = quest.category {
                Image(systemName: cat.icon)
                    .font(.system(size: 10))
                    .foregroundStyle(cat.color.opacity(0.65))
            }
        }
    }

    // MARK: Chart column — espelho do DrawingProgressView do app

    private var chartColumn: some View {
        VStack(spacing: 5) {
            Spacer(minLength: 0)
            WidgetCategoryChart(adventure: entry.adventure)
                .frame(width: 64, height: 64)
            Text(progressLabel)
                .font(.system(size: 9, weight: .semibold))
                .foregroundStyle(Theme.titleDenim)
                .multilineTextAlignment(.center)
            Spacer(minLength: 0)
        }
        .frame(width: 72)
    }

    private var progressLabel: String {
        switch entry.adventure.completionLevel {
        case .complete: return "All done!"
        case .partial:  return "In progress"
        case .empty:    return "Not started"
        }
    }
}

// MARK: - Category sector chart (mirrors DrawingProgressView)

struct WidgetCategoryChart: View {
    let adventure: DailyAdventure

    private var workWeight: Double   { max(1.0, Double(adventure.sideQuests.filter { $0.category == .work }.count)) }
    private var healthWeight: Double { max(1.0, Double(adventure.sideQuests.filter { $0.category == .health }.count)) }
    private var relWeight: Double    { max(1.0, Double(adventure.sideQuests.filter { $0.category == .relationship }.count)) }

    private func opacity(for completed: Bool) -> Double { completed ? 0.88 : 0.12 }

    var body: some View {
        ZStack {
            Chart {
                SectorMark(angle: .value("Main", 1.0),          innerRadius: .ratio(0.58), angularInset: 1.5)
                    .foregroundStyle(Theme.titleDenim.opacity(
                        opacity(for: adventure.completedQuests.contains { $0.isMainQuest })))

                SectorMark(angle: .value("Work", workWeight),   innerRadius: .ratio(0.58), angularInset: 1.5)
                    .foregroundStyle(QuestCategory.work.color.opacity(
                        opacity(for: adventure.completedQuests.contains { $0.category == .work })))

                SectorMark(angle: .value("Health", healthWeight), innerRadius: .ratio(0.58), angularInset: 1.5)
                    .foregroundStyle(QuestCategory.health.color.opacity(
                        opacity(for: adventure.completedQuests.contains { $0.category == .health })))

                SectorMark(angle: .value("Rel", relWeight),     innerRadius: .ratio(0.58), angularInset: 1.5)
                    .foregroundStyle(QuestCategory.relationship.color.opacity(
                        opacity(for: adventure.completedQuests.contains { $0.category == .relationship })))
            }
            .chartLegend(.hidden)

            VStack(spacing: 0) {
                Text("\(Int(adventure.completionPercentage * 100))%")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.primary)
                Text("done")
                    .font(.system(size: 8, weight: .medium))
                    .foregroundStyle(Color.primary.opacity(0.5))
            }
        }
    }
}

// MARK: - Previews

#Preview(as: .systemSmall) {
    DailyQuestWidget()
} timeline: {
    DailyAdventureEntry.placeholder
}

#Preview(as: .systemMedium) {
    DailyQuestWidget()
} timeline: {
    DailyAdventureEntry.placeholder
}
