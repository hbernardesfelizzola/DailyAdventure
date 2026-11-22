//
//  LoadingView.swift
//  DailyAdventure
//
//  Created by Henrique Bernardes on 19/04/26.
//


import SwiftUI

struct LoadingView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var appeared = false
    @State private var isPulsing = false

    var body: some View {
        ZStack {
            AnimatedBackgroundView()

            VStack(spacing: Theme.Spacing.large) {
                // MARK: - Ícone com halo pulsando
                ZStack {
                    RoundedRectangle(cornerRadius: 44)
                        .fill(Theme.accent.opacity(0.08))
                        .frame(width: 184, height: 184)
                        .scaleEffect(isPulsing ? 1.06 : 0.94)

                    RoundedRectangle(cornerRadius: 36)
                        .fill(Theme.accent.opacity(0.12))
                        .frame(width: 152, height: 152)

                    Image("appIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 27))
                        .shadow(color: Theme.ink.opacity(0.15), radius: 16, y: 8)
                }
                .accessibilityHidden(true)

                Text(verbatim: "DailyAdventure")
                    .font(.screenTitleCompact)
                    .foregroundStyle(Theme.ink)

                // MARK: - Pontos de carregamento
                HStack(spacing: Theme.Spacing.small) {
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(Theme.accent)
                            .frame(width: 8, height: 8)
                            .opacity(isPulsing ? 1 : 0.3)
                            .animation(
                                reduceMotion ? nil : .easeInOut(duration: 0.6)
                                    .repeatForever(autoreverses: true)
                                    .delay(Double(index) * 0.2),
                                value: isPulsing
                            )
                    }
                }
                .accessibilityHidden(true)
            }
            .opacity(appeared ? 1 : 0)
            .scaleEffect(appeared || reduceMotion ? 1 : 0.9)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text("Loading"))
        }
        .onAppear {
            withAnimation(reduceMotion ? .easeOut(duration: 0.2) : .spring(response: 0.6, dampingFraction: 0.8)) {
                appeared = true
            }
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                isPulsing = true
            }
        }
    }
}

#Preview {
    LoadingView()
}
