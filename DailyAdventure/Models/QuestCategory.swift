//
//  QuestCategory.swift
//  DailyAdventure
//
//  Created by Henrique Bernardes on 19/04/26.
//


import SwiftUI

enum QuestCategory: String, CaseIterable, Codable {
    case work = "Work"
    case health = "Health"
    case relationship = "Relationship"
    
    var icon: String {
        switch self {
        case .work: return "briefcase.fill"
        case .health: return "figure.run"
        case .relationship: return "heart.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .work: return Theme.workColor
        case .health: return Theme.healthColor
        case .relationship: return Theme.relationshipColor
        }
    }

    /// Variante da cor para texto — `color` não tem contraste suficiente em fonte pequena.
    var labelColor: Color {
        switch self {
        case .work: return Color(light: "4652C8", dark: "A9B0F5")
        case .health: return Color(light: "2E7D57", dark: "7DD3AA")
        case .relationship: return Color(light: "B2405B", dark: "F0A0B2")
        }
    }

    var localizedName: LocalizedStringKey {
        LocalizedStringKey(rawValue)
    }
}