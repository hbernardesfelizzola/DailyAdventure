//
//  ContentView.swift
//  DailyAdventure
//
//  Created by Henrique Bernardes on 09/02/26.
//

import SwiftUI

struct ContentView: View {
    
    private var dailyAdventure: String = "What would you like to do today?"
    
    var body: some View {
        VStack{
            Text("What's your daily adventure?")
                .font(.headline)
                .padding()
            TextField("Daily Adventure", text: .constant(dailyAdventure))
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
