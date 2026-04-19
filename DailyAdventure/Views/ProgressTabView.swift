//
//  ProgressTabView.swift
//  DailyAdventure
//
//  Created by Henrique Bernardes on 19/04/26.
//


import SwiftUI

struct ProgressTabView: View {
    var viewModel: QuestViewModel
    
    var missingCategories: [QuestCategory] {
        QuestCategory.allCases.filter { category in
            viewModel.todayAdventure.sideQuests.filter { $0.category == category }.isEmpty
        }
    }
    
    var isMissingMainQuest: Bool {
        viewModel.todayAdventure.mainQuest.isEmpty
    }
    
    var body: some View {
        ZStack {
            AnimatedBackgroundView()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: Theme.Spacing.large) {
                    // MARK: - Header
                    VStack(spacing: Theme.Spacing.small) {
                        HStack(spacing: Theme.Spacing.medium) {
                            Text("🏰")
                                .font(.system(size: 48))
                                .padding(Theme.Spacing.small)
                                .background(Theme.titleDenim.opacity(0.1))
                                .clipShape(Circle())
                                .glassEffectCircleIfAvailable()
                            
                            Text("Check your progress")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(Theme.titleDenim)
                        }
                    }
                    .padding(.top, Theme.Spacing.large)
                    
                    // MARK: - Missing Quests Warning
                    if isMissingMainQuest || !missingCategories.isEmpty {
                        VStack(alignment: .leading, spacing: Theme.Spacing.small) {
                            Label("Your adventure can improve!", systemImage: "exclamationmark.triangle.fill")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Theme.titleDenim)
                            
                            if isMissingMainQuest {
                                MissingQuestRow(
                                    icon: "star.fill",
                                    color: Theme.titleDenim,
                                    message: "You haven't set your Daily Adventure yet!"
                                )
                            }
                            
                            ForEach(missingCategories, id: \.self) { category in
                                MissingQuestRow(
                                    icon: category.icon,
                                    color: category.color,
                                    message: "No \(category.rawValue) quest added yet!"
                                )
                            }
                        }
                        .padding(Theme.Spacing.medium)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
                        .glassEffectIfAvailable()
                        .padding(.horizontal, Theme.Spacing.medium)
                    }
                    
                    // MARK: - Progress Section
                    DrawingProgressView(
                        drawingType: viewModel.todayAdventure.drawingType,
                        progress: viewModel.todayAdventure.completionPercentage,
                        completedQuests: viewModel.todayAdventure.completedQuests,
                        totalQuests: viewModel.todayAdventure.totalQuests,
                        allSideQuests: viewModel.todayAdventure.sideQuests
                    )
                    .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
                    .glassEffectIfAvailable()
                    .padding(.horizontal, Theme.Spacing.medium)
                    
                    // MARK: - Completed Quests
                    if !viewModel.todayAdventure.completedQuests.isEmpty {
                        VStack(alignment: .leading, spacing: Theme.Spacing.small) {
                            Label("Completed Quests", systemImage: "checkmark.circle.fill")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Theme.titleDenim)
                            
                            VStack(spacing: Theme.Spacing.small) {
                                ForEach(viewModel.todayAdventure.completedQuests) { quest in
                                    CompletedQuestRow(
                                        quest: quest,
                                        onRemove: {
                                            viewModel.uncompleteQuest(quest)
                                        }
                                    )
                                }
                            }
                        }
                        .padding(Theme.Spacing.medium)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
                        .glassEffectIfAvailable()
                        .padding(.horizontal, Theme.Spacing.medium)
                    } else {
                        VStack(spacing: Theme.Spacing.medium) {
                            Text("⚔️")
                                .font(.system(size: 48))
                            
                            Text("No quests completed yet!")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Theme.titleDenim)
                            
                            Text("Go back and start your adventure!")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(Theme.titleDenim.opacity(0.8))
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(Theme.Spacing.large)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
                        .glassEffectIfAvailable()
                        .padding(.horizontal, Theme.Spacing.medium)
                    }
                    
                    Spacer()
                        .frame(height: 100)
                }
            }
            .frame(maxWidth: .infinity)
            .scrollEdgeEffectIfAvailable()        }
    }
}

struct MissingQuestRow: View {
    let icon: String
    let color: Color
    let message: String
    
    var body: some View {
        HStack(spacing: Theme.Spacing.small) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 32, height: 32)
                
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 14, weight: .semibold))
            }
            .glassEffectCircleIfAvailable()
            
            Text(message)
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(Theme.titleDenim.opacity(0.8))
            
            Spacer()
        }
        .padding(Theme.Spacing.small)
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusSmall))
        .glassEffectIfAvailable(cornerRadius: Theme.cornerRadiusSmall)
    }
}

#Preview {
    ProgressTabView(viewModel: QuestViewModel())
}
