//
//  LegacyDataMigrator.swift
//  DailyAdventure
//

import Foundation
import SwiftData

/// Migração única e não-destrutiva dos dados antigos (UserDefaults + JSON) para o SwiftData.
/// Segue o mesmo padrão do antigo `StorageService.migrateFromStandardIfNeeded()`: guardada por flag,
/// nunca apaga os dados de origem — eles ficam como rede de segurança.
@MainActor
enum LegacyDataMigrator {
    private static let migrationFlagKey = "didMigrateToSwiftData_v1"
    private static let todayKey = "todayAdventure"
    private static let historyKey = "adventureHistory"

    static func migrateIfNeeded(context: ModelContext) {
        let defaults = UserDefaults(suiteName: PersistenceController.appGroupID) ?? .standard
        guard !defaults.bool(forKey: migrationFlagKey) else { return }

        if let data = defaults.data(forKey: todayKey),
           let legacy = try? JSONDecoder().decode(LegacyDailyAdventure.self, from: data) {
            insert(legacy, into: context)
        }
        if let data = defaults.data(forKey: historyKey),
           let legacyHistory = try? JSONDecoder().decode([LegacyDailyAdventure].self, from: data) {
            for day in legacyHistory {
                insert(day, into: context)
            }
        }

        try? context.save()
        defaults.set(true, forKey: migrationFlagKey)
    }

    private static func insert(_ legacy: LegacyDailyAdventure, into context: ModelContext) {
        let sideQuests = legacy.sideQuests.map {
            Quest(id: $0.id, title: $0.title, category: $0.category, isMainQuest: $0.isMainQuest)
        }
        let completedQuests = legacy.completedQuests.map {
            Quest(id: $0.id, title: $0.title, category: $0.category, isMainQuest: $0.isMainQuest)
        }
        let adventure = DailyAdventure(
            id: legacy.id,
            date: legacy.date,
            mainQuest: legacy.mainQuest,
            sideQuests: sideQuests,
            completedQuests: completedQuests,
            drawingType: legacy.drawingType,
            feedback: legacy.feedback
        )
        context.insert(adventure)
    }

    // Espelham exatamente o formato Codable antigo — mantidos privados aqui só para a importação única.
    private struct LegacyDailyAdventure: Codable {
        let id: UUID
        var date: Date
        var mainQuest: String
        var sideQuests: [LegacyQuest]
        var completedQuests: [LegacyQuest]
        var drawingType: DrawingType
        var feedback: DayFeedback
    }

    private struct LegacyQuest: Codable {
        let id: UUID
        var title: String
        var category: QuestCategory?
        var isMainQuest: Bool = false
    }
}
