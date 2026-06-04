//
//  ProgressTabView.swift
//  DailyAdventure
//

import SwiftUI
import Charts

struct ProgressTabView: View {
    var viewModel: QuestViewModel

    var body: some View {
        ZStack {
            AnimatedBackgroundView()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: Theme.Spacing.large) {

                    // MARK: - Header
                    HStack(spacing: Theme.Spacing.medium) {
                        Image(systemName: "chart.pie.fill")
                            .font(.system(size: 26))
                            .foregroundColor(Theme.titleDenim)
                            .frame(width: 56, height: 56)
                            .background(Theme.titleDenim.opacity(0.1))
                            .clipShape(Circle())
                            .glassEffectCircleIfAvailable()

                        Text("Your Progress")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(Theme.titleDenim)
                    }
                    .padding(.top, Theme.Spacing.large)

                    // MARK: - Today
                    VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
                        Label("Today", systemImage: "star.fill")
                            .font(.headline)
                            .foregroundColor(Theme.titleDenim)

                        if viewModel.todayAdventure.hasAnyQuest {
                            DrawingProgressView(
                                progress: viewModel.todayAdventure.completionPercentage,
                                completedQuests: viewModel.todayAdventure.completedQuests,
                                totalQuests: viewModel.todayAdventure.totalQuests,
                                allSideQuests: viewModel.todayAdventure.sideQuests
                            )
                        } else {
                            HStack {
                                Spacer()
                                VStack(spacing: Theme.Spacing.small) {
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 30))
                                        .foregroundColor(Theme.titleDenim.opacity(0.3))
                                    Text("No quests set for today yet")
                                        .font(.subheadline)
                                        .foregroundColor(Theme.titleDenim.opacity(0.7))
                                }
                                Spacer()
                            }
                            .padding(Theme.Spacing.medium)
                        }
                    }
                    .padding(Theme.Spacing.medium)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
                    .glassEffectIfAvailable()
                    .padding(.horizontal, Theme.Spacing.medium)

                    // MARK: - Last 7 Days
                    VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
                        Label("Last 7 Days", systemImage: "calendar")
                            .font(.headline)
                            .foregroundColor(Theme.titleDenim)

                        HStack(spacing: Theme.Spacing.small) {
                            ForEach(viewModel.last7Days, id: \.date) { entry in
                                DayCell(date: entry.date, level: entry.level, dominantCategory: entry.dominantCategory)
                            }
                        }
                        .frame(maxWidth: .infinity)

                        // Legenda
                        HStack(spacing: Theme.Spacing.medium) {
                            LegendItem(color: Color(hex: "F5C518"), label: "Complete")
                            LegendItem(color: Theme.workBlue, label: "Partial")
                            LegendItem(color: Theme.titleDenim.opacity(0.2), label: "Empty")
                        }
                    }
                    .padding(Theme.Spacing.medium)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
                    .glassEffectIfAvailable()
                    .padding(.horizontal, Theme.Spacing.medium)

                    // MARK: - Category Insights
                    if viewModel.categoryStats.contains(where: { $0.hasData }) {
                        CategoryInsightsCard(stats: viewModel.categoryStats)
                    }

                    Spacer().frame(height: 100)
                }
            }
            .frame(maxWidth: .infinity)
            .scrollEdgeEffectIfAvailable()
        }
    }
}

// MARK: - DayCell

private struct DayCell: View {
    let date: Date
    let level: DayCompletionLevel
    let dominantCategory: QuestCategory?

    private var dayLabel: String {
        date.formatted(.dateTime.weekday(.narrow))
    }

    private var bgColor: Color {
        switch level {
        case .complete: return Color(hex: "F5C518")
        case .partial:  return dominantCategory?.color ?? Theme.workBlue
        case .empty:    return Theme.titleDenim.opacity(0.15)
        }
    }

    private var icon: String? {
        switch level {
        case .complete: return "star.fill"
        case .partial:  return "circle.fill"
        case .empty:    return nil
        }
    }

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(bgColor.opacity(level == .empty ? 1 : 0.25))
                    .frame(height: 44)

                if let icon {
                    Image(systemName: icon)
                        .foregroundColor(bgColor)
                        .font(.system(size: level == .complete ? 16 : 10))
                }
            }
            .glassEffectIfAvailable(cornerRadius: 8)

            Text(dayLabel)
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(Theme.titleDenim.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - LegendItem

private struct LegendItem: View {
    let color: Color
    let label: String

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
                .font(.caption2)
                .foregroundColor(Theme.titleDenim.opacity(0.7))
        }
    }
}

// MARK: - MissingQuestRow (mantida para compatibilidade)

struct MissingQuestRow: View {
    let icon: String
    let color: Color
    let message: String

    var body: some View {
        HStack(spacing: Theme.Spacing.small) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 32, height: 32)
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 14, weight: .semibold))
            }
            .glassEffectCircleIfAvailable()
            Text(message)
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(Theme.titleDenim.opacity(0.8))
            Spacer()
        }
        .padding(Theme.Spacing.small)
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusSmall))
        .glassEffectIfAvailable(cornerRadius: Theme.cornerRadiusSmall)
    }
}

