//
//  DailyAdventureApp.swift
//  DailyAdventure
//
//  Created by Henrique Bernardes on 09/02/26.
//

import SwiftUI

@main
struct DailyAdventureApp: App {
    private static let isUITesting = ProcessInfo.processInfo.arguments.contains("--ui-testing")

    init() {
        if Self.isUITesting {
            UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
        }
        if ProcessInfo.processInfo.arguments.contains("--mock-data") {
            MockDataSeeder.seed()
        }
    }

    @State private var viewModel = QuestViewModel()
    @State private var notificationRouter = NotificationTapRouter()
    @State private var weatherProvider = WeatherProvider()
    @State private var isLoading = !DailyAdventureApp.isUITesting
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @AppStorage("isDarkMode") private var isDarkMode = false
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if isLoading {
                    LoadingView()
                        .transition(.opacity)
                } else if !hasSeenOnboarding {
                    OnboardingView()
                        .transition(.opacity)
                } else {
                    MainTabView(viewModel: viewModel, notificationRouter: notificationRouter, weatherProvider: weatherProvider)
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.5), value: isLoading)
            .animation(.easeInOut(duration: 0.5), value: hasSeenOnboarding)
            .preferredColorScheme(isDarkMode ? .dark : .light)
            .onChange(of: scenePhase) { oldPhase, newPhase in
                if newPhase == .active {
                    viewModel.checkAndResetIfNeeded()
                    NotificationService.shared.syncScheduledNotificationsWithSettings()
                    weatherProvider.fetchIfNeeded()
                }
            }
            .onOpenURL { url in
                switch url.host {
                case "today":    notificationRouter.pendingTabIndex = MainTab.today
                case "progress": notificationRouter.pendingTabIndex = MainTab.progress
                default: break
                }
            }
            .onAppear {
                guard !DailyAdventureApp.isUITesting else { return }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation {
                        isLoading = false
                    }
                }
            }
        }
    }
}

