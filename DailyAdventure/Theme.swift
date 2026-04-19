//
//  Theme.swift
//  DailyAdventure
//
//  Created by Henrique Bernardes on 26/03/26.
//


import SwiftUI

enum Theme {
    // MARK: - Colors
    static let backgroundVanilla = Color(hex: "FCF6B1")
    static let backgroundBlue = Color(hex: "011936")
    static let workBlue = Color(hex: "6874E8")
    static let healthRose = Color(hex: "DA627D")
    static let relationshipCeladon = Color(hex: "A9E5BB")
    static let healthGreen = Color(hex: "4CAF82")
    
    // MARK: - High Contrast
    static var isHighContrast: Bool {
        UserDefaults.standard.bool(forKey: "isHighContrast")
    }
    
    // MARK: - Adaptive Colors
    static var titleDenim: Color {
        if isHighContrast {
            return Color(UIColor { trait in
                trait.userInterfaceStyle == .dark ?
                UIColor.white :
                UIColor(hex: "1A3A5C")
            })
        }
        return Color(UIColor { trait in
            trait.userInterfaceStyle == .dark ?
            UIColor(hex: "8BB8D4") :
            UIColor(hex: "4A7BA7")
        })
    }
    
    static var background: Color {
        if isHighContrast {
            return Color(UIColor { trait in
                trait.userInterfaceStyle == .dark ?
                UIColor.black :
                UIColor.white
            })
        }
        return Color(UIColor { trait in
            trait.userInterfaceStyle == .dark ?
            UIColor(hex: "011936") :
            UIColor(hex: "FCF6B1")
        })
    }
    
    static var cardBackground: Color {
        if isHighContrast {
            return Color(UIColor { trait in
                trait.userInterfaceStyle == .dark ?
                UIColor(hex: "1A1A1A") :
                UIColor(hex: "F0F0F0")
            })
        }
        return Color(UIColor { trait in
            trait.userInterfaceStyle == .dark ?
            UIColor(hex: "0D2847") :
            UIColor.white
        })
    }
    
    // MARK: - Category Colors 
    static var workColor: Color {
        isHighContrast ? Color(hex: "3D4AE8") : workBlue
    }
    
    static var healthColor: Color {
        isHighContrast ? Color(hex: "2E8B57") : healthGreen
    }
    
    static var relationshipColor: Color {
        isHighContrast ? Color(hex: "C0392B") : healthRose
    }
    
    enum Category {
        static var work: Color { Theme.workColor }
        static var health: Color { Theme.healthColor }
        static var relationship: Color { Theme.relationshipColor }
    }
    
    enum Icons {
        static let mainQuest = "star.fill"
        static let sideQuest = "diamond.fill"
    }
    
    enum Spacing {
        static let small: CGFloat = 8
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
        static let extraSmall: CGFloat = 10
    }
    
    static let cornerRadius: CGFloat = 20
    static let cornerRadiusSmall: CGFloat = 12
    
    static func categoryColor(for category: QuestCategory) -> Color {
        switch category {
        case .work: return workColor
        case .health: return healthColor
        case .relationship: return relationshipColor
        }
    }
}

// MARK: - Color Extension para Hex
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        let rgb = Int(hex, radix: 16) ?? 0
        
        let red = Double((rgb >> 16) & 0xFF) / 255.0
        let green = Double((rgb >> 8) & 0xFF) / 255.0
        let blue = Double(rgb & 0xFF) / 255.0
        
        self.init(red: red, green: green, blue: blue)
    }
}

extension UIColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        let rgb = Int(hex, radix: 16) ?? 0
        
        let red = CGFloat((rgb >> 16) & 0xFF) / 255.0
        let green = CGFloat((rgb >> 8) & 0xFF) / 255.0
        let blue = CGFloat(rgb & 0xFF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
