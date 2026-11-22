//
//  HistoryView.swift
//  DailyAdventure
//
//  Created by Henrique Bernardes on 25/04/26.
//
//  Registro: dias agrupados por semana, com filtros. Tocar num dia abre o detalhe.
//

import SwiftUI

struct HistoryView: View {
    var viewModel: QuestViewModel
    @State private var filter: AdventureLogFilter = .all
    @State private var expandedWeeks: Set<Date> = []
    @State private var selectedDayID: UUID?

    private var allDays: [DailyAdventure] {
        let calendar = Calendar.current
        let today = viewModel.todayAdventure
        var days = viewModel.history.filter { !calendar.isDate($0.date, inSameDayAs: today.date) }
        if today.shouldArchiveToAdventureLog {
            days.insert(today, at: 0)
        }
        return days
    }

    private var weeks: [AdventureLogWeek] {
        AdventureLog.weeks(from: allDays, filter: filter)
    }

    /// Sem filtro, só a semana mais recente começa aberta. Com filtro, todas abertas.
    private func isExpanded(_ week: AdventureLogWeek) -> Bool {
        filter != .all || week.id == weeks.first?.id || expandedWeeks.contains(week.id)
    }

    private var selectedDay: Binding<DailyAdventure?> {
        Binding(
            get: { allDays.first { $0.id == selectedDayID } },
            set: { selectedDayID = $0?.id }
        )
    }

    var body: some View {
        ZStack {
            AnimatedBackgroundView()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    header

                    if allDays.isEmpty {
                        emptyState(
                            title: "No adventures yet!",
                            message: "Your days will show up here once you add quests."
                        )
                    } else {
                        filterBar

                        if weeks.isEmpty {
                            emptyState(title: "No days here yet", message: "Try another filter.")
                        } else {
                            ForEach(weeks) { week in
                                LogWeekSection(
                                    week: week,
                                    isExpanded: isExpanded(week),
                                    showsSummary: filter == .all,
                                    onToggle: {
                                        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                                            _ = expandedWeeks.insert(week.id)
                                        }
                                    },
                                    onSelectDay: { selectedDayID = $0.id }
                                )
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 120)
                .animation(.spring(response: 0.4, dampingFraction: 0.85), value: filter)
            }
            .scrollEdgeEffectIfAvailable()
        }
        .sheet(item: selectedDay) { day in
            DayDetailSheet(adventure: day) { feedback in
                viewModel.updateFeedback(feedback, for: day)
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
    }

    // MARK: - Partes

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Adventure Log")
                .font(.screenTitle)
                .foregroundStyle(Theme.ink)
                .accessibilityAddTraits(.isHeader)
            Text("\(viewModel.totalDaysAdventured) days of adventure")
                .font(.supporting)
                .foregroundStyle(Theme.inkSecondary)
        }
    }

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(AdventureLogFilter.allCases) { option in
                    LogFilterChip(filter: option, isSelected: filter == option) {
                        filter = option
                    }
                }
            }
        }
        .scrollClipDisabled()
    }

    private func emptyState(title: LocalizedStringKey, message: LocalizedStringKey) -> some View {
        VStack(spacing: 8) {
            Image(systemName: "book.closed")
                .font(.title)
                .foregroundStyle(Theme.accent)
                .accessibilityHidden(true)
            Text(title)
                .font(.cardTitle)
                .foregroundStyle(Theme.ink)
            Text(message)
                .font(.supporting)
                .foregroundStyle(Theme.inkSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(28)
        .cardSurface()
    }
}

private struct LogFilterChip: View {
    let filter: AdventureLogFilter
    let isSelected: Bool
    let action: () -> Void

    private var title: LocalizedStringKey {
        switch filter {
        case .all: "All"
        case .complete: "Complete days"
        case .greatDays: "Great days"
        case .toughDays: "Tough days"
        }
    }

    private var icon: String? {
        switch filter {
        case .all: nil
        case .complete: "star.fill"
        case .greatDays: DayFeedback.positive.icon
        case .toughDays: DayFeedback.negative.icon
        }
    }

    private var iconTint: Color {
        switch filter {
        case .all: Theme.accent
        case .complete: Theme.goldComplete
        case .greatDays: DayFeedback.positive.tint
        case .toughDays: DayFeedback.negative.tint
        }
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let icon {
                    Image(systemName: icon)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(isSelected ? Theme.onAccent : iconTint)
                }
                Text(title)
                    .font(.supporting.weight(isSelected ? .semibold : .medium))
                    .foregroundStyle(isSelected ? Theme.onAccent : Theme.ink)
            }
            .padding(.horizontal, 14)
            .frame(minHeight: 36)
            .background(isSelected ? Theme.accent : Theme.cardBackground, in: Capsule())
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    HistoryView(viewModel: QuestViewModel.preview)
}
