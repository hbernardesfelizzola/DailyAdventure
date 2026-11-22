//
//  DayFeedbackCard.swift
//  DailyAdventure
//

import SwiftUI

/// "Como foi o dia?" — aparece na Today quando o dia é concluído.
struct DayFeedbackCard: View {
    let feedback: DayFeedback
    let onSelect: (DayFeedback) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("How was this day?")
                .font(.cardTitle)
                .foregroundStyle(Theme.ink)
                .accessibilityAddTraits(.isHeader)

            HStack(spacing: 8) {
                ForEach(DayFeedback.selectable, id: \.self) { value in
                    option(value, title: value.title, icon: value.icon ?? "", tint: value.tint)
                }
            }
        }
        .padding(20)
        .cardSurface()
    }

    private func option(_ value: DayFeedback, title: LocalizedStringKey, icon: String, tint: Color) -> some View {
        let isSelected = feedback == value
        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                onSelect(isSelected ? .none : value)
            }
        } label: {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(isSelected ? tint : Theme.inkSecondary)
                    .scaleEffect(isSelected ? 1.15 : 1)
                Text(title)
                    .font(.label)
                    .foregroundStyle(isSelected ? Theme.ink : Theme.inkSecondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity, minHeight: 72)
            .background(tint.opacity(isSelected ? 0.2 : 0.08), in: RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(tint, lineWidth: isSelected ? 1.5 : 0)
            )
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
