//
//  VictoryView.swift
//  DailyAdventure
//
//  Created by Henrique Bernardes on 19/04/26.
//


import SwiftUI

/// Celebração exibida quando todas as quests do dia são concluídas.
/// Usa a mesma linguagem dourada do card de aventura concluída da Today.
/// Com Reduzir Movimento ativo, vira um fade simples sem confete nem rotação.
struct VictoryView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var start = Date()
    @State private var cardIn = false
    @State private var trophyIn = false
    @State private var textStep = 0
    @State private var wiggle = false

    var body: some View {
        ZStack {
            Color.black
                .opacity(cardIn ? 0.5 : 0)
                .ignoresSafeArea()

            if !reduceMotion {
                ConfettiRain(start: start)
                    .accessibilityHidden(true)
            }

            card
        }
        .onAppear(perform: animateIn)
    }

    private var card: some View {
        VStack(spacing: Theme.Spacing.medium) {
            trophy
                .padding(.bottom, Theme.Spacing.small)

            VStack(spacing: Theme.Spacing.small) {
                SectionLabel("Day complete", color: Theme.goldText)
                    .modifier(RiseIn(visible: textStep >= 1, reduceMotion: reduceMotion))

                Text("Adventure Complete!")
                    .font(.screenTitleCompact)
                    .foregroundStyle(Theme.ink)
                    .multilineTextAlignment(.center)
                    .modifier(RiseIn(visible: textStep >= 2, reduceMotion: reduceMotion))

                Text("You conquered today's quests!")
                    .font(.supporting)
                    .foregroundStyle(Theme.inkSecondary)
                    .multilineTextAlignment(.center)
                    .modifier(RiseIn(visible: textStep >= 3, reduceMotion: reduceMotion))
            }

            Text("Tap to continue")
                .font(.label)
                .foregroundStyle(Theme.goldText)
                .padding(.top, Theme.Spacing.small)
                .opacity(textStep >= 4 ? 1 : 0)
        }
        .padding(.vertical, 32)
        .padding(.horizontal, Theme.Spacing.large)
        .frame(maxWidth: 340)
        .background(Theme.goldSurface, in: RoundedRectangle(cornerRadius: Theme.Radius.card))
        .shadow(color: .black.opacity(0.2), radius: 28, y: 14)
        .padding(.horizontal, Theme.Spacing.large)
        .scaleEffect(cardIn || reduceMotion ? 1 : 0.6)
        .opacity(cardIn ? 1 : 0)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isModal)
        .accessibilityHint(Text("Tap to continue"))
    }

    private var trophy: some View {
        ZStack {
            if !reduceMotion {
                SunburstRays()
                    .opacity(trophyIn ? 1 : 0)
                    .scaleEffect(trophyIn ? 1 : 0.3)

                TwinklingStars()
                    .opacity(trophyIn ? 1 : 0)
            }

            Image(systemName: "trophy.fill")
                .font(.system(size: 42, weight: .semibold))
                // Ícone escuro fixo: o círculo dourado é igual no claro e no escuro.
                .foregroundStyle(Color(hex: "1D3550"))
                .frame(width: 92, height: 92)
                .background(Theme.goldComplete, in: Circle())
                .shadow(color: Theme.goldComplete.opacity(0.6), radius: trophyIn ? 18 : 0)
                .rotationEffect(.degrees(trophyIn ? (wiggle ? 6 : -6) : -40))
                .scaleEffect(trophyIn || reduceMotion ? 1 : 0.2)
        }
        .frame(width: 150, height: 120)
        .accessibilityHidden(true)
    }

    private func animateIn() {
        start = Date()
        guard !reduceMotion else {
            withAnimation(.easeOut(duration: 0.25)) {
                cardIn = true
                trophyIn = true
                textStep = 4
            }
            return
        }

        withAnimation(.spring(response: 0.45, dampingFraction: 0.62)) {
            cardIn = true
        }
        withAnimation(.spring(response: 0.55, dampingFraction: 0.45).delay(0.15)) {
            trophyIn = true
        }
        withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true).delay(0.75)) {
            wiggle = true
        }
        for step in 1...4 {
            let delay = step == 4 ? 1.1 : 0.3 + Double(step) * 0.12
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
                    textStep = step
                }
            }
        }
    }
}

// MARK: - Entrada dos textos

private struct RiseIn: ViewModifier {
    let visible: Bool
    let reduceMotion: Bool

    func body(content: Content) -> some View {
        content
            .opacity(visible ? 1 : 0)
            .offset(y: visible || reduceMotion ? 0 : 14)
    }
}

