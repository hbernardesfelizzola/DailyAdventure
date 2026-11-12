//
//  MainQuestCard.swift
//  DailyAdventure
//

import SwiftUI

/// Aventura do dia: campo de texto enquanto vazia, card de destaque depois de definida.
struct MainQuestCard: View {
    var viewModel: QuestViewModel
    let onCompleted: () -> Void

    /// Rascunho local — só vai pro ViewModel quando o usuário pressionar done.
    @State private var draft: String = ""
    @FocusState private var isFocused: Bool

    private var quest: String { viewModel.todayAdventure.mainQuest }
    private var isCompleted: Bool { viewModel.isMainQuestCompleted() }

    var body: some View {
        Group {
            if quest.isEmpty {
                inputCard
            } else if isCompleted {
                completedCard
            } else {
                heroCard
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: quest.isEmpty)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isCompleted)
    }

    // MARK: - Vazio

    private var inputCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            label(color: Theme.accent)

            TextField("Write your main quest…", text: $draft, axis: .vertical)
                .font(.system(.title3, design: .serif))
                .foregroundStyle(Theme.ink)
                .focused($isFocused)
                .submitLabel(.done)
                .onChange(of: draft) { _, newValue in
                    // Com axis: .vertical o return vira quebra de linha — tratamos como submit.
                    if newValue.contains("\n") {
                        draft = newValue.replacingOccurrences(of: "\n", with: "")
                        submit()
                    }
                }
                .onSubmit(submit)
                .padding(16)
                .frame(minHeight: 56)
                .background(Theme.surfaceSecondary, in: RoundedRectangle(cornerRadius: 14))
                .accessibilityLabel("Main quest")

            Text("One thing that would make today worth it.")
                .font(.subheadline)
                .foregroundStyle(Theme.inkSecondary)
        }
        .padding(20)
        .background(Theme.cardBackground, in: RoundedRectangle(cornerRadius: 24))
        .shadow(color: Theme.ink.opacity(0.06), radius: 12, y: 6)
        .transition(.opacity.combined(with: .scale(scale: 0.98)))
    }

    // MARK: - Definida

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            label(color: Theme.onAccent.opacity(0.8))

            HStack(alignment: .center, spacing: 14) {
                Text(quest)
                    .font(.system(.title2, design: .serif, weight: .semibold))
                    .foregroundStyle(Theme.onAccent)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Button(action: toggle) {
                    Image(systemName: "checkmark")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(Theme.onAccent.opacity(0.55))
                        .frame(width: 52, height: 52)
                        .overlay(Circle().stroke(Theme.onAccent, lineWidth: 2.5))
                }
                .accessibilityLabel("Mark main quest complete")
            }
        }
        .padding(20)
        .background(Theme.accent, in: RoundedRectangle(cornerRadius: 24))
        .shadow(color: Theme.accent.opacity(0.3), radius: 12, y: 6)
        .contextMenu { editMenu }
        .accessibilityAction(named: "Edit main quest", edit)
        .accessibilityAction(named: "Remove main quest", remove)
        .transition(.opacity.combined(with: .scale(scale: 0.98)))
    }

    private var completedCard: some View {
        HStack(spacing: 14) {
            Button(action: toggle) {
                Image(systemName: "checkmark")
                    .font(.body.weight(.bold))
                    // Fixo escuro: o dourado é claro nos dois modos.
                    .foregroundStyle(Color(hex: "1D3550"))
                    .frame(width: 44, height: 44)
                    .background(Theme.goldComplete, in: Circle())
            }
            .accessibilityLabel("Mark main quest incomplete")

            VStack(alignment: .leading, spacing: 2) {
                Text("Daily Adventure")
                    .font(.caption.weight(.bold))
                    .textCase(.uppercase)
                    .tracking(0.8)
                    .foregroundStyle(Theme.goldText)
                Text(quest)
                    .font(.system(.title3, design: .serif, weight: .semibold))
                    .foregroundStyle(Theme.ink)
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, 18)
        .padding(.horizontal, 20)
        .background(Theme.goldSurface, in: RoundedRectangle(cornerRadius: 24))
        .contextMenu { editMenu }
        .accessibilityAction(named: "Edit main quest", edit)
        .accessibilityAction(named: "Remove main quest", remove)
        .transition(.opacity.combined(with: .scale(scale: 0.98)))
    }

    // MARK: - Partes

    private func label(color: Color) -> some View {
        Label("Daily Adventure", systemImage: Theme.Icons.mainQuest)
            .font(.footnote.weight(.bold))
            .textCase(.uppercase)
            .tracking(0.8)
            .foregroundStyle(color)
    }

    @ViewBuilder
    private var editMenu: some View {
        Button("Edit", systemImage: "pencil", action: edit)
        Button("Remove", systemImage: "trash", role: .destructive, action: remove)
    }

    // MARK: - Ações

    private func submit() {
        let trimmed = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        viewModel.updateMainQuest(trimmed)
        draft = ""
        isFocused = false
    }

    private func toggle() {
        let wasCompleted = isCompleted
        viewModel.toggleMainQuest()
        if !wasCompleted { onCompleted() }
    }

    private func edit() {
        draft = quest
        clearQuest()
        isFocused = true
    }

    private func remove() {
        draft = ""
        clearQuest()
    }

    private func clearQuest() {
        if isCompleted { viewModel.toggleMainQuest() }
        viewModel.updateMainQuest("")
    }
}
