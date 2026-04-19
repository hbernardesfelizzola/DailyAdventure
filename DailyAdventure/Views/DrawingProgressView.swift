//
//  DrawingProgressView.swift
//  DailyAdventure
//
//  Created by Henrique Bernardes on 19/04/26.
//


import SwiftUI
import Charts

struct DrawingProgressView: View {
    let drawingType: DrawingType
    let progress: Double
    let completedQuests: [Quest]
    let totalQuests: Int
    let allSideQuests: [Quest]
    
    @State private var animatedProgress: Double = 0
    
    var chartData: [ChartDataPoint] {
        var data: [ChartDataPoint] = []
        
        let workCompleted = completedQuests.filter { $0.category == .work && !$0.isMainQuest }.count
        let healthCompleted = completedQuests.filter { $0.category == .health }.count
        let relationshipCompleted = completedQuests.filter { $0.category == .relationship }.count
        let mainCompleted = completedQuests.filter { $0.isMainQuest }.count
        
        if mainCompleted > 0 {
            data.append(ChartDataPoint(category: "Main", value: Double(mainCompleted), color: Theme.titleDenim))
        }
        if workCompleted > 0 {
            data.append(ChartDataPoint(category: "Work", value: Double(workCompleted), color: QuestCategory.work.color))
        }
        if healthCompleted > 0 {
            data.append(ChartDataPoint(category: "Health", value: Double(healthCompleted), color: QuestCategory.health.color))
        }
        if relationshipCompleted > 0 {
            data.append(ChartDataPoint(category: "Relationship", value: Double(relationshipCompleted), color: QuestCategory.relationship.color))
        }
        
        return data
    }
    
    var mainWeight: Double {
        return 1.0
    }

    var workWeight: Double {
        let total = allSideQuests.filter { $0.category == .work }.count
        return max(1.0, Double(total)) // Mínimo 1, cresce com mais quests
    }

    var healthWeight: Double {
        let total = allSideQuests.filter { $0.category == .health }.count
        return max(1.0, Double(total))
    }

    var relationshipWeight: Double {
        let total = allSideQuests.filter { $0.category == .relationship }.count
        return max(1.0, Double(total))
    }
    
    var mainProgress: String {
        let completed = completedQuests.filter { $0.isMainQuest }.count
        return "\(completed)/1"
    }
    
    var workProgress: String {
        let completed = completedQuests.filter { $0.category == .work }.count
        let total = allSideQuests.filter { $0.category == .work }.count
        return "\(completed)/\(total)"
    }
    
    var healthProgress: String {
        let completed = completedQuests.filter { $0.category == .health }.count
        let total = allSideQuests.filter { $0.category == .health }.count
        return "\(completed)/\(total)"
    }
    
    var relationshipProgress: String {
        let completed = completedQuests.filter { $0.category == .relationship }.count
        let total = allSideQuests.filter { $0.category == .relationship }.count
        return "\(completed)/\(total)"
    }
    
    var progressBarColors: [Color] {
        var colors: [Color] = []
        
        if completedQuests.contains(where: { $0.isMainQuest }) {
            colors.append(Theme.titleDenim)
        }
        if completedQuests.contains(where: { $0.category == .work }) {
            colors.append(QuestCategory.work.color)
        }
        if completedQuests.contains(where: { $0.category == .health }) {
            colors.append(QuestCategory.health.color)
        }
        if completedQuests.contains(where: { $0.category == .relationship }) {
            colors.append(QuestCategory.relationship.color)
        }
        
        return colors.isEmpty ? [Theme.titleDenim] : colors
    }
    
