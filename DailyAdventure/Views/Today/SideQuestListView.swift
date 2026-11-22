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
                        .font(.title3.weight(.bold))
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
                    Button(action: onAdd) {
                        Image(systemName: "plus")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(Theme.accent)
                            .frame(width: 44, height: 44)
                            .background(Theme.cardBackground, in: Circle())
                    }
                    .accessibilityLabel("Add quest")
                }
            }

            if quests.isEmpty {
                emptyState
            } else {
                SideQuestList(quests: quests, viewModel: viewModel, onQuestCompleted: onQuestCompleted)
                Text("Touch and hold a quest to delete it")
                    .font(.footnote)
                    .foregroundStyle(Theme.inkSecondary)
                    .padding(.horizontal, 4)
            }
        }
    }

    // MARK: - Vazio

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Small quests that complement your day.")
                .font(.subheadline)
                .foregroundStyle(Theme.inkSecondary)

            Button(action: onAdd) {
                Label("Add quest", systemImage: "plus")
                    .font(.headline)
                    .foregroundStyle(Theme.accent)
                    .frame(maxWidth: .infinity, minHeight: 52)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(Theme.accent.opacity(0.45), style: StrokeStyle(lineWidth: 1.5, dash: [6, 4]))
                    )
            }

            HStack {
                Text("Suggestions")
                    .font(.footnote.weight(.semibold))
                    .textCase(.uppercase)
                    .tracking(0.8)
                    .foregroundStyle(Theme.inkSecondary)
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
        .background(Theme.cardBackground, in: RoundedRectangle(cornerRadius: 20))
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
                    .font(.body)
                    .foregroundStyle(quest.isCompleted ? Theme.inkSecondary : Theme.ink)
                    .strikethrough(quest.isCompleted)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)

                if let category = quest.category {
                    Text(category.localizedName)
                        .font(.caption.weight(.semibold))
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

// MARK: - Componentes compartilhados

struct SuggestionChip: View {
    let title: String
    var dotColor: Color? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let dotColor {
                    Circle().fill(dotColor).frame(width: 8, height: 8)
                }
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(Theme.ink)
            }
            .padding(.horizontal, 14)
            .frame(minHeight: 44)
            .background(Theme.cardBackground, in: Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityHint("Adds this quest")
    }
}

struct ShuffleButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label("More", systemImage: "shuffle")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.accent)
                .frame(minHeight: 44)
        }
        .accessibilityLabel("Other suggestions")
    }
}

/// Layout que quebra linha quando os itens não cabem (para os chips).
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = arrange(proposal: proposal, subviews: subviews)
        let height = rows.last.map { $0.y + $0.height } ?? 0
        return CGSize(width: proposal.width ?? 0, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = arrange(proposal: ProposedViewSize(width: bounds.width, height: nil), subviews: subviews)
        for row in rows {
            var x = bounds.minX
            for index in row.indices {
                let size = subviews[index].sizeThatFits(.unspecified)
                subviews[index].place(
                    at: CGPoint(x: x, y: bounds.minY + row.y),
                    proposal: ProposedViewSize(width: min(size.width, bounds.width), height: size.height)
                )
                x += size.width + spacing
            }
        }
    }

    private struct Row { var indices: [Int] = []; var y: CGFloat = 0; var height: CGFloat = 0 }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> [Row] {
        let maxWidth = proposal.width ?? .infinity
        var rows: [Row] = []
        var current = Row()
        var x: CGFloat = 0
        var y: CGFloat = 0

        for index in subviews.indices {
            let size = subviews[index].sizeThatFits(.unspecified)
            if x > 0 && x + size.width > maxWidth {
                rows.append(current)
                y += current.height + spacing
                current = Row(y: y)
                x = 0
            }
            current.indices.append(index)
            current.height = max(current.height, size.height)
            x += size.width + spacing
        }
        if !current.indices.isEmpty { rows.append(current) }
        return rows
    }
}
