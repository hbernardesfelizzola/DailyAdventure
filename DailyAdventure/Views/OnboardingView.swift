//
//  OnboardingView.swift
//  DailyAdventure
//
//  Created by Henrique Bernardes on 19/04/26.
//


import SwiftUI
import UserNotifications

struct OnboardingView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var currentPage = 0
    @State private var isAnimating = false

    let pages: [OnboardingPage] = [
        OnboardingPage(
            systemImage: "map.fill",
            title: "Welcome to DailyAdventure!",
            description: "Turn your daily life into an epic adventure. Every day is a new quest waiting to be conquered!",
            color: Theme.titleDenim
        ),
        OnboardingPage(
            systemImage: "star.fill",
            title: "Your Daily Adventure",
            description: "Set your main quest for the day. What's the one big thing you want to accomplish today?",
            color: Theme.workBlue
        ),
        OnboardingPage(
            systemImage: "bolt.fill",
            title: "Side Quests",
            description: "Balance your adventure with side quests in Work, Health and Relationship. Small steps lead to great victories!",
            color: Theme.healthGreen
        ),
        OnboardingPage(
            systemImage: "chart.pie.fill",
            title: "Check your Progress",
            description: "Watch your adventure unfold as you complete quests. Check your progress and celebrate your victories!",
            color: Theme.healthRose
        ),
        OnboardingPage(
            systemImage: "book.fill",
            title: "Adventure Log",
            description: "Look back at your past adventures, review your days and give feedback on how each one went. Your journey tells a story!",
            color: Theme.titleDenim
        ),
        OnboardingPage(
            systemImage: "bell.fill",
            title: "Stay on Track",
            description: "Get a morning reminder to plan your adventure and an evening one to review your day. You can adjust the schedule anytime in Settings.",
            color: Theme.workBlue
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
                            Text(currentPage == pages.count - 2 ? "Start your Adventure!" : "Next")
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
                            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in
                                DispatchQueue.main.async {
                                    hasSeenOnboarding = true
                                }
                            }
                        }) {
                            Text("Enable reminders")
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
                            Text("Skip for now")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(Theme.titleDenim.opacity(0.7))
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
    let systemImage: String
    let title: String
    let description: String
    let color: Color
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    @State private var isAnimating = false

    var body: some View {
        VStack(spacing: Theme.Spacing.large) {
            // Ícone animado
            ZStack {
                Circle()
                    .fill(page.color.opacity(0.1))
                    .frame(width: 140, height: 140)
                    .scaleEffect(isAnimating ? 1.1 : 0.9)

                Circle()
                    .fill(page.color.opacity(0.05))
                    .frame(width: 170, height: 170)
                    .scaleEffect(isAnimating ? 1.15 : 0.85)

                Image(systemName: page.systemImage)
                    .font(.system(size: 56))
                    .foregroundColor(page.color)
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
