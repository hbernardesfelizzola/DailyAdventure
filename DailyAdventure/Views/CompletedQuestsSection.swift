//
//  CompletedQuestsSection.swift
//  DailyAdventure
//
//  Created by Henrique Bernardes on 19/04/26.
//


import SwiftUI

struct CompletedQuestsSection: View {
    let adventure: DailyAdventure
    let completedQuests: [Quest]
    let onRemoveQuest: (Quest) -> Void
    @State private var isExpanded = false
    
    var body: some View {
        VStack(spacing: Theme.Spacing.medium) {
            VStack(spacing: 0) {
                // Botão de expansão
                Button(action: {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        isExpanded.toggle()
                    }
                }) {
                    HStack(spacing: Theme.Spacing.medium) {
                        ZStack {
                            Circle()
                                .fill(Theme.titleDenim.opacity(0.3))
                                .frame(width: 44, height: 44)
                            
                            Text("🏰")
                                .font(.system(size: 22))
                        }
                        .glassEffectCircleIfAvailable()
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Check your progress")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Theme.titleDenim)
                            
                            Text("\(completedQuests.count)/\(adventure.totalQuests) quests completed")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(Theme.titleDenim.opacity(0.8))
                        }
                        
                        Spacer()
                        
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .foregroundColor(Theme.titleDenim.opacity(0.8))
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .padding(Theme.Spacing.medium)
                }
                
                if isExpanded {
                    VStack(spacing: Theme.Spacing.medium) {
                        Divider()
                            .padding(.horizontal, Theme.Spacing.medium)
                        
                        DrawingProgressView(
                            drawingType: adventure.drawingType,
                            progress: adventure.completionPercentage,
                            completedQuests: completedQuests,
                            totalQuests: adventure.totalQuests,
                            allSideQuests: adventure.sideQuests
                        )
                        
                        if !completedQuests.isEmpty {
                            VStack(alignment: .leading, spacing: Theme.Spacing.small) {
                                Divider()
                                    .padding(.horizontal, Theme.Spacing.medium)
                                
                                Label("Completed Quests", systemImage: "checkmark.circle.fill")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(Theme.titleDenim)
                                    .padding(.horizontal, Theme.Spacing.medium)
                                
                                VStack(spacing: Theme.Spacing.small) {
                                    ForEach(completedQuests) { quest in
                                        CompletedQuestRow(
                                            quest: quest,
                                            onRemove: { onRemoveQuest(quest) }
                                        )
                                    }
                                }
                                .padding(.horizontal, Theme.Spacing.medium)
                                .padding(.bottom, Theme.Spacing.medium)
                            }
                        }
                    }
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
            .glassEffectIfAvailable()
        }
    }
}

struct CompletedQuestRow: View {
    let quest: Quest
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: Theme.Spacing.small) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(quest.isMainQuest ? Theme.titleDenim : (quest.category?.color ?? Theme.titleDenim))
                .font(.system(size: 18))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(quest.title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Theme.titleDenim)
                
                Text(quest.isMainQuest ? "Main Quest" : (quest.category?.rawValue ?? "Quest"))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Theme.titleDenim.opacity(0.8))
            }
            
            Spacer()
            
            Button(action: onRemove) {
                Image(systemName: "arrow.uturn.backward.circle.fill")
                    .foregroundColor(Theme.titleDenim.opacity(0.6))
                    .font(.system(size: 18))
            }
        }
        .padding(Theme.Spacing.small)
        .background(
            quest.isMainQuest ?
            Theme.titleDenim.opacity(0.15) :
            (quest.category?.color.opacity(0.15) ?? Theme.titleDenim.opacity(0.15))
        )
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusSmall))
        .glassEffectIfAvailable(cornerRadius: Theme.cornerRadiusSmall)
    }
}

#Preview {
    CompletedQuestsSection(
        adventure: DailyAdventure(
            mainQuest: "Complete project",
            sideQuests: [
                Quest(title: "Go to office", category: .work),
                Quest(title: "Drink water", category: .health),
                Quest(title: "Call mom", category: .relationship)
            ],
            completedQuests: [
                Quest(title: "Complete project", category: nil, isMainQuest: true),
                Quest(title: "Go to office", category: .work)
            ]
        ),
        completedQuests: [
            Quest(title: "Complete project", category: nil, isMainQuest: true),
            Quest(title: "Go to office", category: .work)
        ],
        onRemoveQuest: { _ in }
    )
    .padding()
    .background(Theme.background)
}
