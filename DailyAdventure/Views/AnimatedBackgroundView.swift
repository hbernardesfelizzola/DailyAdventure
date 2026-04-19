//
//  AnimatedBackgroundView.swift
//  DailyAdventure
//
//  Created by Henrique Bernardes on 19/04/26.
//


import SwiftUI

struct AnimatedBackgroundView: View {
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("isHighContrast") private var isHighContrast = false
    @State private var animate = false
    
    var darkColors: [Color] {
        [
            Color(hex: "011936"), Color(hex: "0D2847"), Color(hex: "011936"),
            Color(hex: "0D2847"), Theme.titleDenim.opacity(0.3), Theme.workBlue.opacity(0.2),
            Color(hex: "011936"), Theme.workBlue.opacity(0.15), Color(hex: "011936")
        ]
    }
    
    var lightColors: [Color] {
        [
            Theme.backgroundVanilla, Theme.relationshipCeladon, Theme.backgroundVanilla,
            Theme.relationshipCeladon, Theme.titleDenim.opacity(0.3), Theme.workBlue.opacity(0.3),
            Theme.backgroundVanilla, Theme.workBlue.opacity(0.2), Theme.backgroundVanilla
        ]
    }
    
    var highContrastColors: [Color] {
        colorScheme == .dark ? [
            Color.black, Color.black, Color.black,
            Color.black, Color.black, Color.black,
            Color.black, Color.black, Color.black
        ] : [
            Color.white, Color.white, Color.white,
            Color.white, Color.white, Color.white,
            Color.white, Color.white, Color.white
        ]
    }
    
    var currentColors: [Color] {
        if isHighContrast {
            return highContrastColors
        }
        return colorScheme == .dark ? darkColors : lightColors
    }
    
    var body: some View {
        ZStack {
            if isHighContrast {
                Theme.background
                    .ignoresSafeArea()
            } else {
                MeshGradient(
                    width: 3,
                    height: 3,
                    points: [
                        [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
                        [0.0, 0.5], [animate ? 0.7 : 0.3, 0.5], [1.0, 0.5],
                        [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]
                    ],
                    colors: currentColors
                )
                .ignoresSafeArea()
                
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .opacity(0.3)
                    .ignoresSafeArea()
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                animate = true
            }
        }
    }
}

#Preview {
    AnimatedBackgroundView()
}
