//
//  AdventureLog.swift
//  DailyAdventure
//
//  Agrupamento e filtros do Registro, separados da View para serem testáveis.
//

import Foundation

/// Uma semana do Registro (segue o primeiro dia da semana do calendário do usuário).
struct AdventureLogWeek: Identifiable {
    let interval: DateInterval
    /// Dias registrados nessa semana, do mais recente para o mais antigo.
    let days: [DailyAdventure]

    var id: Date { interval.start }

    /// Dias com pelo menos uma quest concluída.
    var daysWithCompletion: Int { days.filter { $0.completionLevel != .empty }.count }
    /// Dias com todas as quests concluídas.
    var completeDays: Int { days.filter { $0.completionLevel == .complete }.count }

    /// Os 7 dias da semana, em ordem, com o nível de conclusão de cada um (nil = sem registro).
    func strip(calendar: Calendar = .current) -> [(date: Date, level: DayCompletionLevel?)] {
        (0..<7).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: offset, to: interval.start) else { return nil }
            let day = days.first { calendar.isDate($0.date, inSameDayAs: date) }
            return (date, day?.completionLevel)
        }
    }
}

enum AdventureLogFilter: String, CaseIterable, Identifiable {
    case all, complete, greatDays, toughDays

    var id: String { rawValue }

    func includes(_ day: DailyAdventure) -> Bool {
        switch self {
        case .all: true
        case .complete: day.completionLevel == .complete
        case .greatDays: day.feedback == .positive
        case .toughDays: day.feedback == .negative
        }
    }
}

enum AdventureLog {
    /// Agrupa os dias por semana, da semana mais recente para a mais antiga.
    static func weeks(
        from days: [DailyAdventure],
        filter: AdventureLogFilter = .all,
        calendar: Calendar = .current
    ) -> [AdventureLogWeek] {
        var buckets: [Date: (interval: DateInterval, days: [DailyAdventure])] = [:]
        for day in days where filter.includes(day) {
            guard let interval = calendar.dateInterval(of: .weekOfYear, for: day.date) else { continue }
            buckets[interval.start, default: (interval, [])].days.append(day)
        }
        return buckets.values
            .map { AdventureLogWeek(interval: $0.interval, days: $0.days.sorted { $0.date > $1.date }) }
            .sorted { $0.interval.start > $1.interval.start }
    }
}
