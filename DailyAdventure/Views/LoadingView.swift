//
//  LoadingView.swift
//  DailyAdventure
//
//  Created by Henrique Bernardes on 19/04/26.
//


import SwiftUI

struct LoadingView: View {
    @State private var isAnimating = false
    @State private var opacity: Double = 0
    @State private var scale: CGFloat = 0.6
    
    var body: some View {
        ZStack {
            AnimatedBackgroundView()
            
            VStack(spacing: Theme.Spacing.large) {
                // MARK: - App Icon animado
                ZStack {
                    // Retângulos pulsando ao redor do ícone
                    RoundedRectangle(cornerRadius: 34)
                        .fill(Theme.titleDenim.opacity(0.1))
                        .frame(width: 160, height: 160)
                        .scaleEffect(isAnimating ? 1.2 : 0.9)
                    
                    RoundedRectangle(cornerRadius: 38)
                        .fill(Theme.titleDenim.opacity(0.05))
                        .frame(width: 190, height: 190)
                        .scaleEffect(isAnimating ? 1.3 : 0.8)
                    
                    // App Icon
                    Image("appIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 27))
                        .shadow(color: Theme.titleDenim.opacity(0.3), radius: 20, x: 0, y: 10)
                        .scaleEffect(isAnimating ? 1.05 : 0.95)
                }
                
                // Loading dots
                HStack(spacing: Theme.Spacing.small) {
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(Theme.titleDenim)
                            .frame(width: 8, height: 8)
                            .scaleEffect(isAnimating ? 1.0 : 0.5)
                            .opacity(isAnimating ? 1.0 : 0.3)
                            .animation(
                                .easeInOut(duration: 0.6)
                                .repeatForever(autoreverses: true)
                                .delay(Double(index) * 0.2),
                                value: isAnimating
                            )
                    }
                }
            }
            .opacity(opacity)
            .scaleEffect(scale)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                opacity = 1
                scale = 1
            }
            
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}

#Preview {
    LoadingView()
}
