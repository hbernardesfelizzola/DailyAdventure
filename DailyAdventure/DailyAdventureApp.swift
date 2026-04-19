//
//  DailyAdventureApp.swift
//  DailyAdventure
//
//  Created by Henrique Bernardes on 09/02/26.
//

import SwiftUI

@main
struct DailyAdventureApp: App {
    @State private var viewModel = QuestViewModel()
    @State private var isLoading = true
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
                    MainTabView(viewModel: viewModel)
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.5), value: isLoading)
            .animation(.easeInOut(duration: 0.5), value: hasSeenOnboarding)
            .preferredColorScheme(isDarkMode ? .dark : .light)
            .onChange(of: scenePhase) { oldPhase, newPhase in
                if newPhase == .active {
                    viewModel.checkAndResetIfNeeded()
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation {
                        isLoading = false
                    }
                }
            }
        }
    }
}

