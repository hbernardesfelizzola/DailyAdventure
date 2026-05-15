//
//  MainTabView.swift
//  DailyAdventure
//
//  Created by Henrique Bernardes on 19/04/26.
//


import SwiftUI

struct MainTabView: View {
    var viewModel: QuestViewModel
    var notificationRouter: NotificationTapRouter
    @State private var selectedTab = MainTab.today
    
    var body: some View {
        ZStack {
            AnimatedBackgroundView()
                .ignoresSafeArea()
            
            TabView(selection: $selectedTab) {
                // MARK: - History Tab (esquerda)
                HistoryView(viewModel: viewModel)
                    .tabItem {
                        Label("Log", systemImage: "book.fill")
                    }
                    .tag(MainTab.log)
                    .toolbarBackground(.ultraThinMaterial, for: .tabBar)
                
                // MARK: - Today Tab (centro - tab inicial)
                ContentView(viewModel: viewModel)
                    .tabItem {
                        Label("Today", systemImage: "star.fill")
                    }
                    .tag(MainTab.today)
                    .toolbarBackground(.ultraThinMaterial, for: .tabBar)
                
                // MARK: - Progress Tab
                ProgressTabView(viewModel: viewModel)
                    .tabItem {
                        Label("Progress", systemImage: "chart.pie.fill")
                    }
                    .tag(MainTab.progress)
                    .toolbarBackground(.ultraThinMaterial, for: .tabBar)
                
                // MARK: - Settings Tab (direita)
                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gearshape.fill")
                    }
                    .tag(MainTab.settings)
                    .toolbarBackground(.ultraThinMaterial, for: .tabBar)
            }
            .tint(Theme.titleDenim)
            .scrollContentBackground(.hidden)
            .onAppear {
                if let index = notificationRouter.pendingTabIndex {
                    selectedTab = index
                    notificationRouter.pendingTabIndex = nil
                }
            }
            .onChange(of: notificationRouter.pendingTabIndex) { _, newValue in
                guard let index = newValue else { return }
                selectedTab = index
                notificationRouter.pendingTabIndex = nil
            }
        }
    }
}

#Preview {
    MainTabView(viewModel: QuestViewModel(), notificationRouter: NotificationTapRouter())
}

