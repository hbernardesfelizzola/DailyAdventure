//
//  PersistenceController.swift
//  DailyAdventure
//

import Foundation
import SwiftData

/// Ponto único de acesso ao ModelContainer, compartilhado entre o app e o widget extension via App Group.
///
/// Stage 1 desta migração: armazenamento local via App Group, sem CloudKit ainda.
/// Stage 2 (depois de validado): adicionar `cloudKitDatabase: .private("iCloud.com.hbfelizzola.DailyAdventure")`
/// à ModelConfiguration abaixo. A partir daí, o schema só aceita mudanças aditivas (novo atributo opcional) —
/// nunca renomear ou remover um campo já sincronizado.
enum PersistenceController {
    static let appGroupID = "group.com.hbfelizzola.DailyAdventure"

    static let shared: ModelContainer = makeContainer()

    private static func makeContainer() -> ModelContainer {
        let schema = Schema([DailyAdventure.self, Quest.self])
        let configuration = ModelConfiguration(
            schema: schema,
            groupContainer: .identifier(appGroupID)
        )
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Failed to create shared ModelContainer: \(error)")
        }
    }
}
