//
//  StorageService.swift
//  Meu App
//
//  Created by Henrique Bernardes on 24/02/26.
//


import Foundation

class StorageService {
    @MainActor static let shared = StorageService()

    static let appGroupID = "group.com.hbfelizzola.DailyAdventure"

    private var defaults: UserDefaults {
        UserDefaults(suiteName: StorageService.appGroupID) ?? .standard
    }

    private let todayKey = "todayAdventure"
    private let historyKey = "adventureHistory"

    init() {
        migrateFromStandardIfNeeded()
    }

    // Copia dados existentes de UserDefaults.standard para o App Group na primeira execução.
    private func migrateFromStandardIfNeeded() {
        let migrationKey = "didMigrateToAppGroup_v1"
        guard let appGroupDefaults = UserDefaults(suiteName: StorageService.appGroupID),
              !appGroupDefaults.bool(forKey: migrationKey) else { return }

        if let data = UserDefaults.standard.data(forKey: todayKey) {
            appGroupDefaults.set(data, forKey: todayKey)
        }
        if let data = UserDefaults.standard.data(forKey: historyKey) {
            appGroupDefaults.set(data, forKey: historyKey)
        }
        appGroupDefaults.set(true, forKey: migrationKey)
    }

    func saveTodayAdventure(_ adventure: DailyAdventure) {
        if let encoded = try? JSONEncoder().encode(adventure) {
            defaults.set(encoded, forKey: todayKey)
        }
    }

    func loadTodayAdventure() -> DailyAdventure? {
        guard let saved = defaults.data(forKey: todayKey),
              let decoded = try? JSONDecoder().decode(DailyAdventure.self, from: saved) else {
            return nil
        }
        return decoded
    }

    func saveHistory(_ history: [DailyAdventure]) {
        if let encoded = try? JSONEncoder().encode(history) {
            defaults.set(encoded, forKey: historyKey)
        }
    }

    func loadHistory() -> [DailyAdventure] {
        guard let saved = defaults.data(forKey: historyKey),
              let decoded = try? JSONDecoder().decode([DailyAdventure].self, from: saved) else {
            return []
        }
        return decoded
    }
}
