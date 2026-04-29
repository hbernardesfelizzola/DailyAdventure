//
//  HistoryView.swift
//  DailyAdventure
//
//  Created by Henrique Bernardes on 25/04/26.
//


import SwiftUI

struct HistoryView: View {
    var viewModel: QuestViewModel
    @State private var selectedAdventure: DailyAdventure? = nil
    
    var allDays: [DailyAdventure] {
        var days = viewModel.history
        if !viewModel.todayAdventure.mainQuest.isEmpty ||
           !viewModel.todayAdventure.sideQuests.isEmpty {
            days.insert(viewModel.todayAdventure, at: 0)
        }
        return days
    }
    
    var body: some View {
        ZStack {
            AnimatedBackgroundView()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: Theme.Spacing.large) {
                    // MARK: - Header
                    VStack(spacing: Theme.Spacing.small) {
                        HStack(spacing: Theme.Spacing.medium) {
                            Text("📖")
                                .font(.system(size: 48))
                                .padding(Theme.Spacing.small)
                                .background(Theme.titleDenim.opacity(0.1))
                                .clipShape(Circle())
                                .glassEffectCircleIfAvailable()
                            
                            Text("Adventure Log")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(Theme.titleDenim)
                        }
                        
                        Text("\(allDays.count) days of adventure")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(Theme.titleDenim.opacity(0.8))
                            .padding(.horizontal, Theme.Spacing.medium)
                            .padding(.vertical, Theme.Spacing.small)
                            .background(Theme.titleDenim.opacity(0.1))
                            .clipShape(Capsule())
                            .glassEffectCapsuleIfAvailable()
                    }
                    .padding(.top, Theme.Spacing.large)
                    
                    // MARK: - Lista de dias
                    if allDays.isEmpty {
                        VStack(spacing: Theme.Spacing.medium) {
                            Text("📜")
                                .font(.system(size: 48))
                            
                            Text("No adventures yet!")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Theme.titleDenim)
                            
                            Text("Start your first adventure today!")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(Theme.titleDenim.opacity(0.8))
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(Theme.Spacing.large)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
                        .glassEffectIfAvailable()
                        .padding(.horizontal, Theme.Spacing.medium)
                    } else {
                        VStack(spacing: Theme.Spacing.small) {
                            ForEach(allDays) { adventure in
                                AdventureHistoryRow(
                                    adventure: adventure,
                                    isSelected: selectedAdventure?.id == adventure.id,
                                    onTap: {
                                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                            if selectedAdventure?.id == adventure.id {
                                                selectedAdventure = nil
                                            } else {
                                                selectedAdventure = adventure
                                            }
                                        }
                                    },
                                    onFeedback: { feedback in
                                        viewModel.updateFeedback(feedback, for: adventure)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, Theme.Spacing.medium)
                    }
                    
                    Spacer()
                        .frame(height: 100)
                }
            }
            .frame(maxWidth: .infinity)
            .scrollEdgeEffectIfAvailable()
        }
    }
}

// MARK: - AdventureHistoryRow
struct AdventureHistoryRow: View {
    let adventure: DailyAdventure
    let isSelected: Bool
    let onTap: () -> Void
    let onFeedback: (DayFeedback) -> Void
    
    var dateLabel: String {
        if Calendar.current.isDateInToday(adventure.date) {
            return "Today"
        } else if Calendar.current.isDateInYesterday(adventure.date) {
            return "Yesterday"
        } else {
            return adventure.date.formatted(.dateTime.weekday(.wide).day().month())
        }
    }
    
