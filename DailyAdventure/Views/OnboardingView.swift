//
//  OnboardingView.swift
//  DailyAdventure
//
//  Created by Henrique Bernardes on 19/04/26.
//


import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var currentPage = 0
    @State private var isAnimating = false
    
    let pages: [OnboardingPage] = [
        OnboardingPage(
            emoji: "⚔️",
            title: "Welcome to DailyAdventure!",
            description: "Turn your daily life into an epic adventure. Every day is a new quest waiting to be conquered!",
            color: Theme.titleDenim
        ),
        OnboardingPage(
            emoji: "🌟",
            title: "Your Daily Adventure",
            description: "Set your main quest for the day. What's the one big thing you want to accomplish today?",
            color: Theme.workBlue
        ),
        OnboardingPage(
            emoji: "⚡️",
            title: "Side Quests",
            description: "Balance your adventure with side quests in Work, Health and Relationship. Small steps lead to great victories!",
            color: Theme.healthGreen
        ),
        OnboardingPage(
            emoji: "🏰",
            title: "Track your Progress",
            description: "Watch your adventure unfold as you complete quests. Check your progress and celebrate your victories!",
            color: Theme.healthRose
        )
    ]
    
    var body: some View {
        ZStack {
            AnimatedBackgroundView()
            
            VStack(spacing: Theme.Spacing.large) {
                Spacer()
                
                // MARK: - Page Content
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 400)
                
                // MARK: - Page Indicators
                HStack(spacing: Theme.Spacing.small) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Capsule()
                            .fill(currentPage == index ? Theme.titleDenim : Theme.titleDenim.opacity(0.3))
                            .frame(width: currentPage == index ? 24 : 8, height: 8)
                            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: currentPage)
                    }
                }
                
                Spacer()
                
                // MARK: - Buttons
                VStack(spacing: Theme.Spacing.medium) {
                    if currentPage < pages.count - 1 {
                        Button(action: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                currentPage += 1
                            }
                        }) {
                            Text("Next")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(Theme.Spacing.medium)
                                .background(Theme.titleDenim)
                                .clipShape(Capsule())
                                .glassEffectCapsuleIfAvailable()
                        }
                        
                        Button(action: {
                            hasSeenOnboarding = true
                        }) {
                            Text("Skip")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(Theme.titleDenim.opacity(0.7))
                        }
                    } else {
                        Button(action: {
                            withAnimation {
                                hasSeenOnboarding = true
                            }
                        }) {
                            Text("Start your Adventure!")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(Theme.Spacing.medium)
                                .background(Theme.titleDenim)
                                .clipShape(Capsule())
                                .glassEffectCapsuleIfAvailable()
                        }
                    }
                }
                .padding(.horizontal, Theme.Spacing.large)
                .padding(.bottom, Theme.Spacing.large)
            }
        }
    }
}

struct OnboardingPage {
    let emoji: String
    let title: String
    let description: String
    let color: Color
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: Theme.Spacing.large) {
            // Emoji animado
            ZStack {
                Circle()
                    .fill(page.color.opacity(0.1))
                    .frame(width: 140, height: 140)
                    .scaleEffect(isAnimating ? 1.1 : 0.9)
                
                Circle()
                    .fill(page.color.opacity(0.05))
                    .frame(width: 170, height: 170)
                    .scaleEffect(isAnimating ? 1.15 : 0.85)
                
                Text(page.emoji)
                    .font(.system(size: 64))
                    .scaleEffect(isAnimating ? 1.05 : 0.95)
            }
            .glassEffectCircleIfAvailable()
            
            // Texto
            VStack(spacing: Theme.Spacing.medium) {
                Text(page.title)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Theme.titleDenim)
                    .multilineTextAlignment(.center)
                
                Text(page.description)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(Theme.titleDenim.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Theme.Spacing.large)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}

#Preview {
    OnboardingView()
}
