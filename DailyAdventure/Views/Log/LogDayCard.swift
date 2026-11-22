//
//  LogDayCard.swift
//  DailyAdventure
//
//  Card de um dia no Registro: indicador de conclusão, data, aventura do dia e resumo por categoria.
//

import SwiftUI

struct LogDayCard: View {
    let adventure: DailyAdventure
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: 14) {
                DayCompletionBadge(adventure: adventure)

                VStack(alignment: .leading, spacing: 6) {
                    HStack(alignment: .center, spacing: 8) {
                        SectionLabel(verbatim: LogDateLabel.short(for: adventure.date))
                        Spacer(minLength: 0)
                        if let icon = adventure.feedback.icon {
                            Image(systemName: icon)
                                .font(.supporting)
                                .foregroundStyle(adventure.feedback.tint)
                                .accessibilityLabel(adventure.feedback.title)
                        }
                    }

                    if adventure.mainQuest.isEmpty {
                        Text("No daily adventure")
                            .font(.questTitleSmall)
                            .foregroundStyle(Theme.inkSecondary)
                    } else {
                        Text(adventure.mainQuest)
                            .font(.questTitleSmall)
                            .foregroundStyle(Theme.ink)
                            .multilineTextAlignment(.leading)
                    }

                    let summaries = CategorySummary.make(for: adventure)
                    if !summaries.isEmpty {
                        FlowLayout(spacing: 6) {
                            ForEach(summaries) { summary in
                                CategorySummaryChip(summary: summary)
                            }
                        }
                        .padding(.top, 2)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(16)
            .cardSurface(cornerRadius: Theme.Radius.list)
            .contentShape(RoundedRectangle(cornerRadius: Theme.Radius.list))
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityHint(Text("Shows the day's details"))
    }
}

// MARK: - Indicador de conclusão

struct DayCompletionBadge: View {
    let adventure: DailyAdventure

    var body: some View {
        Group {
            switch adventure.completionLevel {
            case .complete:
                Image(systemName: "star.fill")
                    .font(.body.weight(.semibold))
                    // Fixo escuro: o dourado é claro nos dois modos.
                    .foregroundStyle(Color(hex: "1D3550"))
                    .frame(width: 44, height: 44)
                    .background(Theme.goldComplete, in: Circle())
                    .accessibilityLabel(Text("Day complete"))

            case .partial, .empty:
                let done = adventure.completedQuests.count
                let total = adventure.totalQuests
                ZStack {
                    Circle()
                        .stroke(Theme.separator, lineWidth: 4)
                    Circle()
                        .trim(from: 0, to: adventure.completionPercentage)
                        .stroke(Theme.accent, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    Text(verbatim: "\(done)/\(total)")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(done > 0 ? Theme.accent : Theme.inkSecondary)
                        .minimumScaleFactor(0.7)
                }
                .frame(width: 44, height: 44)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(Text("\(done) of \(total) quests done"))
            }
        }
    }
}

// MARK: - Resumo por categoria

struct CategorySummary: Identifiable {
    let category: QuestCategory
    let done: Int
    let total: Int

    var id: String { category.rawValue }

    static func make(for adventure: DailyAdventure) -> [CategorySummary] {
        QuestCategory.allCases.compactMap { category in
            let quests = adventure.sideQuests.filter { $0.category == category }
            guard !quests.isEmpty else { return nil }
            return CategorySummary(category: category, done: quests.filter(\.isCompleted).count, total: quests.count)
        }
    }
}

struct CategorySummaryChip: View {
    let summary: CategorySummary

    var body: some View {
        (Text(summary.category.localizedName) + Text(verbatim: " \(summary.done)/\(summary.total)"))
            .font(.tag)
            .foregroundStyle(summary.category.labelColor)
            .padding(.horizontal, 9)
            .padding(.vertical, 4)
            .background(summary.category.color.opacity(0.14), in: RoundedRectangle(cornerRadius: 10))
    }
}

// MARK: - Datas

enum LogDateLabel {
    /// "Hoje", "Ontem" ou "quinta-feira, 19 de nov.".
    static func short(for date: Date, calendar: Calendar = .current) -> String {
        if calendar.isDateInToday(date) { return String(localized: "Today") }
        if calendar.isDateInYesterday(date) { return String(localized: "Yesterday") }
        let sameYear = calendar.isDate(date, equalTo: Date(), toGranularity: .year)
        return sameYear
            ? date.formatted(.dateTime.weekday(.wide).day().month(.abbreviated))
            : date.formatted(.dateTime.weekday(.wide).day().month(.abbreviated).year())
    }
}
