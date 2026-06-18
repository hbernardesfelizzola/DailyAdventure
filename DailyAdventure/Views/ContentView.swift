//
//  ContentView.swift
//  DailyAdventure
//
//  Created by Henrique Bernardes on 09/02/26.
//

import SwiftUI

struct ContentView: View {
    var viewModel: QuestViewModel
    var weatherProvider: WeatherProvider
    @Environment(\.colorScheme) var colorScheme
    @State private var isAnimating: Bool = false
    @State private var showVictory = false
    @State private var showMainFloatingText = false
    /// Rascunho local — só vai pro ViewModel quando o usuário pressionar done.
    @State private var mainQuestDraft: String = ""

    private var showMainQuestCard: Bool {
        !viewModel.todayAdventure.mainQuest.isEmpty
    }
    
    var body: some View {
        ZStack {
            AnimatedBackgroundView()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: Theme.Spacing.large) {
                    // MARK: - Header
                    VStack(spacing: Theme.Spacing.medium) {
                        Image("DailyTitleClipped")
                             .resizable()
                             .scaledToFit()
                             .frame(height: 120)
                             .colorInvert()
                             .opacity(colorScheme == .dark ? 0.9 : 0)
                             .overlay(
                                 Image("DailyTitleClipped")
                                     .resizable()
                                     .scaledToFit()
                                     .frame(height: 120)
                                     .opacity(colorScheme == .dark ? 0 : 1)
                             )
                             .padding(.top, Theme.Spacing.medium)
                             .scaleEffect(isAnimating ? 1 : 0.95)
                             .opacity(isAnimating ? 1 : 0.8)
                        
                        HStack(spacing: Theme.Spacing.small) {
                            Text(Date().formatted(date: .complete, time: .omitted))
                                .font(.caption)
                                .foregroundColor(Theme.titleDenim.opacity(0.8))
                                .padding(.horizontal, Theme.Spacing.medium)
                                .padding(.vertical, Theme.Spacing.small)
                                .background(Theme.titleDenim.opacity(0.1))
                                .clipShape(Capsule())
                                .glassEffectCapsuleIfAvailable()

                            if let symbol = weatherProvider.conditionSymbolName,
                               let temp = weatherProvider.temperatureString {
                                HStack(spacing: 4) {
                                    Image(systemName: symbol)
                                        .font(.caption)
                                    Text(temp)
                                        .font(.caption)
                                }
                                .foregroundColor(Theme.titleDenim.opacity(0.8))
                                .padding(.horizontal, 10)
                                .padding(.vertical, Theme.Spacing.small)
                                .background(Theme.titleDenim.opacity(0.1))
                                .clipShape(Capsule())
                                .glassEffectCapsuleIfAvailable()
                                .transition(.scale.combined(with: .opacity))
                            }
                        }
                        .scaleEffect(isAnimating ? 1 : 0.95)
                        .opacity(isAnimating ? 1 : 0.8)
                    }
                    
                    // MARK: - Main Quest Card
                    HStack(spacing: 0) {
                        // Barra lateral colorida
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Theme.titleDenim)
                            .frame(width: 4)
                            .padding(.vertical, Theme.Spacing.small)
                        
                        VStack(alignment: .leading, spacing: Theme.Spacing.small) {
                            // Label igual ao Side Quests
                            Label("Daily Adventure", systemImage: Theme.Icons.mainQuest)
                                .font(.headline)
                                .foregroundColor(Theme.titleDenim)
                            
                            // TextField: visível enquanto não há quest salva no ViewModel
                            if !showMainQuestCard {
                                ZStack(alignment: .leading) {
                                    if mainQuestDraft.isEmpty {
                                        Text("What is your main quest today?")
                                            .font(.body)
                                            .foregroundColor(Theme.titleDenim.opacity(0.6))
                                            .padding(.leading, Theme.Spacing.extraSmall)
                                    }

                                    TextField("", text: $mainQuestDraft)
                                        .font(.body)
                                        .textFieldStyle(.plain)
                                        .padding(Theme.Spacing.small)
                                        .foregroundColor(Theme.titleDenim)
                                        .submitLabel(.done)
                                        .onSubmit {
                                            let trimmed = mainQuestDraft.trimmingCharacters(in: .whitespaces)
                                            if !trimmed.isEmpty {
                                                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                                    viewModel.updateMainQuest(trimmed)
                                                }
                                            }
                                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                        }
                                }
                                .transition(.opacity.combined(with: .move(edge: .top)))
                            }

                            // MARK: - Main Quest Card (visível após submit, persiste entre abas)
                            if showMainQuestCard {
                                ZStack {
                                    HStack(spacing: Theme.Spacing.small) {
                                        Button(action: {
                                            let wasCompleted = viewModel.isMainQuestCompleted()
                                            viewModel.toggleMainQuest()
                                            if !wasCompleted {
                                                showMainFloatingText = true
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                                    showMainFloatingText = false
                                                }
                                                checkVictory()
                                            }
                                        }) {
                                            Image(systemName: viewModel.isMainQuestCompleted() ? "checkmark.circle.fill" : "circle")
                                                .foregroundColor(viewModel.isMainQuestCompleted() ? Theme.titleDenim : Theme.titleDenim.opacity(0.5))
                                                .font(.body)
                                                .frame(minWidth: 44, minHeight: 44)
                                        }
                                        .accessibilityLabel(viewModel.isMainQuestCompleted() ? "Mark main quest incomplete" : "Mark main quest complete")

                                        Text(viewModel.todayAdventure.mainQuest)
                                            .font(.body)
                                            .foregroundColor(Theme.titleDenim)
                                            .strikethrough(viewModel.isMainQuestCompleted())
                                            .opacity(viewModel.isMainQuestCompleted() ? 0.6 : 1)

                                        Spacer()

                                        // Xmark sempre visível — limpa e volta ao TextField
                                        Button(action: {
                                            if viewModel.isMainQuestCompleted() {
                                                viewModel.toggleMainQuest()
                                            }
                                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                                viewModel.updateMainQuest("")
                                                mainQuestDraft = ""
                                            }
                                        }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(Theme.titleDenim.opacity(0.6))
                                                .font(.callout)
                                                .frame(minWidth: 44, minHeight: 44)
                                        }
                                        .accessibilityLabel("Remove main quest")
                                    }
                                    .padding(Theme.Spacing.medium)
                                    .background(Theme.titleDenim.opacity(viewModel.isMainQuestCompleted() ? 0.05 : 0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusSmall))
                                    .glassEffectIfAvailable(cornerRadius: Theme.cornerRadiusSmall)
                                    .transition(.opacity.combined(with: .move(edge: .bottom)))

                                    if showMainFloatingText {
                                        FloatingTextView(
                                            text: "+1 Quest! ⚔️",
                                            color: Theme.titleDenim
                                        )
                                        .transition(.opacity)
                                    }
                                }
                            }
                        }
                        .padding(Theme.Spacing.medium)
                    }
                    .background(
                        LinearGradient(
                            colors: [
                                Theme.titleDenim.opacity(0.15),
                                Theme.titleDenim.opacity(0.05)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
                    .glassEffectIfAvailable()
                    .padding(.horizontal, Theme.Spacing.medium)
                    .scaleEffect(isAnimating ? 1 : 0.95)
                    .opacity(isAnimating ? 1 : 0.8)
                    
                    // MARK: - Side Quests Card
                    VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
                        Label("Side Quests", systemImage: Theme.Icons.sideQuest)
                            .font(.headline)
                            .foregroundColor(Theme.titleDenim)
                        
                        VStack(spacing: Theme.Spacing.medium) {
                            ForEach(QuestCategory.allCases, id: \.self) { category in
                                SideQuestRow(
                                    category: category,
                                    quests: viewModel.getSideQuests(for: category),
                                    viewModel: viewModel,
                                    onQuestCompleted: {
                                        checkVictory()
                                    }
                                )
                            }
                        }
                    }
                    .padding(Theme.Spacing.medium)
                    .background(
                        LinearGradient(
                            colors: [
                                Theme.titleDenim.opacity(0.1),
                                Theme.titleDenim.opacity(0.03)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
                    .glassEffectIfAvailable()
                    .padding(.horizontal, Theme.Spacing.medium)
                    .scaleEffect(isAnimating ? 1 : 0.95)
                    .opacity(isAnimating ? 1 : 0.8)
                    
                    Spacer()
                        .frame(height: 100)
                }
            }
            .frame(maxWidth: .infinity)
            .scrollEdgeEffectIfAvailable()
            // MARK: - Victory Screen
            if showVictory {
                VictoryView()
                    .transition(.opacity)
                    .onTapGesture {
                        withAnimation {
                            showVictory = false
                        }
                    }
            }
        }
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                isAnimating = true
            }
        }
    }
    
    private func checkVictory() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if viewModel.todayAdventure.completionPercentage >= 1.0 {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    showVictory = true
                }
                
                // Esconde após 4 segundos
                DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                    withAnimation {
                        showVictory = false
                    }
                }
            }
        }
    }
}

#Preview("Light Mode") {
    ContentView(viewModel: QuestViewModel(), weatherProvider: WeatherProvider())
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    ContentView(viewModel: QuestViewModel(), weatherProvider: WeatherProvider())
        .preferredColorScheme(.dark)
}

#Preview("Light Mode") {
    ContentView(viewModel: QuestViewModel(), weatherProvider: WeatherProvider())
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    ContentView(viewModel: QuestViewModel(), weatherProvider: WeatherProvider())
        .preferredColorScheme(.dark)
}

