//
//  MainTabView.swift
//  DailyAdventure
//
//  Created by Henrique Bernardes on 19/04/26.
//


import SwiftUI

struct MainTabView: View {
    var viewModel: QuestViewModel
    @State private var selectedTab = 1 // ✅ Começa na tab Today (índice 1)
    
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
                    .tag(0)
                    .toolbarBackground(.ultraThinMaterial, for: .tabBar)
                
                // MARK: - Today Tab (centro - tab inicial)
                ContentView(viewModel: viewModel)
                    .tabItem {
                        Label("Today", systemImage: "star.fill")
                    }
                    .tag(1) // ✅ selectedTab começa em 1
                    .toolbarBackground(.ultraThinMaterial, for: .tabBar)
                
                // MARK: - Progress Tab
                ProgressTabView(viewModel: viewModel)
                    .tabItem {
                        Label("Progress", systemImage: "chart.pie.fill")
                    }
                    .tag(2)
                    .toolbarBackground(.ultraThinMaterial, for: .tabBar)
                
                // MARK: - Settings Tab (direita)
                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gearshape.fill")
                    }
                    .tag(3)
                    .toolbarBackground(.ultraThinMaterial, for: .tabBar)
            }
            .tint(Theme.titleDenim)
            .scrollContentBackground(.hidden)
        }
    }
}

#Preview {
    MainTabView(viewModel: QuestViewModel())
}

