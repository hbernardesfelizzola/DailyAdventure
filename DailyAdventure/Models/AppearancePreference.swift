//
//  AppearancePreference.swift
//  DailyAdventure
//

import SwiftUI

/// Tema escolhido pelo usuário. O padrão segue o sistema.
enum AppearancePreference: String, CaseIterable, Identifiable {
    case system, light, dark

    static let key = "appearance"
    /// Chave do antigo toggle "Modo escuro" (Bool), substituída por `key`.
    private static let legacyKey = "isDarkMode"

    var id: String { rawValue }

    /// `nil` deixa o app seguir o sistema.
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }

    var title: LocalizedStringKey {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }

    /// Converte o toggle antigo uma única vez. Quem tinha o modo escuro ligado continua no escuro;
    /// o resto passa a seguir o sistema (o "desligado" antigo era só o padrão, não uma escolha de tema claro).
    static func migrateLegacyIfNeeded(defaults: UserDefaults = .standard) {
        guard defaults.object(forKey: legacyKey) != nil else { return }
        if defaults.string(forKey: key) == nil, defaults.bool(forKey: legacyKey) {
            defaults.set(AppearancePreference.dark.rawValue, forKey: key)
        }
        defaults.removeObject(forKey: legacyKey)
    }
}