// MARK: - Raios atrás do troféu

private struct SunburstRays: View {
    @State private var rotating = false

    var body: some View {
        ZStack {
            ForEach(0..<14, id: \.self) { index in
                Capsule()
                    .fill(Theme.goldComplete.opacity(0.5))
                    .frame(width: index.isMultiple(of: 2) ? 9 : 5, height: 70)
                    .offset(y: -62)
                    .rotationEffect(.degrees(Double(index) / 14 * 360))
            }
        }
        .frame(width: 220, height: 220)
        .mask(
            RadialGradient(colors: [.black, .black.opacity(0)], center: .center, startRadius: 40, endRadius: 105)
        )
        .rotationEffect(.degrees(rotating ? 360 : 0))
        .onAppear {
            withAnimation(.linear(duration: 16).repeatForever(autoreverses: false)) {
                rotating = true
            }
        }
    }
}

// MARK: - Estrelinhas piscando

private struct TwinklingStars: View {
    @State private var twinkle = false

    private let stars: [(x: CGFloat, y: CGFloat, size: CGFloat, delay: Double)] = [
        (-66, -34, 14, 0.0),
        (64, -42, 11, 0.35),
        (72, 28, 13, 0.7),
        (-70, 36, 10, 0.5),
        (0, -60, 9, 0.9)
    ]

    var body: some View {
        ZStack {
            ForEach(stars.indices, id: \.self) { index in
                let star = stars[index]
                Image(systemName: "star.fill")
                    .font(.system(size: star.size))
                    .foregroundStyle(Theme.goldComplete)
                    .scaleEffect(twinkle ? 1 : 0.3)
                    .opacity(twinkle ? 1 : 0.2)
                    .offset(x: star.x, y: star.y)
                    .animation(
                        .easeInOut(duration: 0.7).repeatForever(autoreverses: true).delay(star.delay),
                        value: twinkle
                    )
            }
        }
        .onAppear { twinkle = true }
    }
}

// MARK: - Chuva de confete

private struct ConfettiParticle {
    let x: Double
    let delay: Double
    let speed: Double
    let width: Double
    let height: Double
    let colorIndex: Int
    let spin: Double
    let flip: Double
    let swayAmplitude: Double
    let swayFrequency: Double
    let phase: Double
    let isCircle: Bool

    static func random() -> ConfettiParticle {
        let isCircle = Double.random(in: 0...1) < 0.25
        let width = isCircle ? Double.random(in: 6...9) : Double.random(in: 7...11)
        return ConfettiParticle(
            x: .random(in: 0...1),
            delay: .random(in: 0...1.2),
            speed: .random(in: 170...330),
            width: width,
            height: isCircle ? width : Double.random(in: 4...6),
            colorIndex: .random(in: 0..<4),
            spin: .random(in: -4...4),
            flip: .random(in: 3...8),
            swayAmplitude: .random(in: 8...26),
            swayFrequency: .random(in: 1.5...3.5),
            phase: .random(in: 0...(2 * .pi)),
            isCircle: isCircle
        )
    }
}

/// Confete caindo do topo, girando e balançando. Desenhado num único `Canvas` para ficar leve.
private struct ConfettiRain: View {
    let start: Date
    @State private var particles = (0..<80).map { _ in ConfettiParticle.random() }

    private var palette: [Color] {
        [Theme.goldComplete, QuestCategory.work.color, QuestCategory.health.color, QuestCategory.relationship.color]
    }

    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let elapsed = timeline.date.timeIntervalSince(start)
                let travel = size.height + 60
                let colors = palette

                for particle in particles {
                    let local = elapsed - particle.delay
                    guard local > 0 else { continue }

                    let y = (local * particle.speed).truncatingRemainder(dividingBy: travel) - 30
                    let x = particle.x * size.width
                        + sin(local * particle.swayFrequency + particle.phase) * particle.swayAmplitude

                    var piece = context
                    piece.translateBy(x: x, y: y)
                    piece.rotate(by: .radians(local * particle.spin))
                    // Achata no eixo x para parecer que o papel está virando no ar.
                    piece.scaleBy(x: max(0.15, abs(cos(local * particle.flip))), y: 1)

                    let rect = CGRect(
                        x: -particle.width / 2, y: -particle.height / 2,
                        width: particle.width, height: particle.height
                    )
                    let path = particle.isCircle
                        ? Path(ellipseIn: rect)
                        : Path(roundedRect: rect, cornerRadius: 1.5)
                    piece.fill(path, with: .color(colors[particle.colorIndex]))
                }
            }
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }
}

#Preview {
    VictoryView()
}
