//
//  CompletedQuestRow.swift
//  DailyAdventure
//
//  Created by Henrique Bernardes on 19/04/26.
//

import SwiftUI

struct CompletedQuestRow: View {
    let quest: Quest
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: Theme.Spacing.small) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(quest.isMainQuest ? Theme.titleDenim : (quest.category?.color ?? Theme.titleDenim))
                .font(.system(size: 18))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(quest.title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Theme.titleDenim)
                
                Text(quest.isMainQuest ? "Main Quest" : (quest.category?.rawValue ?? "Quest"))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Theme.titleDenim.opacity(0.8))
            }
            
            Spacer()
            
            Button(action: onRemove) {
                Image(systemName: "arrow.uturn.backward.circle.fill")
                    .foregroundColor(Theme.titleDenim.opacity(0.6))
                    .font(.system(size: 18))
            }
        }
        .padding(Theme.Spacing.small)
        .background(
            quest.isMainQuest ?
            Theme.titleDenim.opacity(0.15) :
            (quest.category?.color.opacity(0.15) ?? Theme.titleDenim.opacity(0.15))
        )
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusSmall))
        .glassEffectIfAvailable(cornerRadius: Theme.cornerRadiusSmall)
    }
}
