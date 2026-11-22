//
//  Chips.swift
//  DailyAdventure
//

import SwiftUI

struct SuggestionChip: View {
    let title: String
    var dotColor: Color? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let dotColor {
                    Circle().fill(dotColor).frame(width: 8, height: 8)
                }
                Text(title)
                    .font(.supporting)
                    .foregroundStyle(Theme.ink)
            }
            .padding(.horizontal, 14)
            .frame(minHeight: 44)
            .background(Theme.cardBackground, in: Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityHint("Adds this quest")
    }
}

struct ShuffleButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label("More", systemImage: "shuffle")
                .font(.supporting.weight(.semibold))
                .foregroundStyle(Theme.accent)
                .frame(minHeight: 44)
        }
        .accessibilityLabel("Other suggestions")
    }
}
