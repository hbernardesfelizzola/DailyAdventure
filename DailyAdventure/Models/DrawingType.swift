//
//  DrawingType.swift
//  DailyAdventure
//
//  Created by Henrique Bernardes on 19/04/26.
//


import SwiftUI

enum DrawingType: String, Codable, CaseIterable {
    case castle = "Castle"
    
    var description: String {
        switch self {
        case .castle:
            return "🏰 Castle"
        }
    }
    
    static func random() -> DrawingType {
        .castle
    }
}
