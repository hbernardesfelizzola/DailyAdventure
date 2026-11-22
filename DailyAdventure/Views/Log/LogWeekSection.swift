//
//  LogWeekSection.swift
//  DailyAdventure
//
//  Uma semana do Registro: rótulo, resumo com a tirinha dos 7 dias e os cards dos dias.
//  Semanas recolhidas mostram só o resumo.
//

import SwiftUI

struct LogWeekSection: View {
    let week: AdventureLogWeek
    let isExpanded: Bool
    /// Com filtro ativo o resumo da semana não faz sentido: mostra só os dias.
    let showsSummary: Bool
    let onToggle: () -> Void
    let onSelectDay: (DailyAdventure) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if isExpanded {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 12) {
                        SectionLabel(verbatim: WeekLabel.title(for: week.interval))
                        Spacer(minLength: 0)
                        if showsSummary {
                            WeekStrip(week: week)
                        }
                    }
                    if showsSummary {
                        Text("Days with a completed quest: \(week.daysWithCompletion) of \(week.days.count)")
                            .font(.supporting)
                            .foregroundStyle(Theme.ink)
                    }
                }
                .accessibilityElement(children: .combine)
                .accessibilityAddTraits(.isHeader)

                VStack(spacing: 10) {
                    ForEach(week.days) { day in
                        LogDayCard(adventure: day) { onSelectDay(day) }
                    }
                }
            } else {
                SectionLabel(verbatim: WeekLabel.title(for: week.interval))
                    .accessibilityAddTraits(.isHeader)

                Button(action: onToggle) {
                    HStack(spacing: 14) {
                        VStack(alignment: .leading, spacing: 8) {
                            (Text("\(week.days.count) days") + Text(verbatim: " · ") + Text("\(week.completeDays) complete"))
                                .font(.rowText.weight(.semibold))
                                .foregroundStyle(Theme.ink)
                            WeekStrip(week: week)
                        }
                        Spacer(minLength: 0)
                        Image(systemName: "chevron.down")
                            .font(.supporting.weight(.semibold))
                            .foregroundStyle(Theme.inkSecondary)
                    }
                    .padding(16)
                    .cardSurface(cornerRadius: Theme.Radius.list)
                    .contentShape(RoundedRectangle(cornerRadius: Theme.Radius.list))
                }
                .buttonStyle(.plain)
                .accessibilityElement(children: .combine)
                .accessibilityValue(Text("Collapsed"))
                .accessibilityHint(Text("Shows the days of this week"))
            }
        }
    }
}

/// Os 7 dias da semana como quadradinhos: dourado = completo, azul = parcial, cinza = sem conclusão,
/// contorno = dia que ainda não chegou.
struct WeekStrip: View {
    let week: AdventureLogWeek

    var body: some View {
        HStack(spacing: 4) {
            ForEach(week.strip(), id: \.date) { entry in
                cell(date: entry.date, level: entry.level)
            }
        }
        .accessibilityHidden(true)
    }

    @ViewBuilder
    private func cell(date: Date, level: DayCompletionLevel?) -> some View {
        let shape = RoundedRectangle(cornerRadius: 4)
        if date > Date() && !Calendar.current.isDateInToday(date) {
            shape.strokeBorder(Theme.separator, lineWidth: 1.5)
                .frame(width: 14, height: 14)
        } else {
            shape.fill(color(for: level))
                .frame(width: 14, height: 14)
        }
    }

    private func color(for level: DayCompletionLevel?) -> Color {
        switch level {
        case .complete: Theme.goldComplete
        case .partial: Theme.accent.opacity(0.5)
        case .empty, nil: Theme.ink.opacity(0.1)
        }
    }
}

enum WeekLabel {
    /// "Esta semana", "Semana passada" ou "2 – 8 de nov.".
    static func title(for interval: DateInterval, calendar: Calendar = .current, now: Date = Date()) -> String {
        if interval.contains(now) { return String(localized: "This week") }
        if let lastWeek = calendar.date(byAdding: .weekOfYear, value: -1, to: now), interval.contains(lastWeek) {
            return String(localized: "Last week")
        }
        let lastDay = calendar.date(byAdding: .day, value: -1, to: interval.end) ?? interval.end
        return (interval.start..<lastDay).formatted(.interval.day().month(.abbreviated))
    }
}