    var completionColor: Color {
        if adventure.completionPercentage >= 1.0 {
            return Theme.healthColor
        } else if adventure.completionPercentage >= 0.5 {
            return Theme.workBlue
        } else if adventure.completionPercentage > 0 {
            return Theme.healthRose
        } else {
            return Theme.titleDenim.opacity(0.3)
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Row principal
            Button(action: onTap) {
                HStack(spacing: Theme.Spacing.medium) {
                    // Indicador de completion
                    ZStack {
                        Circle()
                            .fill(completionColor.opacity(0.2))
                            .frame(width: 44, height: 44)
                        
                        if adventure.hasAnyQuest {
                            Text("\(Int(adventure.completionPercentage * 100))%")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(completionColor)
                        } else {
                            Image(systemName: "minus")
                                .foregroundColor(Theme.titleDenim.opacity(0.3))
                                .font(.system(size: 14))
                        }
                    }
                    .glassEffectCircleIfAvailable()
                    
                    // Info do dia
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(dateLabel)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Theme.titleDenim)
                            
                            if Calendar.current.isDateInToday(adventure.date) {
                                Text("-")
                                    .foregroundColor(Theme.titleDenim.opacity(0.4))
                                Text("Current")
                                    .font(.system(size: 12, weight: .regular))
                                    .foregroundColor(Theme.titleDenim.opacity(0.6))
                            }
                        }
                        
                        if adventure.mainQuest.isEmpty {
                            Text("No main quest set")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(Theme.titleDenim.opacity(0.5))
                                .italic()
                        } else {
                            Text(adventure.mainQuest)
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(Theme.titleDenim.opacity(0.8))
                                .lineLimit(1)
                        }
                    }
                    
                    Spacer()
                    
                    // Feedback badge
                    if adventure.feedback != .none {
                        Text(adventure.feedback == .positive ? "👍" : "👎")
                            .font(.system(size: 20))
                    }
                    
                    Image(systemName: isSelected ? "chevron.up" : "chevron.down")
                        .foregroundColor(Theme.titleDenim.opacity(0.5))
                        .font(.system(size: 12, weight: .semibold))
                }
                .padding(Theme.Spacing.medium)
            }
            
            // MARK: - Conteúdo expandido
            if isSelected {
                VStack(spacing: Theme.Spacing.medium) {
                    Divider()
                        .padding(.horizontal, Theme.Spacing.medium)
                    
                    // Quests do dia
                    if adventure.hasAnyQuest {
                        VStack(alignment: .leading, spacing: Theme.Spacing.small) {
                            // Main Quest
                            if !adventure.mainQuest.isEmpty {
                                HStack(spacing: Theme.Spacing.small) {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(Theme.titleDenim)
                                        .font(.system(size: 12))
                                        .frame(width: 20)
                                    
                                    Text(adventure.mainQuest)
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(Theme.titleDenim)
                                    
                                    Spacer()
                                    
                                    if adventure.completedQuests.contains(where: { $0.isMainQuest }) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(Theme.healthColor)
                                            .font(.system(size: 14))
                                    }
                                }
                            }
                            
                            // Side Quests
                            ForEach(adventure.sideQuests) { quest in
                                HStack(spacing: Theme.Spacing.small) {
                                    Image(systemName: quest.category?.icon ?? "diamond.fill")
                                        .foregroundColor(quest.category?.color ?? Theme.titleDenim)
                                        .font(.system(size: 12))
                                        .frame(width: 20)
                                    
                                    Text(quest.title)
                                        .font(.system(size: 13, weight: .regular))
                                        .foregroundColor(Theme.titleDenim.opacity(0.8))
                                    
                                    Spacer()
                                    
                                    if adventure.completedQuests.contains(where: { $0.id == quest.id }) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(Theme.healthColor)
                                            .font(.system(size: 14))
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, Theme.Spacing.medium)
                    } else {
                        Text("No quests recorded for this day")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(Theme.titleDenim.opacity(0.5))
                            .italic()
                            .padding(.horizontal, Theme.Spacing.medium)
                    }
                    
                    Divider()
                        .padding(.horizontal, Theme.Spacing.medium)
                    
                    // MARK: - Feedback
                    VStack(spacing: Theme.Spacing.small) {
                        Text("How was this day?")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Theme.titleDenim.opacity(0.8))
                        
                        HStack(spacing: Theme.Spacing.large) {
                            // Thumbs Up
                            Button(action: {
                                withAnimation {
                                    onFeedback(adventure.feedback == .positive ? .none : .positive)
                                }
                            }) {
                                VStack(spacing: 4) {
                                    Text("👍")
                                        .font(.system(size: 32))
                                        .scaleEffect(adventure.feedback == .positive ? 1.2 : 1.0)
                                    
                                    Text("Great day!")
                                        .font(.system(size: 11, weight: .regular))
                                        .foregroundColor(adventure.feedback == .positive ? Theme.healthColor : Theme.titleDenim.opacity(0.5))
                                }
                                .padding(Theme.Spacing.medium)
                                .background(adventure.feedback == .positive ? Theme.healthColor.opacity(0.15) : Color.clear)
                                .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusSmall))
                                .glassEffectIfAvailable(cornerRadius: Theme.cornerRadiusSmall)
                            }
                            
                            // Thumbs Down
                            Button(action: {
                                withAnimation {
                                    onFeedback(adventure.feedback == .negative ? .none : .negative)
                                }
                            }) {
                                VStack(spacing: 4) {
                                    Text("👎")
                                        .font(.system(size: 32))
                                        .scaleEffect(adventure.feedback == .negative ? 1.2 : 1.0)
                                    
                                    Text("Tough day")
                                        .font(.system(size: 11, weight: .regular))
                                        .foregroundColor(adventure.feedback == .negative ? Theme.healthRose : Theme.titleDenim.opacity(0.5))
                                }
                                .padding(Theme.Spacing.medium)
                                .background(adventure.feedback == .negative ? Theme.healthRose.opacity(0.15) : Color.clear)
                                .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusSmall))
                                .glassEffectIfAvailable(cornerRadius: Theme.cornerRadiusSmall)
                            }
                        }
                    }
                    .padding(.bottom, Theme.Spacing.medium)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
        .glassEffectIfAvailable()
    }
}

#Preview {
    HistoryView(viewModel: QuestViewModel())
}
