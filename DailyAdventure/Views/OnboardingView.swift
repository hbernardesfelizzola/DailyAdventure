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
    @AppStorage(UserProfile.nameKey) private var userName = ""
    @State private var nameDraft = ""
    @AppStorage("morningReminderEnabled") private var morningReminderEnabled = false
    @AppStorage("eveningReminderEnabled") private var eveningReminderEnabled = false

    let pages: [OnboardingPage] = [
        OnboardingPage(
            systemImage: "map.fill",
            title: "Welcome to DailyAdventure!",
            description: "Turn your daily life into an epic adventure. Every day is a new quest waiting to be conquered!",
            color: Theme.accent
        ),
        OnboardingPage(
            systemImage: "star.fill",
            title: "Your Daily Adventure",
            description: "Set your main quest for the day. What's the one big thing you want to accomplish today?",
            color: Theme.workColor
        ),
        OnboardingPage(
            systemImage: "bolt.fill",
            title: "Side Quests",
            description: "Balance your adventure with side quests in Work, Health and Relationship. Small steps lead to great victories!",
            color: Theme.healthColor
        ),
        OnboardingPage(
            systemImage: "chart.pie.fill",
            title: "Check your Progress",
            description: "Watch your adventure unfold as you complete quests. Check your progress and celebrate your victories!",
            color: Theme.relationshipColor
        ),
        OnboardingPage(
            systemImage: "book.fill",
            title: "Adventure Log",
            description: "Look back at your past adventures, review your days and give feedback on how each one went. Your journey tells a story!",
            color: Theme.accent
        ),
        OnboardingPage(
            systemImage: "bell.fill",
            title: "Stay on Track",
            description: "Get a morning reminder to plan your adventure and an evening one to review your day. You can adjust the schedule anytime in Settings.",
            color: Theme.workColor
        )
    ]

    /// Páginas informativas com o passo do nome logo depois das boas-vindas.
    private var steps: [OnboardingStep] {
        var steps = pages.map(OnboardingStep.info)
        steps.insert(.name, at: 1)
        return steps
    }

    var body: some View {
        ZStack {
            AnimatedBackgroundView()
            
            VStack(spacing: Theme.Spacing.large) {
                Spacer()
                
                // MARK: - Page Content
                TabView(selection: $currentPage) {
                    ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                        Group {
                            switch step {
                            case .info(let page):
                                OnboardingPageView(page: page)
                            case .name:
                                OnboardingNamePageView(name: $nameDraft, onSubmit: goToNextPage)
                            }
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 400)
                .onChange(of: currentPage) { _, _ in saveName() }
                
                // MARK: - Page Indicators
                HStack(spacing: Theme.Spacing.small) {
                    ForEach(0..<steps.count, id: \.self) { index in
                        Capsule()
                            .fill(currentPage == index ? Theme.accent : Theme.accent.opacity(0.25))
                            .frame(width: currentPage == index ? 24 : 8, height: 8)
                            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: currentPage)
                    }
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(Text("Page \(currentPage + 1) of \(steps.count)"))

                Spacer()

                // MARK: - Buttons
                VStack(spacing: Theme.Spacing.medium) {
                    if currentPage < steps.count - 1 {
                        Button(currentPage == steps.count - 2 ? "Start your Adventure!" : "Next", action: goToNextPage)
                            .buttonStyle(.primary)

                        Button("Skip", action: finish)
                            .buttonStyle(OnboardingSecondaryButtonStyle())
                    } else {
                        Button("Enable reminders", action: enableReminders)
                            .buttonStyle(.primary)

                        Button("Skip for now", action: finish)
                            .buttonStyle(OnboardingSecondaryButtonStyle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, Theme.Spacing.medium)
            }
        }
    }

    private func goToNextPage() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            currentPage = min(currentPage + 1, steps.count - 1)
        }
    }

    private func saveName() {
        let name = UserProfile.sanitized(nameDraft)
        if !name.isEmpty { userName = name }
    }

    /// Pede permissão e, se concedida, liga os dois lembretes com os horários padrão.
    private func enableReminders() {
        Task {
            let granted = await NotificationService.shared.requestPermission()
            if granted {
                morningReminderEnabled = true
                eveningReminderEnabled = true
                NotificationService.shared.syncScheduledNotificationsWithSettings()
            }
            finish()
        }
    }

    private func finish() {
        saveName()
        hasSeenOnboarding = true
    }
}

enum OnboardingStep {
    case info(OnboardingPage)
    case name
}

/// Passo opcional para o usuário dizer como quer ser chamado (usado na saudação da Today).
struct OnboardingNamePageView: View {
    @Binding var name: String
    let onSubmit: () -> Void
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: Theme.Spacing.large) {
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 72))
                .foregroundStyle(Theme.accent)
                .accessibilityHidden(true)

            VStack(spacing: Theme.Spacing.medium) {
                Text("What should we call you?")
                    .font(.screenTitleCompact)
                    .foregroundStyle(Theme.ink)
                    .multilineTextAlignment(.center)

                Text("We'll use your name to greet you every day. You can change it anytime in Settings.")
                    .font(.body)
                    .foregroundStyle(Theme.inkSecondary)
                    .multilineTextAlignment(.center)
            }

            TextField("Your name", text: $name)
                .font(.title3)
                .foregroundStyle(Theme.ink)
                .multilineTextAlignment(.center)
                .textContentType(.givenName)
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled()
                .submitLabel(.next)
                .focused($isFocused)
                .onSubmit(onSubmit)
                .padding(.horizontal, 16)
                .frame(minHeight: 56)
                .cardSurface(cornerRadius: Theme.Radius.control)
                .onChange(of: name) { _, newValue in
                    if newValue.count > UserProfile.maxNameLength {
                        name = String(newValue.prefix(UserProfile.maxNameLength))
                    }
                }
        }
        .padding(.horizontal, Theme.Spacing.large)
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
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isAnimating = false

    var body: some View {
        VStack(spacing: Theme.Spacing.large) {
            ZStack {
                Circle()
                    .fill(page.color.opacity(0.08))
                    .frame(width: 170, height: 170)
                    .scaleEffect(isAnimating ? 1.06 : 0.94)

                Circle()
                    .fill(page.color.opacity(0.14))
                    .frame(width: 132, height: 132)

                Image(systemName: page.systemImage)
                    .font(.system(size: 54, weight: .semibold))
                    .foregroundStyle(page.color)
            }
            .accessibilityHidden(true)

            VStack(spacing: Theme.Spacing.medium) {
                Text(LocalizedStringKey(page.title))
                    .font(.screenTitleCompact)
                    .foregroundStyle(Theme.ink)
                    .multilineTextAlignment(.center)
                    .accessibilityAddTraits(.isHeader)

                Text(LocalizedStringKey(page.description))
                    .font(.body)
                    .foregroundStyle(Theme.inkSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.horizontal, Theme.Spacing.large)
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}

/// Botão de texto secundário ("Pular").
struct OnboardingSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.supporting.weight(.semibold))
            .foregroundStyle(Theme.accent)
            .frame(maxWidth: .infinity, minHeight: 44)
            .opacity(configuration.isPressed ? 0.6 : 1)
    }
}

#Preview {
    OnboardingView()
}
