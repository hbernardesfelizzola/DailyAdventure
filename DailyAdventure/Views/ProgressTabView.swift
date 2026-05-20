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
                        Text("🏰")
                            .font(.system(size: 48))
                            .padding(Theme.Spacing.small)
                            .background(Theme.titleDenim.opacity(0.1))
                            .clipShape(Circle())
                            .glassEffectCircleIfAvailable()

                        Text("Your Journey")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(Theme.titleDenim)
                    }
                    .padding(.top, Theme.Spacing.large)

                    // MARK: - Streak Cards
                    HStack(spacing: Theme.Spacing.medium) {
                        StreakCard(
                            icon: "🔥",
                            value: viewModel.currentStreak,
                            label: viewModel.currentStreak == 1 ? "day" : "days",
                            sublabel: "in a row"
                        )
                        StreakCard(
                            icon: "⭐",
                            value: viewModel.excellenceInStreak,
                            label: viewModel.excellenceInStreak == 1 ? "day" : "days",
                            sublabel: "100% complete"
                        )
                        StreakCard(
                            icon: "⚔️",
                            value: viewModel.totalDaysAdventured,
                            label: viewModel.totalDaysAdventured == 1 ? "day" : "days",
                            sublabel: "adventured"
                        )
                    }
                    .padding(.horizontal, Theme.Spacing.medium)

                    // MARK: - Last 7 Days
                    VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
                        Label("Last 7 Days", systemImage: "calendar")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Theme.titleDenim)

                        HStack(spacing: Theme.Spacing.small) {
                            ForEach(viewModel.last7Days, id: \.date) { entry in
                                DayCell(date: entry.date, level: entry.level)
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

                    // MARK: - Today
                    VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
                        Label("Today", systemImage: "star.fill")
                            .font(.system(size: 16, weight: .semibold))
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
                                    Text("⚔️")
                                        .font(.system(size: 36))
                                    Text("No quests set for today yet")
                                        .font(.system(size: 14, weight: .regular))
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

                    Spacer().frame(height: 100)
                }
            }
            .frame(maxWidth: .infinity)
            .scrollEdgeEffectIfAvailable()
        }
    }
}

// MARK: - StreakCard

private struct StreakCard: View {
    let icon: String
    let value: Int
    let label: String
    let sublabel: String

    var body: some View {
        VStack(spacing: 4) {
            Text(icon)
                .font(.system(size: 28))
            Text("\(value)")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Theme.titleDenim)
            Text(label)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(Theme.titleDenim)
            Text(sublabel)
                .font(.system(size: 10, weight: .regular))
                .foregroundColor(Theme.titleDenim.opacity(0.6))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(Theme.Spacing.medium)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusSmall))
        .glassEffectIfAvailable(cornerRadius: Theme.cornerRadiusSmall)
    }
}

// MARK: - DayCell

private struct DayCell: View {
    let date: Date
    let level: DayCompletionLevel

    private var dayLabel: String {
        date.formatted(.dateTime.weekday(.narrow))
    }

    private var bgColor: Color {
        switch level {
        case .complete: return Color(hex: "F5C518")
        case .partial:  return Theme.workBlue
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
                .font(.system(size: 10, weight: .medium))
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
                .font(.system(size: 11, weight: .regular))
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

#Preview {
    ProgressTabView(viewModel: QuestViewModel())
}
