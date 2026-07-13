//
//  LockScreenWidget.swift
//  DailyAdventureWidget
//
//  Lock screen widgets — circular, rectangular, and inline (iOS 16+).

import WidgetKit
import SwiftUI

struct LockScreenWidget: Widget {
    let kind = "LockScreenWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DailyAdventureProvider()) { entry in
            LockScreenWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Quest Status")
        .description("Quest completion on your lock screen.")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline])
    }
}

// MARK: - Router

struct LockScreenWidgetView: View {
    let entry: DailyAdventureEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        Group {
            switch family {
            case .accessoryCircular:    CircularView(entry: entry)
            case .accessoryRectangular: RectangularView(entry: entry)
            default:                    InlineView(entry: entry)
            }
        }
        // Accessory widgets têm pouquíssimo espaço (circular tem ~76pt de diâmetro) — não deixa
        // escalar além do tamanho padrão de Dynamic Type pra não cortar o conteúdo.
        .dynamicTypeSize(.xSmall ... .large)
    }
}

// MARK: - Circular

struct CircularView: View {
    let entry: DailyAdventureEntry

    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            VStack(spacing: 1) {
                Image(systemName: entry.adventure.completionLevel.widgetIcon)
                    .font(.body.weight(.semibold))
                if entry.totalCount > 0 {
                    Text("\(entry.completedCount)/\(entry.totalCount)")
                        .font(.system(.caption2, design: .rounded).bold())
                }
            }
        }
        .widgetURL(URL(string: "dailyadventure://today"))
    }
}

// MARK: - Rectangular

struct RectangularView: View {
    let entry: DailyAdventureEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 4) {
                Image(systemName: entry.adventure.completionLevel.widgetIcon)
                    .font(.caption2.bold())
                Text("Daily Adventure")
                    .font(.caption2.bold())
                    .lineLimit(1)
            }
            Text(
                entry.adventure.mainQuest.isEmpty
                    ? "Set today's quest →"
                    : entry.adventure.mainQuest
            )
            .font(.caption)
            .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .widgetURL(URL(string: "dailyadventure://today"))
    }
}

// MARK: - Inline

struct InlineView: View {
    let entry: DailyAdventureEntry

    var body: some View {
        Label {
            if entry.adventure.mainQuest.isEmpty {
                Text("Start your adventure")
            } else if entry.totalCount == 0 {
                Text(entry.adventure.mainQuest)
            } else {
                Text("\(entry.completedCount)/\(entry.totalCount) quests done")
            }
        } icon: {
            Image(systemName: entry.adventure.completionLevel.widgetIcon)
        }
        .widgetURL(URL(string: "dailyadventure://today"))
    }
}

// MARK: - Previews

#Preview(as: .accessoryCircular) {
    LockScreenWidget()
} timeline: {
    DailyAdventureEntry.placeholder
}

#Preview(as: .accessoryRectangular) {
    LockScreenWidget()
} timeline: {
    DailyAdventureEntry.placeholder
}

#Preview(as: .accessoryInline) {
    LockScreenWidget()
} timeline: {
    DailyAdventureEntry.placeholder
}
