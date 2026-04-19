//
//  MainTabView.swift
//  DailyAdventure
//
//  Created by Henrique Bernardes on 19/04/26.
//


import SwiftUI

struct MainTabView: View {
    var viewModel: QuestViewModel
    
    var body: some View {
        TabView {
            ContentView(viewModel: viewModel)
                .tabItem {
                    Label("Today", systemImage: "star.fill")
                }
            
            ProgressTabView(viewModel: viewModel)
                .tabItem {
                    Label("Progress", systemImage: "chart.pie.fill")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .tint(Theme.titleDenim)
    }
}

#Preview {
    MainTabView(viewModel: QuestViewModel())
}
