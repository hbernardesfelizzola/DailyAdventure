//
//  AnimatedBackgroundView.swift
//  DailyAdventure
//
//  Created by Henrique Bernardes on 19/04/26.
//


import SwiftUI

/// Fundo 60:30:10 — creme como base, brilho azul no canto superior direito e verde no inferior esquerdo.
/// As cores são pré-misturadas com a base (em vez de opacidade) para o MeshGradient não depender do que está atrás.
struct AnimatedBackgroundView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @AppStorage("isHighContrast") private var isHighContrast = false
    @State private var animate = false

    // Ordem: linha a linha, de cima para baixo (TL, TC, TR, ML, MC, MR, BL, BC, BR).
    private var lightColors: [Color] {
        let cream = Color(hex: "FBF6E3")
        return [
            cream, Color(hex: "E1DFE4"), Color(hex: "C6C7E5"),
            cream, cream, Color(hex: "E1DFE4"),
            Color(hex: "AFDEB6"), Color(hex: "D5EACD"), cream
        ]
    }

    private var darkColors: [Color] {
        let navy = Color(hex: "011936")
        return [
            navy, Color(hex: "132954"), Color(hex: "243872"),
            navy, navy, Color(hex: "132954"),
            Color(hex: "14404A"), Color(hex: "0B2D40"), navy
        ]
    }

    private var points: [SIMD2<Float>] {
        [
            [0.0, 0.0], [animate ? 0.35 : 0.55, 0.0], [1.0, 0.0],
            [0.0, animate ? 0.6 : 0.45], [animate ? 0.6 : 0.42, animate ? 0.55 : 0.45], [1.0, animate ? 0.65 : 0.4],
            [0.0, 1.0], [animate ? 0.65 : 0.45, 1.0], [1.0, 1.0]
        ]
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
                    points: points,
                    colors: colorScheme == .dark ? darkColors : lightColors
                )
                .ignoresSafeArea()
            }
        }
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 5).repeatForever(autoreverses: true)) {
                animate = true
            }
        }
    }
}

#Preview {
    AnimatedBackgroundView()
}
