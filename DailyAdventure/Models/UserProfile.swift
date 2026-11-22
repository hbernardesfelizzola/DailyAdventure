//
//  UserProfile.swift
//  DailyAdventure
//

import Foundation

/// Dados do usuário guardados em `UserDefaults` (via `@AppStorage`).
enum UserProfile {
    /// Nome usado na saudação da Today. Vazio = saudação sem nome.
    static let nameKey = "userName"
    static let maxNameLength = 30

    /// Normaliza o que o usuário digitou: sem espaços nas pontas e com limite de tamanho.
    static func sanitized(_ name: String) -> String {
        String(name.trimmingCharacters(in: .whitespacesAndNewlines).prefix(maxNameLength))
    }
}
