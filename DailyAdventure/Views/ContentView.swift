//
//  ContentView.swift
//  DailyAdventure
//
//  Created by Henrique Bernardes on 09/02/26.
//

import SwiftUI

/// Tela Today: header que acompanha o dia, aventura do dia em destaque e missões secundárias.
struct ContentView: View {
    var viewModel: QuestViewModel
    @State private var showVictory = false
    @State private var showAddQuest = false
    @State private var showCompletedQuests = false
    @State private var completionTick = 0

    private var adventure: DailyAdventure { viewModel.todayAdventure }
    private var phase: TodayPhase { TodayPhase(adventure: adventure) }

    var body: some View {
        ZStack {
            AnimatedBackgroundView()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    TodayHeaderView(
                        phase: phase,
                        completedCount: adventure.completedQuests.count,
                        totalCount: adventure.totalQuests,
                        progress: adventure.completionPercentage,
                        daysAdventured: viewModel.totalDaysAdventured
                    )

                    MainQuestCard(viewModel: viewModel, onCompleted: questCompleted)

                    if phase == .complete {
                        completedSection
                    } else {
                        SideQuestSection(
                            viewModel: viewModel,
                            onAdd: { showAddQuest = true },
                            onQuestCompleted: questCompleted
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 120)
                .animation(.spring(response: 0.45, dampingFraction: 0.85), value: phase)
            }
            .scrollEdgeEffectIfAvailable()
            .scrollDismissesKeyboard(.interactively)

            // MARK: - Victory Screen
            if showVictory {
                VictoryView()
                    .transition(.opacity)
                    .onTapGesture {
                        withAnimation { showVictory = false }
                    }
            }
        }
        .sensoryFeedback(.success, trigger: completionTick)
        .sheet(isPresented: $showAddQuest) {
            AddQuestSheet(viewModel: viewModel)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }

    // MARK: - Dia completo

    @ViewBuilder
    private var completedSection: some View {
        let sideQuests = adventure.sideQuests

        if !sideQuests.isEmpty {
            VStack(spacing: 10) {
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                        showCompletedQuests.toggle()
                    }
                } label: {
                    HStack {
                        Text("\(sideQuests.count) side quests completed")
                            .font(.rowText)
                            .foregroundStyle(Theme.ink)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .font(.supporting.weight(.semibold))
                            .foregroundStyle(Theme.inkSecondary)
                            .rotationEffect(.degrees(showCompletedQuests ? 180 : 0))
                    }
                    .padding(.horizontal, 18)
                    .frame(minHeight: 52)
                    .cardSurface(cornerRadius: Theme.Radius.list)
                }
                .buttonStyle(.plain)
                .accessibilityValue(showCompletedQuests ? Text("Expanded") : Text("Collapsed"))

                if showCompletedQuests {
                    SideQuestList(quests: sideQuests, viewModel: viewModel, onQuestCompleted: questCompleted)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }

        DayFeedbackCard(feedback: adventure.feedback) { feedback in
            viewModel.updateFeedback(feedback, for: adventure)
        }

        Button {
            showAddQuest = true
        } label: {
            Label("Add another quest", systemImage: "plus")
                .font(.supporting.weight(.semibold))
                .foregroundStyle(Theme.accent)
                .frame(maxWidth: .infinity, minHeight: 44)
        }
    }

    // MARK: - Conclusão

    private func questCompleted() {
        completionTick += 1
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            guard viewModel.todayAdventure.completionPercentage >= 1.0 else { return }
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                showVictory = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                withAnimation { showVictory = false }
            }
        }
    }
}

#Preview("Light Mode") {
    ContentView(viewModel: QuestViewModel.preview)
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    ContentView(viewModel: QuestViewModel.preview)
        .preferredColorScheme(.dark)
}
