//
//  DayFeedbackStyle.swift
//  DailyAdventure
//
//  Ícone, cor e título de cada feedback do dia, compartilhados entre Today e Registro.
//

import SwiftUI

extension DayFeedback {
    /// Opções exibidas ao usuário, na ordem do seletor.
    static let selectable: [DayFeedback] = [.positive, .neutral, .negative]

    var icon: String? {
        switch self {
        case .positive: "hand.thumbsup.fill"
        case .neutral: "minus.circle.fill"
        case .negative: "hand.thumbsdown.fill"
        case .none: nil
        }
    }

    var tint: Color {
        switch self {
        case .positive: Theme.healthColor
        case .neutral: Theme.neutralOrange
        case .negative: Theme.healthRose
        case .none: Theme.inkSecondary
        }
    }

    var title: LocalizedStringKey {
        switch self {
        case .positive: "Great day!"
        case .neutral: "So-so"
        case .negative: "Tough day"
        case .none: ""
        }
    }
}
