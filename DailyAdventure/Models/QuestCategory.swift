//
//  QuestCategory.swift
//  DailyAdventure
//
//  Created by Henrique Bernardes on 19/04/26.
//


import SwiftUI

@MainActor
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
}