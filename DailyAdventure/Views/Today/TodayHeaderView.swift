//
//  TodayHeaderView.swift
//  DailyAdventure
//

import SwiftUI

/// Estado do dia que define o que o header mostra.
enum TodayPhase {
    case empty       // nenhuma quest ainda
    case inProgress  // há quests, nem todas concluídas
    case complete    // 100% concluído

    init(adventure: DailyAdventure) {
        if !adventure.hasAnyQuest {
            self = .empty
        } else if adventure.completionLevel == .complete {
            self = .complete
        } else {
            self = .inProgress
        }
    }
}

struct TodayHeaderView: View {
    let phase: TodayPhase
    let completedCount: Int
    let totalCount: Int
    let progress: Double
    let daysAdventured: Int
    @AppStorage(UserProfile.nameKey) private var userName = ""

    var body: some View {
        switch phase {
        case .empty:
            VStack(alignment: .leading, spacing: 10) {
                eyebrow
                greeting
                    .font(.greeting)
                    .foregroundStyle(Theme.inkSecondary)
                Text("What's today's adventure?")
                    .font(.screenTitle)
                    .foregroundStyle(Theme.ink)
                    .accessibilityAddTraits(.isHeader)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

        case .inProgress:
            HStack(alignment: .center, spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    eyebrow
                    greeting
                        .font(.screenTitleCompact)
                        .foregroundStyle(Theme.ink)
                        .accessibilityAddTraits(.isHeader)
                    Text("\(completedCount) of \(totalCount) quests done")
                        .font(.supporting)
                        .foregroundStyle(Theme.inkSecondary)
                }
                Spacer(minLength: 0)
                ProgressRing(progress: progress, tint: Theme.accent, size: 64) {
                    Text("\(Int(progress * 100))%")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(Theme.ink)
                }
            }

        case .complete:
            VStack(spacing: 12) {
                eyebrow
                ProgressRing(progress: 1, tint: Theme.goldComplete, size: 96) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 38))
                        .foregroundStyle(Theme.goldComplete)
                }
                Text("Day complete.")
                    .font(.screenTitle)
                    .foregroundStyle(Theme.ink)
                    .accessibilityAddTraits(.isHeader)
                Text("\(completedCount) of \(totalCount) quests · \(daysAdventured) days of adventure")
                    .font(.supporting)
                    .foregroundStyle(Theme.inkSecondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Data

    private var eyebrow: some View {
        SectionLabel(verbatim: Date().formatted(.dateTime.weekday(.wide).day().month(.wide)))
    }

    private var greeting: Text {
        let name = UserProfile.sanitized(userName)
        switch Calendar.current.component(.hour, from: Date()) {
        case 5..<12: return name.isEmpty ? Text("Good morning.") : Text("Good morning, \(name).")
        case 12..<18: return name.isEmpty ? Text("Good afternoon.") : Text("Good afternoon, \(name).")
        default: return name.isEmpty ? Text("Good evening.") : Text("Good evening, \(name).")
        }
    }
}
