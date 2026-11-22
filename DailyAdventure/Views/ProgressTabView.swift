//
//  ProgressTabView.swift
//  DailyAdventure
//
//  Progresso: sequência atual, calendário do mês e totais.
//  Tudo aqui é retrospectivo — nada de metas, recordes ou cobranças (ver a sequência em StreakCalculator).
//

import SwiftUI

struct ProgressTabView: View {
    var viewModel: QuestViewModel

    var body: some View {
        ZStack {
            AnimatedBackgroundView()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    Text("Progress")
                        .font(.screenTitle)
                        .foregroundStyle(Theme.ink)
                        .accessibilityAddTraits(.isHeader)

                    StreakHeroCard(
                        streak: viewModel.currentStreak,
                        excellence: viewModel.excellenceInStreak,
                        totalDays: viewModel.totalDaysAdventured
                    )

                    MonthCalendarCard(viewModel: viewModel)

                    totals
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 120)
            }
            .scrollEdgeEffectIfAvailable()
        }
    }

    private var totals: some View {
        Grid(horizontalSpacing: 10, verticalSpacing: 10) {
            GridRow {
                StatTile(value: Text(viewModel.totalQuestsCompleted, format: .number), label: Text(viewModel.totalQuestsCompleted == 1 ? "quest completed" : "quests completed"))
                if let rate = viewModel.dailyAdventureCompletionRate {
                    StatTile(
                        value: Text(rate, format: .percent.precision(.fractionLength(0))),
                        label: Text("of daily adventures done")
                    )
                }
            }
            // Com sequência ativa o card principal não mostra os dias de aventura: mostra aqui.
            if viewModel.currentStreak > 0 {
                GridRow {
                    StatTile(
                        value: Text(viewModel.totalDaysAdventured, format: .number),
                        label: Text(viewModel.totalDaysAdventured == 1 ? "day of adventure" : "days of adventure")
                    )
                    .gridCellColumns(viewModel.dailyAdventureCompletionRate == nil ? 1 : 2)
                }
            }
        }
    }
}

// MARK: - Sequência

private struct StreakHeroCard: View {
    let streak: Int
    let excellence: Int
    let totalDays: Int

    private var excellenceText: Text? {
        guard excellence > 0 else { return nil }
        if excellence == streak {
            return streak == 1 ? Text("Every quest done.") : Text("Every quest done on all of them.")
        }
        return Text("Every quest done on \(excellence) of them.")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if streak > 0 {
                Label("Current streak", systemImage: "flame.fill")
                    .font(.label)
                    .textCase(.uppercase)
                    .tracking(0.8)
                    .foregroundStyle(Theme.onAccent.opacity(0.85))
                    .labelStyle(GoldIconLabelStyle())

                HStack(alignment: .firstTextBaseline, spacing: 10) {
                    Text(streak, format: .number)
                        .font(.system(size: 64, weight: .bold, design: .serif))
                    Text(streak == 1 ? "day in a row" : "days in a row")
                        .font(.questTitleSmall)
                }
                .foregroundStyle(Theme.onAccent)
                .accessibilityElement(children: .combine)

                if let excellenceText {
                    excellenceText
                        .font(.supporting)
                        .foregroundStyle(Theme.onAccent.opacity(0.88))
                }
            } else if totalDays > 0 {
                Label("Your journey", systemImage: "map.fill")
                    .font(.label)
                    .textCase(.uppercase)
                    .tracking(0.8)
                    .foregroundStyle(Theme.onAccent.opacity(0.85))
                    .labelStyle(GoldIconLabelStyle())

                HStack(alignment: .firstTextBaseline, spacing: 10) {
                    Text(totalDays, format: .number)
                        .font(.system(size: 64, weight: .bold, design: .serif))
                    Text(totalDays == 1 ? "day of adventure" : "days of adventure")
                        .font(.questTitleSmall)
                }
                .foregroundStyle(Theme.onAccent)
                .accessibilityElement(children: .combine)
            } else {
                Label("Your journey", systemImage: "map.fill")
                    .font(.label)
                    .textCase(.uppercase)
                    .tracking(0.8)
                    .foregroundStyle(Theme.onAccent.opacity(0.85))
                    .labelStyle(GoldIconLabelStyle())

                Text("Your adventures will show up here.")
                    .font(.cardTitle)
                    .foregroundStyle(Theme.onAccent)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(22)
        .background(Theme.accent, in: RoundedRectangle(cornerRadius: Theme.Radius.card))
        .shadow(color: Theme.accent.opacity(0.3), radius: 12, y: 6)
    }
}

/// Ícone dourado + título, para os rótulos do card azul.
private struct GoldIconLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 8) {
            configuration.icon.foregroundStyle(Theme.goldComplete)
            configuration.title
        }
    }
}

// MARK: - Totais

private struct StatTile: View {
    let value: Text
    let label: Text

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            value
                .font(.system(.title, design: .serif, weight: .bold))
                .foregroundStyle(Theme.ink)
            label
                .font(.supporting)
                .foregroundStyle(Theme.inkSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(16)
        .cardSurface(cornerRadius: Theme.Radius.list)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    ProgressTabView(viewModel: QuestViewModel.preview)
}
