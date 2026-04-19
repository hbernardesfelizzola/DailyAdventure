//
//  ContentView.swift
//  DailyAdventure
//
//  Created by Henrique Bernardes on 09/02/26.
//

import SwiftUI

struct ContentView: View {
    var viewModel: QuestViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var isAnimating: Bool = false
    @State private var showMainQuestPreview: Bool = false
    @State private var showVictory = false
    @State private var showMainFloatingText = false
    
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
                        
                        Text(Date().formatted(date: .complete, time: .omitted))
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(Theme.titleDenim.opacity(0.8))
                            .padding(.horizontal, Theme.Spacing.medium)
                            .padding(.vertical, Theme.Spacing.small)
                            .background(Theme.titleDenim.opacity(0.1))
                            .clipShape(Capsule())
                            .glassEffectCapsuleIfAvailable()
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
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Theme.titleDenim)
                            
                            ZStack(alignment: .leading) {
                                if viewModel.todayAdventure.mainQuest.isEmpty {
                                    Text("What is your main quest today?")
                                        .font(.system(size: 16, weight: .regular))
                                        .foregroundColor(Theme.titleDenim.opacity(0.6))
                                        .padding(.leading, Theme.Spacing.extraSmall)
                                }
                                
                                HStack {
                                    TextField("", text: .init(
                                        get: { viewModel.todayAdventure.mainQuest },
                                        set: { viewModel.updateMainQuest($0) }
                                    ))
                                    .font(.system(size: 16, weight: .medium))
                                    .textFieldStyle(.plain)
                                    .padding(Theme.Spacing.small)
                                    .foregroundColor(Theme.titleDenim)
                                    .opacity(viewModel.isMainQuestCompleted() ? 0.7 : 1)
                                    .submitLabel(.done)
                                    .onSubmit {
                                        if !viewModel.todayAdventure.mainQuest.isEmpty && !viewModel.isMainQuestCompleted() {
                                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                                showMainQuestPreview = true
                                            }
                                        }
                                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                    }
                                    
                                    if !viewModel.todayAdventure.mainQuest.isEmpty && !showMainQuestPreview {
                                        Button(action: {
                                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                                showMainQuestPreview = true
                                            }
                                        }) {
                                            Image(systemName: "checkmark.circle")
                                                .foregroundColor(Theme.titleDenim.opacity(0.7))
                                                .font(.system(size: 18, weight: .semibold))
                                        }
                                        .padding(.trailing, Theme.Spacing.small)
                                    }
                                }
                            }
                            
                            // MARK: - Main Quest Preview
                            if showMainQuestPreview && !viewModel.todayAdventure.mainQuest.isEmpty {
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
                                                .font(.system(size: 18))
                                        }
                                        
                                        Text(viewModel.todayAdventure.mainQuest)
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(Theme.titleDenim)
                                            .strikethrough(viewModel.isMainQuestCompleted())
                                            .opacity(viewModel.isMainQuestCompleted() ? 0.6 : 1)
                                        
                                        Spacer()
                                        
                                        if !viewModel.isMainQuestCompleted() {
                                            Button(action: {
                                                viewModel.updateMainQuest("")
                                                withAnimation {
                                                    showMainQuestPreview = false
                                                }
                                            }) {
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundColor(Theme.titleDenim.opacity(0.6))
                                                    .font(.system(size: 16))
                                            }
                                        }
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
                            .font(.system(size: 16, weight: .semibold))
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
    ContentView(viewModel: QuestViewModel())
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    ContentView(viewModel: QuestViewModel())
        .preferredColorScheme(.dark)
}

#Preview("Light Mode") {
    ContentView(viewModel: QuestViewModel())
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    ContentView(viewModel: QuestViewModel())
        .preferredColorScheme(.dark)
}

