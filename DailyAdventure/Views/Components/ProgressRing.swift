//
//  ProgressRing.swift
//  DailyAdventure
//

import SwiftUI

struct ProgressRing<Center: View>: View {
    let progress: Double
    let tint: Color
    let size: CGFloat
    @ViewBuilder var center: Center

    var body: some View {
        ZStack {
            Circle()
                .stroke(Theme.separator, lineWidth: size * 0.1)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(tint, style: StrokeStyle(lineWidth: size * 0.1, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: progress)
            center
        }
        .frame(width: size, height: size)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("\(Int(progress * 100))% of the day complete"))
    }
}