    var body: some View {
        VStack(spacing: Theme.Spacing.medium) {
            // MARK: - Gráfico e Progress lado a lado
            HStack(spacing: Theme.Spacing.large) {
                // Gráfico circular
                ZStack {
                    Chart {
                        // Main Quest
                        SectorMark(
                            angle: .value("Main", mainWeight),
                            innerRadius: .ratio(0.6),
                            angularInset: 2
                        )
                        .foregroundStyle(Theme.titleDenim.opacity(
                            completedQuests.contains(where: { $0.isMainQuest }) ? 0.9 : 0.15
                        ))
                        
                        // Work
                        SectorMark(
                            angle: .value("Work", workWeight),
                            innerRadius: .ratio(0.6),
                            angularInset: 2
                        )
                        .foregroundStyle(QuestCategory.work.color.opacity(
                            completedQuests.contains(where: { $0.category == .work }) ? 0.9 : 0.15
                        ))
                        
                        // Health
                        SectorMark(
                            angle: .value("Health", healthWeight),
                            innerRadius: .ratio(0.6),
                            angularInset: 2
                        )
                        .foregroundStyle(QuestCategory.health.color.opacity(
                            completedQuests.contains(where: { $0.category == .health }) ? 0.9 : 0.15
                        ))
                        
                        // Relationship
                        SectorMark(
                            angle: .value("Relationship", relationshipWeight),
                            innerRadius: .ratio(0.6),
                            angularInset: 2
                        )
                        .foregroundStyle(QuestCategory.relationship.color.opacity(
                            completedQuests.contains(where: { $0.category == .relationship }) ? 0.9 : 0.15
                        ))
                    }
                    .animation(.spring(response: 0.5, dampingFraction: 0.7), value: workWeight)
                    .animation(.spring(response: 0.5, dampingFraction: 0.7), value: healthWeight)
                    .animation(.spring(response: 0.5, dampingFraction: 0.7), value: relationshipWeight)
                    .frame(maxWidth: 150)
                    .frame(height: 150)
                    
                    // Centro do gráfico
                    VStack(spacing: 4) {
                        Text("\(Int(animatedProgress * 100))%")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Theme.titleDenim)
                        
                        Text(completedQuests.isEmpty ? "Start!" : "Complete")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(Theme.titleDenim.opacity(0.7))
                    }
                }
                
                // Progress by Category
                VStack(alignment: .leading, spacing: Theme.Spacing.small) {
                    Text("Category Progress")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Theme.titleDenim)
                    
                    CategoryBadge(
                        icon: "star.fill",
                        category: "Main",
                        progress: mainProgress,
                        color: Theme.titleDenim
                    )
                    
                    CategoryBadge(
                        icon: "briefcase.fill",
                        category: "Work",
                        progress: workProgress,
                        color: QuestCategory.work.color
                    )
                    
                    CategoryBadge(
                        icon: "figure.run",
                        category: "Health",
                        progress: healthProgress,
                        color: QuestCategory.health.color
                    )
                    
                    CategoryBadge(
                        icon: "heart.fill",
                        category: "Relationship",
                        progress: relationshipProgress,
                        color: QuestCategory.relationship.color
                    )
                    
                    Spacer()
                }
            }
            .padding(.horizontal, Theme.Spacing.medium)
            
            // MARK: - Barra de progresso colorida
            VStack(spacing: Theme.Spacing.small) {
                HStack {
                    Text("Overall Progress")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(Theme.titleDenim)
                    
                    Spacer()
                    
                    Text("\(completedQuests.count)/\(totalQuests)")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Theme.titleDenim)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Theme.titleDenim.opacity(0.1))
                            .frame(height: 8)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                LinearGradient(
                                    colors: progressBarColors,
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * animatedProgress, height: 8)
                    }
                }
                .frame(height: 8)
            }
            .padding(.horizontal, Theme.Spacing.medium)
        }
        .padding(Theme.Spacing.medium)
        .onAppear {
            animateProgress()
        }
        .onChange(of: progress) { oldValue, newValue in
            animateProgress()
        }
    }
    
    private func animateProgress() {
        withAnimation(.easeInOut(duration: 0.6)) {
            animatedProgress = progress
        }
    }
}

// MARK: - Componentes auxiliares

struct CategoryBadge: View {
    let icon: String
    let category: String
    let progress: String
    let color: Color
    
    var body: some View {
        HStack(spacing: Theme.Spacing.small) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.3))
                    .frame(width: 28, height: 28)
                
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 12, weight: .semibold))
            }
            .glassEffectCircleIfAvailable()
            
            VStack(alignment: .leading, spacing: 2) {
                Text(category)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(Theme.titleDenim)
                
                Text(progress)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(color)
            }
            
            Spacer()
        }
        .padding(Theme.Spacing.small)
        .background(color.opacity(0.1))
        .clipShape(Capsule())
        .glassEffectCapsuleIfAvailable()
    }
}

struct ChartDataPoint: Identifiable {
    let id = UUID()
    let category: String
    let value: Double
    let color: Color
}

#Preview {
    VStack(spacing: 20) {
        DrawingProgressView(
            drawingType: .castle,
            progress: 0.5,
            completedQuests: [
                Quest(title: "Complete project", category: nil, isMainQuest: true),
                Quest(title: "Go to office", category: .work)
            ],
            totalQuests: 4,
            allSideQuests: [
                Quest(title: "Go to office", category: .work),
                Quest(title: "Drink water", category: .health),
                Quest(title: "Call mom", category: .relationship)
            ]
        )
    }
    .padding()
    .background(Theme.background)
}
