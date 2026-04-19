//
//  StorageService.swift
//  Meu App
//
//  Created by Henrique Bernardes on 24/02/26.
//


import Foundation

class StorageService {
    @MainActor static let shared = StorageService()
    private let todayKey = "todayAdventure"
    private let historyKey = "adventureHistory"
    
    func saveTodayAdventure(_ adventure: DailyAdventure) {
        if let encoded = try? JSONEncoder().encode(adventure) {
            UserDefaults.standard.set(encoded, forKey: todayKey)
        }
    }
    
    func loadTodayAdventure() -> DailyAdventure? {
        guard let saved = UserDefaults.standard.data(forKey: todayKey),
              let decoded = try? JSONDecoder().decode(DailyAdventure.self, from: saved) else {
            return nil
        }
        return decoded
    }
    
    func saveHistory(_ history: [DailyAdventure]) {
        if let encoded = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(encoded, forKey: historyKey)
        }
    }
    
    func loadHistory() -> [DailyAdventure] {
        guard let saved = UserDefaults.standard.data(forKey: historyKey),
              let decoded = try? JSONDecoder().decode([DailyAdventure].self, from: saved) else {
            return []
        }
        return decoded
    }
}