// MARK: - CategoryInsightsCard

private struct CategoryInsightsCard: View {
    let stats: [CategoryStat]

    private var activeStats: [CategoryStat] { stats.filter { $0.hasData } }

    private var mostFocused: CategoryStat? {
        activeStats.max(by: { $0.totalAdded < $1.totalAdded })
    }

    private var neglectedCategories: [CategoryStat] {
        let noData = stats.filter { !$0.hasData }
        if !noData.isEmpty { return noData }
        guard let minAdded = activeStats.map(\.totalAdded).min() else { return [] }
        return activeStats.filter { $0.totalAdded == minAdded }
    }

    @ViewBuilder
    private var insightSection: some View {
        let neglected = neglectedCategories
        if neglected.count == stats.count {
            InsightChip(
                systemImage: "checkmark.circle.fill",
                color: Theme.healthColor,
                text: String(localized: "You're keeping a great balance across all categories!")
            )
        } else if let focused = mostFocused, !neglected.isEmpty,
                  focused.category != neglected[0].category,
                  focused.totalAdded > (neglected.first?.totalAdded ?? 0) || neglected.contains(where: { !$0.hasData }) {
            let focusedName = NSLocalizedString(focused.category.rawValue, comment: "")
            InsightChip(
                systemImage: focused.category.icon,
                color: focused.category.color,
                text: String(format: NSLocalizedString("insight.focus_format", comment: ""), focusedName)
            )
            if neglected.count == 1 {
                let neglectedName = NSLocalizedString(neglected[0].category.rawValue, comment: "")
                InsightChip(
                    systemImage: "exclamationmark.circle.fill",
                    color: neglected[0].category.color,
                    text: String(format: NSLocalizedString("insight.neglect_format", comment: ""), neglectedName)
                )
            } else {
                let separator = NSLocalizedString(" and ", comment: "")
                let names = neglected.map { NSLocalizedString($0.category.rawValue, comment: "") }.joined(separator: separator)
                InsightChip(
                    systemImage: "exclamationmark.circle.fill",
                    color: Theme.titleDenim,
                    text: String(format: NSLocalizedString("insight.neglect_format", comment: ""), names)
                )
            }
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
            VStack(alignment: .leading, spacing: 2) {
                Label("Category Insights", systemImage: "chart.bar.fill")
                    .font(.headline)
                    .foregroundColor(Theme.titleDenim)
                Text("From all your logged adventures")
                    .font(.footnote)
                    .foregroundColor(Theme.titleDenim.opacity(0.5))
            }

            VStack(spacing: Theme.Spacing.small) {
                ForEach(stats, id: \.category.rawValue) { stat in
                    CategoryStatRow(stat: stat)
                }
            }

            Divider()
                .background(Theme.titleDenim.opacity(0.2))

            VStack(alignment: .leading, spacing: Theme.Spacing.small) {
                insightSection
            }
        }
        .padding(Theme.Spacing.medium)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
        .glassEffectIfAvailable()
        .padding(.horizontal, Theme.Spacing.medium)
    }
}

// MARK: - CategoryStatRow

private struct CategoryStatRow: View {
    let stat: CategoryStat

    var body: some View {
        HStack(spacing: Theme.Spacing.small) {
            ZStack {
                Circle()
                    .fill(stat.category.color.opacity(0.2))
                    .frame(width: 32, height: 32)
                Image(systemName: stat.category.icon)
                    .foregroundColor(stat.category.color)
                    .font(.system(size: 14, weight: .semibold))
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(stat.category.rawValue)
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .foregroundColor(Theme.titleDenim)
                    Spacer()
                    if stat.hasData {
                        Text("\(stat.totalCompleted)/\(stat.totalAdded)")
                            .font(.caption2)
                            .foregroundColor(Theme.titleDenim.opacity(0.6))
                    } else {
                        Text("No quests yet")
                            .font(.caption2)
                            .foregroundColor(Theme.titleDenim.opacity(0.4))
                    }
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Theme.titleDenim.opacity(0.1))
                            .frame(height: 6)
                        if stat.hasData {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(stat.category.color)
                                .frame(width: geo.size.width * stat.completionRate, height: 6)
                        }
                    }
                }
                .frame(height: 6)
            }
        }
    }
}

// MARK: - InsightChip

private struct InsightChip: View {
    let systemImage: String
    let color: Color
    let text: String

    var body: some View {
        HStack(spacing: Theme.Spacing.small) {
            Image(systemName: systemImage)
                .foregroundColor(color)
                .font(.system(size: 13))
            Text(text)
                .font(.footnote)
                .foregroundColor(Theme.titleDenim.opacity(0.8))
            Spacer()
        }
    }
}

#Preview {
    ProgressTabView(viewModel: QuestViewModel())
}
