//
//  VictoryView.swift
//  DailyAdventure
//
//  Created by Henrique Bernardes on 19/04/26.
//


import SwiftUI

struct VictoryView: View {
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    @State private var backgroundOpacity: Double = 0
    @State private var isAnimating = false
    @State private var particleScale: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Background escuro
            Color.black
                .opacity(backgroundOpacity * 0.7)
                .ignoresSafeArea()
            
            // Background animado especial
            MeshGradient(
                width: 3,
                height: 3,
                points: [
                    [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
                    [0.0, 0.5], [isAnimating ? 0.8 : 0.2, 0.5], [1.0, 0.5],
                    [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]
                ],
                colors: [
                    Theme.workBlue.opacity(0.8), Theme.titleDenim.opacity(0.8), Theme.workBlue.opacity(0.8),
                    Theme.healthGreen.opacity(0.8), Theme.titleDenim.opacity(0.6), Theme.healthRose.opacity(0.8),
                    Theme.workBlue.opacity(0.8), Theme.titleDenim.opacity(0.8), Theme.workBlue.opacity(0.8)
                ]
            )
            .opacity(backgroundOpacity * 0.5)
            .ignoresSafeArea()
            
            // Partículas
            ZStack {
                ForEach(0..<12) { index in
                    ParticleView(index: index)
                        .scaleEffect(particleScale)
                        .opacity(backgroundOpacity)
                }
            }
            
            // Conteúdo principal
            VStack(spacing: Theme.Spacing.large) {
                // Emojis animados
                HStack(spacing: Theme.Spacing.medium) {
                    Text("⚔️")
                        .font(.system(size: 40))
                        .rotationEffect(.degrees(isAnimating ? -15 : 15))
                    
                    Text("🏰")
                        .font(.system(size: 56))
                        .scaleEffect(isAnimating ? 1.1 : 0.9)
                    
                    Text("⚔️")
                        .font(.system(size: 40))
                        .rotationEffect(.degrees(isAnimating ? 15 : -15))
                }
                
                VStack(spacing: Theme.Spacing.small) {
                    Text("Adventure Complete!")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("You conquered today's quests!")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                
                // Stars
                HStack(spacing: Theme.Spacing.small) {
                    ForEach(0..<5) { index in
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.system(size: 24))
                            .scaleEffect(isAnimating ? 1.2 : 0.8)
                            .animation(
                                .spring(response: 0.4, dampingFraction: 0.6)
                                .delay(Double(index) * 0.1),
                                value: isAnimating
                            )
                    }
                }
            }
            .padding(Theme.Spacing.large)
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            // Animação de entrada
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                scale = 1.0
                opacity = 1.0
                backgroundOpacity = 1.0
                particleScale = 1.0
            }
            
            // Animação contínua
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}

struct ParticleView: View {
    let index: Int
    @State private var isAnimating = false
    
    var angle: Double {
        Double(index) * (360.0 / 12.0)
    }
    
    var color: Color {
        let colors: [Color] = [
            Theme.workBlue, Theme.healthGreen, Theme.healthRose,
            Theme.titleDenim, .yellow, .white
        ]
        return colors[index % colors.count]
    }
    
    var body: some View {
        Circle()
            .fill(color)
            .frame(width: CGFloat.random(in: 6...14), height: CGFloat.random(in: 6...14))
            .offset(x: isAnimating ? cos(angle * .pi / 180) * 160 : 0,
                    y: isAnimating ? sin(angle * .pi / 180) * 160 : 0)
            .opacity(isAnimating ? 0 : 1)
            .onAppear {
                withAnimation(
                    .easeOut(duration: Double.random(in: 1.0...2.0))
                    .repeatForever(autoreverses: false)
                    .delay(Double.random(in: 0...0.5))
                ) {
                    isAnimating = true
                }
            }
    }
}

#Preview {
    VictoryView()
}
