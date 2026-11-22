//
//  MonthCalendarCard.swift
//  DailyAdventure
//
//  Calendário do mês com o nível de conclusão de cada dia (mapa de calor).
//

import SwiftUI

struct MonthCalendarCard: View {
    var viewModel: QuestViewModel
    @State private var monthStart: Date = MonthCalendarCard.startOfMonth(for: Date())

    private var calendar: Calendar { .current }

    private static func startOfMonth(for date: Date) -> Date {
        Calendar.current.dateInterval(of: .month, for: date)?.start ?? date
    }

    private var canGoBack: Bool {
        guard let first = viewModel.firstLoggedDate else { return false }
        return monthStart > Self.startOfMonth(for: first)
    }

    private var canGoForward: Bool {
        monthStart < Self.startOfMonth(for: Date())
    }

    /// Dias do mês precedidos de espaços vazios até o primeiro dia da semana do usuário.
    private var cells: [Date?] {
        guard let range = calendar.range(of: .day, in: .month, for: monthStart) else { return [] }
        let weekday = calendar.component(.weekday, from: monthStart)
        let leading = (weekday - calendar.firstWeekday + 7) % 7
        let days = range.compactMap { calendar.date(byAdding: .day, value: $0 - 1, to: monthStart) }
        return Array(repeating: nil, count: leading) + days.map(Optional.some)
    }

    /// Iniciais dos dias da semana na ordem do calendário do usuário.
    private var weekdaySymbols: [String] {
        let symbols = calendar.veryShortStandaloneWeekdaySymbols
        let start = calendar.firstWeekday - 1
        return Array(symbols[start...] + symbols[..<start])
    }

    /// "Novembro de 2026" (só a primeira letra maiúscula).
    private var monthTitle: String {
        let title = monthStart.formatted(.dateTime.month(.wide).year())
        return title.prefix(1).uppercased() + title.dropFirst()
    }

    /// Células agrupadas em semanas de 7 (a última completada com vazios).
    private var weeks: [[Date?]] {
        var all = cells
        while all.count % 7 != 0 { all.append(nil) }
        return stride(from: 0, to: all.count, by: 7).map { Array(all[$0..<$0 + 7]) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(monthTitle)
                    .font(.sectionTitle)
                    .foregroundStyle(Theme.ink)
                    .accessibilityAddTraits(.isHeader)
                Spacer()
                if canGoBack || canGoForward {
                    monthButton(systemImage: "chevron.left", label: "Previous month", enabled: canGoBack, offset: -1)
                    monthButton(systemImage: "chevron.right", label: "Next month", enabled: canGoForward, offset: 1)
                }
            }

            VStack(spacing: 6) {
                HStack(spacing: 6) {
                    ForEach(Array(weekdaySymbols.enumerated()), id: \.offset) { _, symbol in
                        Text(symbol)
                            .font(.tag)
                            .foregroundStyle(Theme.inkSecondary)
                            .frame(maxWidth: .infinity)
                    }
                }
                .accessibilityHidden(true)

                ForEach(Array(weeks.enumerated()), id: \.offset) { _, week in
                    HStack(spacing: 6) {
                        ForEach(Array(week.enumerated()), id: \.offset) { _, date in
                            Group {
                                if let date {
                                    DayCell(date: date, level: viewModel.completionLevel(on: date))
                                } else {
                                    Color.clear.aspectRatio(1, contentMode: .fit)
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
            }

            HStack(spacing: 14) {
                legend(color: Theme.goldComplete, title: "Complete")
                legend(color: DayCell.partialColor, title: "Partial")
                legend(color: DayCell.emptyColor, title: "No completions")
            }
            .accessibilityElement(children: .combine)
        }
        .padding(18)
        .cardSurface()
        .animation(.easeInOut(duration: 0.2), value: monthStart)
    }

    private func monthButton(systemImage: String, label: LocalizedStringKey, enabled: Bool, offset: Int) -> some View {
        Button {
            if let month = calendar.date(byAdding: .month, value: offset, to: monthStart) {
                monthStart = month
            }
        } label: {
            Image(systemName: systemImage)
                .font(.supporting.weight(.semibold))
                .foregroundStyle(Theme.accent)
                .frame(width: 44, height: 44)
                .background(Theme.surfaceSecondary, in: Circle())
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
        .opacity(enabled ? 1 : 0.35)
        .accessibilityLabel(label)
    }

    private func legend(color: Color, title: LocalizedStringKey) -> some View {
        HStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 3)
                .fill(color)
                .frame(width: 12, height: 12)
            Text(title)
                .font(.tag.weight(.regular))
                .foregroundStyle(Theme.inkSecondary)
        }
    }
}

private struct DayCell: View {
    let date: Date
    let level: DayCompletionLevel?

    static var partialColor: Color { Theme.accent.opacity(0.45) }
    static var emptyColor: Color { Theme.ink.opacity(0.08) }

    private var isToday: Bool { Calendar.current.isDateInToday(date) }
    private var isFuture: Bool { date > Date() && !isToday }

    private var fill: Color {
        if isFuture { return .clear }
        switch level {
        case .complete: return Theme.goldComplete
        case .partial: return Self.partialColor
        case .empty, nil: return Self.emptyColor
        }
    }

    private var textColor: Color {
        if isFuture { return Theme.inkSecondary.opacity(0.6) }
        // Dourado é claro nos dois modos: número escuro fixo.
        if level == .complete { return Color(hex: "1D3550") }
        return level == nil || level == .empty ? Theme.inkSecondary : Theme.ink
    }

    private var stateDescription: LocalizedStringKey {
        switch level {
        case .complete: "Complete"
        case .partial: "Partial"
        case .empty, nil: "No completions"
        }
    }

    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(fill)
            .aspectRatio(1, contentMode: .fit)
            .overlay {
                Text(date, format: .dateTime.day())
                    .font(.supporting.weight(.semibold))
                    .foregroundStyle(textColor)
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
            }
            .overlay {
                if isToday {
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(Theme.accent, lineWidth: 2)
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text(date, format: .dateTime.day().month(.wide)))
            .accessibilityValue(isFuture ? Text(verbatim: "") : Text(stateDescription))
    }
}
