//
//  DailyAdventure.swift
//  DailyAdventure
//
//  Created by Henrique Bernardes on 19/04/26.
//

import Foundation
import SwiftData

enum DayCompletionLevel {
    case empty    // nenhuma quest completada
    case partial  // ≥1 quest completada, mas não todas
    case complete // 100% das quests completadas
}

enum DayFeedback: String, Codable {
    case positive = "positive"
    case neutral = "neutral"
    case negative = "negative"
    case none = "none"
}

@Model
final class DailyAdventure {
    var id: UUID = UUID()
    var date: Date = Date()
    /// Chave normalizada (início do dia) usada para identificar unicamente o dia no armazenamento.
    var calendarDay: Date = Calendar.current.startOfDay(for: Date())
    var mainQuest: String = ""
    var isMainQuestCompleted: Bool = false
    var mainQuestCompletedAt: Date?
    var drawingType: DrawingType = DrawingType.random()
    var feedback: DayFeedback = DayFeedback.none

    @Relationship(deleteRule: .cascade, inverse: \Quest.day)
    var quests: [Quest]? = []

    /// Inicializador único, compatível com o antigo formato de duas listas (sideQuests/completedQuests) —
    /// usado por testes, MockDataSeeder e pela migração de dados legados, além do código de produção.
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        mainQuest: String = "",
        sideQuests: [Quest] = [],
        completedQuests: [Quest] = [],
        drawingType: DrawingType = .random(),
        feedback: DayFeedback = .none
    ) {
        self.id = id
        self.date = date
        self.calendarDay = Calendar.current.startOfDay(for: date)
        self.mainQuest = mainQuest
        self.drawingType = drawingType
        self.feedback = feedback

        let completedSideIDs = Set(completedQuests.filter { !$0.isMainQuest }.map(\.id))
        for quest in sideQuests {
            quest.isCompleted = completedSideIDs.contains(quest.id)
        }
        self.quests = sideQuests
        self.isMainQuestCompleted = completedQuests.contains { $0.isMainQuest }
    }

    // MARK: - Propriedades computadas (compatibilidade com Views/testes existentes)

    var sideQuests: [Quest] {
        (quests ?? []).sorted { $0.createdAt < $1.createdAt }
    }

    /// Reconstrói a lista de quests completas, incluindo um wrapper sintético e transiente para a main quest.
    var completedQuests: [Quest] {
        var result: [Quest] = []
        if isMainQuestCompleted {
            result.append(Quest(title: mainQuest, category: nil, isMainQuest: true))
        }
        result.append(contentsOf: sideQuests.filter(\.isCompleted))
        return result
    }

    var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }

    var totalQuests: Int {
        let mainCount = mainQuest.isEmpty ? 0 : 1
        return mainCount + sideQuests.count
    }

    var completionPercentage: Double {
        guard totalQuests > 0 else { return 0 }
        return Double(completedQuests.count) / Double(totalQuests)
    }

    var hasAnyQuest: Bool {
        !mainQuest.isEmpty || !sideQuests.isEmpty
    }

    var completionLevel: DayCompletionLevel {
        if completedQuests.isEmpty { return .empty }
        if completionPercentage >= 1.0 { return .complete }
        return .partial
    }
}
