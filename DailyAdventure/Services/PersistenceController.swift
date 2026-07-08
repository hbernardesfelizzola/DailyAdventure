//
//  PersistenceController.swift
//  DailyAdventure
//

import Foundation
import SwiftData

/// Ponto único de acesso ao ModelContainer, compartilhado entre o app e o widget extension via App Group,
/// com sincronização CloudKit (banco privado do usuário) — o schema a partir daqui só aceita mudanças
/// aditivas (novo atributo opcional/relação opcional); nunca renomear ou remover um campo já sincronizado.
enum PersistenceController {
    static let appGroupID = "group.com.hbfelizzola.DailyAdventure"
    static let cloudKitContainerID = "iCloud.com.hbfelizzola.DailyAdventure"

    static let shared: ModelContainer = makeContainer()

    private static func makeContainer() -> ModelContainer {
        let schema = Schema([DailyAdventure.self, Quest.self])
        let configuration = ModelConfiguration(
            schema: schema,
            groupContainer: .identifier(appGroupID),
            cloudKitDatabase: .private(cloudKitContainerID)
        )
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Failed to create shared ModelContainer: \(error)")
        }
    }
}
