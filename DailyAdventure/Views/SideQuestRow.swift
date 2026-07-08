//
//  SideQuestRow.swift
//  DailyAdventure
//
//  Created by Henrique Bernardes on 19/04/26.
//


import SwiftUI

struct SideQuestRow: View {
    let category: QuestCategory
    let quests: [Quest]
    let viewModel: QuestViewModel
    let onQuestCompleted: (() -> Void)? 
    @State private var newQuestText: String = ""
    @State private var suggestion: String = ""
    @FocusState private var isFocused: Bool
    
    init(category: QuestCategory, quests: [Quest], viewModel: QuestViewModel, onQuestCompleted: (() -> Void)? = nil) {
        self.category = category
        self.quests = quests
        self.viewModel = viewModel
        self.onQuestCompleted = onQuestCompleted
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.small) {
            // MARK: - Input para nova quest
            HStack(spacing: Theme.Spacing.medium) {
                ZStack {
                    Circle()
                        .fill(category.color.opacity(0.3))
                        .frame(width: 44, height: 44)

                    Image(systemName: category.icon)
                        .foregroundColor(category.color)
                        .font(.callout)
                }
                .glassEffectCircleIfAvailable()
                
                ZStack(alignment: .leading) {
                    if newQuestText.isEmpty && !isFocused {
                        HStack(spacing: 4) {
                            Image(systemName: "pencil")
                                .font(.caption)
                                .foregroundColor(category.color.opacity(0.6))
                            Text(suggestion)
                                .font(.body)
                                .foregroundColor(category.color.opacity(0.75))
                                .lineLimit(1)
                        }
                        .padding(.vertical, Theme.Spacing.small)
                        .padding(.horizontal, Theme.Spacing.small)
                    }

                    TextField("", text: $newQuestText)
                        .font(.body)
                        .textFieldStyle(.plain)
                        .foregroundColor(Theme.titleDenim)
                        .padding(.vertical, Theme.Spacing.small)
                        .padding(.horizontal, Theme.Spacing.small)
                        .focused($isFocused)
                        .submitLabel(.done)
                        .onSubmit {
                            submitQuest()
                            isFocused = false
                        }
                        .onChange(of: isFocused) { oldValue, newValue in
                            if newValue && newQuestText.isEmpty {
                                newQuestText = suggestion
                            }
                        }
                }
                .background(
                    RoundedRectangle(cornerRadius: Theme.cornerRadiusSmall)
                        .fill(isFocused ? category.color.opacity(0.08) : category.color.opacity(0.04))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.cornerRadiusSmall)
                        .stroke(
                            isFocused ? category.color : category.color.opacity(0.35),
                            lineWidth: isFocused ? 2 : 1
                        )
                )
                
                if isFocused && !newQuestText.isEmpty {
                    Button(action: {
                        newQuestText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(Theme.titleDenim.opacity(0.5))
                            .font(.body)
                            .frame(width: 44, height: 44)
                    }
                    .accessibilityLabel("Clear")
                    .padding(.trailing, Theme.Spacing.small)
                } else if !newQuestText.isEmpty {
                    Button(action: submitQuest) {
                        Image(systemName: "checkmark.circle")
                            .foregroundColor(Theme.titleDenim.opacity(0.7))
                            .font(.body)
                            .frame(width: 44, height: 44)
                    }
                    .accessibilityLabel("Submit quest")
                    .glassEffectIfAvailable(cornerRadius: 15)
                    .padding(.trailing, Theme.Spacing.small)
                } else {
                    Button(action: generateNewSuggestion) {
                        Image(systemName: "sparkles")
                            .foregroundColor(category.color)
                            .font(.callout)
                            .frame(width: 44, height: 44)
                    }
                    .accessibilityLabel("New suggestion")
                    .glassEffectIfAvailable(cornerRadius: 15)
                    .padding(.trailing, Theme.Spacing.small)
                }
            }
            .padding(.vertical, Theme.Spacing.small)
            
            if !quests.isEmpty {
                VStack(alignment: .leading, spacing: Theme.Spacing.small) {
                    ForEach(quests) { quest in
                        SideQuestItemRow(
                            quest: quest,
                            isCompleted: viewModel.isQuestCompleted(quest),
                            onComplete: {
                                let wasCompleted = viewModel.isQuestCompleted(quest)
                                viewModel.completeSideQuest(quest)
                                if !wasCompleted {
                                    onQuestCompleted?() // ✅ Notifica o pai
                                }
                            },
                            onDelete: {
                                viewModel.deleteSideQuest(quest)
                            }
                        )
                    }
                }
                .padding(.top, Theme.Spacing.small)
            }
        }
        .onAppear {
            suggestion = SuggestionsService.shared.getSuggestion(for: category, excluding: existingTitles)
        }
    }
    
    private func submitQuest() {
        if !newQuestText.isEmpty {
            let addedTitle = newQuestText
            viewModel.addSideQuest(category: category, title: addedTitle)
            newQuestText = ""
            suggestion = SuggestionsService.shared.getSuggestion(
                for: category,
                excluding: existingTitles + [addedTitle]
            )
            isFocused = false
        }
    }

    private func generateNewSuggestion() {
        suggestion = SuggestionsService.shared.getSuggestion(for: category, excluding: existingTitles)
    }

    private var existingTitles: [String] {
        quests.map(\.title)
    }
}

struct SideQuestItemRow: View {
    let quest: Quest
    let isCompleted: Bool
    let onComplete: () -> Void
    let onDelete: () -> Void
    @State private var showFloatingText = false
    
    var body: some View {
        ZStack {
            HStack(spacing: Theme.Spacing.small) {
                Button(action: {
                    let wasCompleted = isCompleted
                    onComplete()
                    if !wasCompleted {
                        withAnimation {
                            showFloatingText = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            showFloatingText = false
                        }
                    }
                }) {
                    Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(isCompleted ? quest.category?.color ?? Theme.titleDenim : Theme.titleDenim.opacity(0.5))
                        .font(.body)
                        .frame(minWidth: 44, minHeight: 44)
                }
                .accessibilityLabel(isCompleted ? "Mark quest incomplete" : "Mark quest complete")

                Text(quest.title)
                    .font(.subheadline)
                    .foregroundColor(Theme.titleDenim)
                    .strikethrough(isCompleted)
                    .opacity(isCompleted ? 0.6 : 1)
                
                Spacer()
                
                Button(action: onDelete) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Theme.titleDenim.opacity(0.5))
                        .font(.callout)
                        .frame(minWidth: 44, minHeight: 44)
                }
                .accessibilityLabel("Delete quest")
            }
            .padding(Theme.Spacing.small)
            .background((quest.category?.color ?? Theme.titleDenim).opacity(isCompleted ? 0.05 : 0.15))
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusSmall))
            .glassEffectIfAvailable(cornerRadius: Theme.cornerRadiusSmall)
            
            if showFloatingText {
                FloatingTextView(
                    text: "+1 Quest! ⚔️",
                    color: quest.category?.color ?? Theme.titleDenim
                )
                .transition(.opacity)
            }
        }
    }
}

#Preview {
    SideQuestRow(
        category: .work,
        quests: [
            Quest(title: "Go to office", category: .work),
            Quest(title: "Code review", category: .work)
        ],
        viewModel: QuestViewModel.preview
    )
    .padding()
    .background(Theme.background)
}
