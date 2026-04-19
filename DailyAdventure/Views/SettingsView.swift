//
//  SettingsView.swift
//  DailyAdventure
//
//  Created by Henrique Bernardes on 19/04/26.
//


import SwiftUI

struct SettingsView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("isHighContrast") private var isHighContrast = false
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    
    var body: some View {
        ZStack {
            AnimatedBackgroundView()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: Theme.Spacing.large) {
                    // MARK: - Header
                    VStack(spacing: Theme.Spacing.small) {
                        HStack(spacing: Theme.Spacing.medium) {
                            Text("⚙️")
                                .font(.system(size: 48))
                                .padding(Theme.Spacing.small)
                                .background(Theme.titleDenim.opacity(0.1))
                                .clipShape(Circle())
                                .glassEffectCircleIfAvailable()
                            
                            Text("Settings")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(Theme.titleDenim)
                        }
                    }
                    .padding(.top, Theme.Spacing.large)
                    
                    // MARK: - Appearance
                    VStack(alignment: .leading, spacing: Theme.Spacing.small) {
                        Label("Appearance", systemImage: "paintbrush.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Theme.titleDenim)
                        
                        SettingsToggleRow(
                            icon: "moon.fill",
                            color: Theme.workBlue,
                            title: "Dark Mode",
                            subtitle: "Switch to dark theme",
                            isOn: $isDarkMode
                        )
                        
                        SettingsToggleRow(
                            icon: "circle.lefthalf.filled",
                            color: Theme.titleDenim,
                            title: "High Contrast",
                            subtitle: "Increase color contrast for better readability",
                            isOn: $isHighContrast
                        )
                    }
                    .padding(Theme.Spacing.medium)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
                    .glassEffectIfAvailable()
                    .padding(.horizontal, Theme.Spacing.medium)
                    
                    // MARK: - About
                    VStack(alignment: .leading, spacing: Theme.Spacing.small) {
                        Label("About", systemImage: "info.circle.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Theme.titleDenim)
                        
                        SettingsInfoRow(
                            icon: "star.fill",
                            color: Theme.titleDenim,
                            title: "What is DailyAdventure?",
                            subtitle: "A gamified journaling app that turns your daily tasks into epic quests!"
                        )
                        
                        SettingsInfoRow(
                            icon: "diamond.fill",
                            color: Theme.healthColor,
                            title: "Side Quests",
                            subtitle: "Add tasks for Work, Health and Relationship to balance your adventure."
                        )
                        
                        SettingsInfoRow(
                            icon: "chart.pie.fill",
                            color: Theme.workBlue,
                            title: "Check your Progress",
                            subtitle: "Track your daily completion and see how your adventure unfolds."
                        )
                    }
                    .padding(Theme.Spacing.medium)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
                    .glassEffectIfAvailable()
                    .padding(.horizontal, Theme.Spacing.medium)
                    
                    // MARK: - Help
                    VStack(alignment: .leading, spacing: Theme.Spacing.small) {
                        Label("Help", systemImage: "questionmark.circle.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Theme.titleDenim)
                        
                        Button(action: {
                            hasSeenOnboarding = false
                        }) {
                            HStack(spacing: Theme.Spacing.medium) {
                                ZStack {
                                    Circle()
                                        .fill(Theme.titleDenim.opacity(0.3))
                                        .frame(width: 36, height: 36)
                                    
                                    Image(systemName: "arrow.counterclockwise")
                                        .foregroundColor(Theme.titleDenim)
                                        .font(.system(size: 14, weight: .semibold))
                                }
                                .glassEffectCircleIfAvailable()
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("View Onboarding Again")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(Theme.titleDenim)
                                    
                                    Text("See how DailyAdventure works")
                                        .font(.system(size: 12, weight: .regular))
                                        .foregroundColor(Theme.titleDenim.opacity(0.7))
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(Theme.titleDenim.opacity(0.5))
                                    .font(.system(size: 12))
                            }
                            .padding(Theme.Spacing.small)
                            .background(Theme.titleDenim.opacity(0.05))
                            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusSmall))
                            .glassEffectIfAvailable(cornerRadius: Theme.cornerRadiusSmall)
                        }
                    }
                    .padding(Theme.Spacing.medium)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
                    .glassEffectIfAvailable()
                    .padding(.horizontal, Theme.Spacing.medium)
                    
                    // MARK: - Version
                    Text("DailyAdventure v1.0")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(Theme.titleDenim.opacity(0.5))
                    
                    Spacer()
                        .frame(height: 100)
                }
            }
            .frame(maxWidth: .infinity)
            .scrollEdgeEffectIfAvailable()
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
}

struct SettingsToggleRow: View {
    let icon: String
    let color: Color
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: Theme.Spacing.medium) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.3))
                    .frame(width: 36, height: 36)
                
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 14, weight: .semibold))
            }
            .glassEffectCircleIfAvailable()
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Theme.titleDenim)
                
                Text(subtitle)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(Theme.titleDenim.opacity(0.7))
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .tint(Theme.titleDenim)
                .labelsHidden()
        }
        .padding(Theme.Spacing.small)
        .background(color.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusSmall))
        .glassEffectIfAvailable(cornerRadius: Theme.cornerRadiusSmall)
    }
}

struct SettingsInfoRow: View {
    let icon: String
    let color: Color
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(alignment: .top, spacing: Theme.Spacing.medium) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.3))
                    .frame(width: 36, height: 36)
                
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 14, weight: .semibold))
            }
            .glassEffectCircleIfAvailable()
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Theme.titleDenim)
                
                Text(subtitle)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(Theme.titleDenim.opacity(0.7))
            }
            
            Spacer()
        }
        .padding(Theme.Spacing.small)
        .background(color.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusSmall))
        .glassEffectIfAvailable(cornerRadius: Theme.cornerRadiusSmall)
    }
}

#Preview {
    SettingsView()
}
