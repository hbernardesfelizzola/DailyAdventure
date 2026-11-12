//
//  SideQuestListView.swift
//  DailyAdventure
//

import SwiftUI

/// Seção de missões secundárias: estado vazio com sugestões, ou lista única com todas as categorias.
struct SideQuestSection: View {
    var viewModel: QuestViewModel
    let onAdd: () -> Void
    let onQuestCompleted: () -> Void

    @State private var suggestions: [(category: QuestCategory, title: String)] = []

    private var quests: [Quest] { viewModel.todayAdventure.sideQuests }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 6) {
                    Text("Side Quests")
                        .font(.sectionTitle)
                        .foregroundStyle(Theme.ink)
                    if !quests.isEmpty {
                        Text("\(quests.filter(\.isCompleted).count)/\(quests.count)")
                            .font(.title3.weight(.medium))
                            .foregroundStyle(Theme.inkSecondary)
                    }
                }
                .accessibilityElement(children: .combine)
                .accessibilityAddTraits(.isHeader)

                Spacer()

                if !quests.isEmpty {
                    CircleIconButton(systemImage: "plus", accessibilityLabel: "Add quest", action: onAdd)
                }
            }

            if quests.isEmpty {
                emptyState
            } else {
                SideQuestList(quests: quests, viewModel: viewModel, onQuestCompleted: onQuestCompleted)
                Text("Touch and hold a quest to delete it")
                    .font(.label.weight(.regular))
                    .foregroundStyle(Theme.inkSecondary)
                    .padding(.horizontal, 4)
            }
        }
    }

    // MARK: - Vazio

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Small quests that complement your day.")
                .font(.supporting)
                .foregroundStyle(Theme.inkSecondary)

            Button(action: onAdd) {
                Label("Add quest", systemImage: "plus")
            }
            .buttonStyle(.dashed)

            HStack {
                SectionLabel("Suggestions")
                Spacer()
                ShuffleButton(action: refreshSuggestions)
            }
            .padding(.top, 4)

            FlowLayout(spacing: 8) {
                ForEach(suggestions, id: \.title) { suggestion in
                    SuggestionChip(title: suggestion.title, dotColor: suggestion.category.color) {
                        viewModel.addSideQuest(category: suggestion.category, title: suggestion.title)
                    }
                }
            }
        }
        .onAppear {
            if suggestions.isEmpty { refreshSuggestions() }
        }
    }

    /// Uma sugestão por categoria, para mostrar a variedade logo de cara.
    private func refreshSuggestions() {
        withAnimation(.easeInOut(duration: 0.2)) {
            suggestions = QuestCategory.allCases.map { category in
                (category, SuggestionsService.shared.getSuggestion(for: category))
            }
        }
    }
}

/// Lista compacta: pendentes primeiro, concluídas descem para o fim.
struct SideQuestList: View {
    let quests: [Quest]
    var viewModel: QuestViewModel
    let onQuestCompleted: () -> Void

    private var ordered: [Quest] {
        quests.filter { !$0.isCompleted } + quests.filter(\.isCompleted)
    }

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(ordered.enumerated()), id: \.element.id) { index, quest in
                SideQuestListRow(quest: quest) {
                    let wasCompleted = quest.isCompleted
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                        viewModel.completeSideQuest(quest)
                    }
                    if !wasCompleted { onQuestCompleted() }
                } onDelete: {
                    withAnimation { viewModel.deleteSideQuest(quest) }
                }

                if index < ordered.count - 1 {
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

private struct SideQuestListRow: View {
    let quest: Quest
    let onToggle: () -> Void
    let onDelete: () -> Void

    private var tint: Color { quest.category?.color ?? Theme.accent }

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 12) {
                ZStack {
                    if quest.isCompleted {
                        Circle().fill(tint)
                        Image(systemName: "checkmark")
                            .font(.caption.weight(.heavy))
                            .foregroundStyle(Theme.onAccent)
                    } else {
                        Circle().strokeBorder(tint, lineWidth: 2)
                    }
                }
                .frame(width: 26, height: 26)

                Text(quest.title)
                    .font(.rowText)
                    .foregroundStyle(quest.isCompleted ? Theme.inkSecondary : Theme.ink)
                    .strikethrough(quest.isCompleted)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)

                if let category = quest.category {
                    Text(category.localizedName)
                        .font(.tag)
                        .foregroundStyle(quest.isCompleted ? Theme.inkSecondary : category.labelColor)
                }
            }
            .padding(.horizontal, 16)
            .frame(minHeight: 52)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button("Delete", systemImage: "trash", role: .destructive, action: onDelete)
        }
        .accessibilityAddTraits(quest.isCompleted ? .isSelected : [])
        .accessibilityHint(quest.isCompleted ? Text("Mark quest incomplete") : Text("Mark quest complete"))
        .accessibilityAction(named: "Delete quest", onDelete)
    }
}
