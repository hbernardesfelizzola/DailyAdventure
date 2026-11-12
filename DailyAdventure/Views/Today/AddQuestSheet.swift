//
//  AddQuestSheet.swift
//  DailyAdventure
//

import SwiftUI

/// Sheet único para criar uma missão secundária: título, categoria e sugestões da categoria.
struct AddQuestSheet: View {
    var viewModel: QuestViewModel
    @Environment(\.dismiss) private var dismiss

    @AppStorage("lastQuestCategory") private var lastCategory: String = QuestCategory.work.rawValue
    @State private var title: String = ""
    @State private var category: QuestCategory = .work
    @State private var suggestions: [String] = []
    @FocusState private var isFocused: Bool

    private var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    TextField("Quest name", text: $title)
                        .font(.questInput)
                        .foregroundStyle(Theme.ink)
                        .focused($isFocused)
                        .submitLabel(.done)
                        .onSubmit(add)
                        .padding(.horizontal, 16)
                        .frame(minHeight: 56)
                        .cardSurface(cornerRadius: Theme.Radius.control)
                        .overlay(
                            RoundedRectangle(cornerRadius: Theme.Radius.control)
                                .strokeBorder(category.color, lineWidth: isFocused ? 2 : 1)
                        )

                    VStack(alignment: .leading, spacing: 10) {
                        SectionLabel("Category")
                        FlowLayout(spacing: 8) {
                            ForEach(QuestCategory.allCases, id: \.self) { option in
                                CategoryChip(category: option, isSelected: option == category) {
                                    category = option
                                }
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            SectionLabel("Suggestions")
                            Spacer()
                            ShuffleButton(action: refreshSuggestions)
                        }
                        FlowLayout(spacing: 8) {
                            ForEach(suggestions, id: \.self) { suggestion in
                                SuggestionChip(title: suggestion) {
                                    title = suggestion
                                }
                                .accessibilityHint("Fills in the quest name")
                            }
                        }
                    }
                }
                .padding(20)
            }
            .scrollDismissesKeyboard(.interactively)
            .safeAreaInset(edge: .bottom) {
                Button("Add quest", action: add)
                    .buttonStyle(.primary)
                    .disabled(trimmedTitle.isEmpty)
                .padding(.horizontal, 20)
                .padding(.bottom, 12)
            }
            .background(Theme.cream)
            .navigationTitle("New quest")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
        .onAppear {
            category = QuestCategory(rawValue: lastCategory) ?? .work
            refreshSuggestions()
            isFocused = true
        }
        .onChange(of: category) { _, _ in refreshSuggestions() }
    }

    private func refreshSuggestions() {
        let existing = viewModel.todayAdventure.sideQuests.map(\.title)
        suggestions = SuggestionsService.shared.getSuggestions(for: category, count: 3, excluding: existing)
    }

    private func add() {
        guard !trimmedTitle.isEmpty else { return }
        viewModel.addSideQuest(category: category, title: trimmedTitle)
        lastCategory = category.rawValue
        dismiss()
    }
}

private struct CategoryChip: View {
    let category: QuestCategory
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: category.icon)
                    .foregroundStyle(isSelected ? category.labelColor : category.color)
                Text(category.localizedName)
                    .foregroundStyle(isSelected ? category.labelColor : Theme.ink)
            }
                .font(.subheadline.weight(isSelected ? .semibold : .regular))
                .padding(.horizontal, 14)
                .frame(minHeight: 44)
                .background(isSelected ? category.color.opacity(0.18) : Theme.cardBackground, in: Capsule())
                .overlay(Capsule().strokeBorder(isSelected ? category.labelColor : Theme.separator, lineWidth: 1.5))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
