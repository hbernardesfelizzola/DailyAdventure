//
//  DayDetailSheet.swift
//  DailyAdventure
//
//  Detalhe de um dia do Registro. As quests ficam só para leitura; o feedback pode ser alterado.
//

import SwiftUI

struct DayDetailSheet: View {
    let adventure: DailyAdventure
    let onFeedback: (DayFeedback) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header

                if !adventure.mainQuest.isEmpty {
                    mainQuestCard
                }

                if !adventure.sideQuests.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        SectionLabel("Side Quests")
                        VStack(spacing: 0) {
                            ForEach(Array(orderedSideQuests.enumerated()), id: \.element.id) { index, quest in
                                ReadOnlyQuestRow(quest: quest)
                                if index < orderedSideQuests.count - 1 {
                                    Divider()
                                        .overlay(Theme.separator)
                                        .padding(.leading, 54)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                        .cardSurface(cornerRadius: Theme.Radius.list)
                    }
                }

                DayFeedbackCard(feedback: adventure.feedback, onSelect: onFeedback)
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .padding(.bottom, 32)
        }
        .background(Theme.cream)
    }

    // MARK: - Partes

    private var header: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                SectionLabel(verbatim: adventure.date.formatted(.dateTime.weekday(.wide).day().month(.wide)))
                Text(title)
                    .font(.screenTitleCompact)
                    .foregroundStyle(Theme.ink)
                    .accessibilityAddTraits(.isHeader)
                Text("\(adventure.completedQuests.count) of \(adventure.totalQuests) quests done")
                    .font(.supporting)
                    .foregroundStyle(Theme.inkSecondary)
            }
            Spacer(minLength: 0)
            CircleIconButton(systemImage: "xmark", accessibilityLabel: "Close") { dismiss() }
        }
    }

    private var title: LocalizedStringKey {
        switch adventure.completionLevel {
        case .complete: "Day complete."
        case .partial: "Quests done along the way."
        case .empty: "A quiet day."
        }
    }

    private var mainQuestCard: some View {
        let done = adventure.isMainQuestCompleted
        return HStack(spacing: 14) {
            ZStack {
                if done {
                    Circle().fill(Theme.goldComplete)
                    Image(systemName: "checkmark")
                        .font(.body.weight(.bold))
                        .foregroundStyle(Color(hex: "1D3550"))
                } else {
                    Circle().strokeBorder(Theme.accent.opacity(0.5), lineWidth: 2)
                }
            }
            .frame(width: 40, height: 40)
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text("Daily Adventure")
                    .font(.tag)
                    .textCase(.uppercase)
                    .tracking(0.8)
                    .foregroundStyle(done ? Theme.goldText : Theme.inkSecondary)
                Text(adventure.mainQuest)
                    .font(.questTitleSmall)
                    .foregroundStyle(Theme.ink)
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, 18)
        .padding(.horizontal, 20)
        .background(done ? Theme.goldSurface : Theme.cardBackground, in: RoundedRectangle(cornerRadius: Theme.Radius.card))
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(done ? .isSelected : [])
    }

    /// Mesma ordem do Registro antigo: trabalho → saúde → relacionamento.
    private var orderedSideQuests: [Quest] {
        adventure.sideQuests.sorted { lhs, rhs in
            let order = QuestCategory.allCases
            let l = lhs.category.flatMap { order.firstIndex(of: $0) } ?? order.count
            let r = rhs.category.flatMap { order.firstIndex(of: $0) } ?? order.count
            return l < r
        }
    }
}

/// Linha de quest só para leitura, no mesmo visual da lista da Today.
private struct ReadOnlyQuestRow: View {
    let quest: Quest

    private var tint: Color { quest.category?.color ?? Theme.accent }

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                if quest.isCompleted {
                    Circle().fill(tint)
                    Image(systemName: "checkmark")
                        .font(.caption.weight(.heavy))
                        .foregroundStyle(Theme.onAccent)
                } else {
                    Circle().strokeBorder(tint.opacity(0.6), lineWidth: 2)
                }
            }
            .frame(width: 26, height: 26)
            .accessibilityHidden(true)

            Text(quest.title)
                .font(.rowText)
                .foregroundStyle(quest.isCompleted ? Theme.ink : Theme.inkSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            if let category = quest.category {
                Text(category.localizedName)
                    .font(.tag)
                    .foregroundStyle(category.labelColor)
            }
        }
        .padding(.horizontal, 16)
        .frame(minHeight: 52)
        .accessibilityElement(children: .combine)
        .accessibilityValue(quest.isCompleted ? Text("Completed") : Text("Not completed"))
    }
}
