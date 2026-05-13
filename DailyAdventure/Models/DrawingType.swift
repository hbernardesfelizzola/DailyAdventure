//
//  DrawingType.swift
//  DailyAdventure
//
//  Created by Henrique Bernardes on 26/03/26.
//

import Foundation

enum DrawingType: String, Codable {
    case castle = "Castle"

    static func random() -> DrawingType {
        .castle
    }
}
