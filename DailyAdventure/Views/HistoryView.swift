//
//  HistoryView.swift
//  DailyAdventure
//
//  Created by Henrique Bernardes on 25/04/26.
//


import SwiftUI

struct HistoryView: View {
    var viewModel: QuestViewModel
    @State private var selectedAdventure: DailyAdventure? = nil

    var allDays: [DailyAdventure] {
        let cal = Calendar.current
        let today = viewModel.todayAdventure
        var days = viewModel.history.filter { entry in
            !cal.isDate(entry.date, inSameDayAs: today.date)
        }
        if today.shouldArchiveToAdventureLog {
            days.insert(today, at: 0)
        }
        return days
    }

    var body: some View {
        ZStack {
            AnimatedBackgroundView()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: Theme.Spacing.large) {
                    // MARK: - Header
                    VStack(spacing: Theme.Spacing.small) {
                        HStack(spacing: Theme.Spacing.medium) {
                            Image(systemName: "book.fill")
                                .font(.system(size: 26))
                                .foregroundColor(Theme.titleDenim)
                                .frame(width: 56, height: 56)
                                .background(Theme.titleDenim.opacity(0.1))
                                .clipShape(Circle())
                                .glassEffectCircleIfAvailable()

                            Text("Adventure Log")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(Theme.titleDenim)
                        }

                        HStack(spacing: 6) {
                            Image(systemName: "shield.fill")
                                .font(.system(size: 13))
                                .foregroundColor(Theme.titleDenim.opacity(0.7))
                            Text("\(viewModel.totalDaysAdventured) days of adventure")
                                .font(.footnote)
                                .fontWeight(.semibold)
                                .foregroundColor(Theme.titleDenim)
                        }
                        .padding(.horizontal, Theme.Spacing.medium)
                        .padding(.vertical, Theme.Spacing.small)
                        .background(Theme.titleDenim.opacity(0.1))
                        .clipShape(Capsule())
                        .glassEffectCapsuleIfAvailable()
                    }
                    .padding(.top, Theme.Spacing.large)

                    // MARK: - Lista de dias
                    if allDays.isEmpty {
                        VStack(spacing: Theme.Spacing.medium) {
                            Text("📜")
                                .font(.system(size: 48))

                            Text("No adventures yet!")
                                .font(.headline)
                                .foregroundColor(Theme.titleDenim)

                            Text("Start your first adventure today!")
                                .font(.subheadline)
                                .foregroundColor(Theme.titleDenim.opacity(0.8))
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(Theme.Spacing.large)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
                        .glassEffectIfAvailable()
                        .padding(.horizontal, Theme.Spacing.medium)
                    } else {
                        VStack(spacing: Theme.Spacing.small) {
                            ForEach(allDays) { adventure in
                                AdventureHistoryRow(
                                    adventure: adventure,
                                    isSelected: selectedAdventure?.id == adventure.id,
                                    onTap: {
                                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                            if selectedAdventure?.id == adventure.id {
                                                selectedAdventure = nil
                                            } else {
                                                selectedAdventure = adventure
                                            }
                                        }
                                    },
                                    onFeedback: { feedback in
                                        viewModel.updateFeedback(feedback, for: adventure)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, Theme.Spacing.medium)
                    }

                    Spacer()
                        .frame(height: 100)
                }
            }
            .frame(maxWidth: .infinity)
            .scrollEdgeEffectIfAvailable()
        }
    }
}

// MARK: - AdventureHistoryRow
struct AdventureHistoryRow: View {
    let adventure: DailyAdventure
    let isSelected: Bool
    let onTap: () -> Void
    let onFeedback: (DayFeedback) -> Void

    var dateLabel: String {
        if Calendar.current.isDateInToday(adventure.date) {
            return "Today"
        } else if Calendar.current.isDateInYesterday(adventure.date) {
            return "Yesterday"
        } else {
            let sameYear = Calendar.current.isDate(adventure.date, equalTo: Date(), toGranularity: .year)
            if sameYear {
                return adventure.date.formatted(.dateTime.weekday(.wide).day().month())
            } else {
                return adventure.date.formatted(.dateTime.weekday(.wide).day().month().year())
            }
        }
    }

    var completionColor: Color {
        switch adventure.completionLevel {
        case .complete: return Color(hex: "F5C518") // dourado
        case .partial:  return Theme.workBlue
        case .empty:    return Theme.titleDenim.opacity(0.3)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Row principal
            Button(action: onTap) {
                HStack(spacing: Theme.Spacing.medium) {
                    // Indicador de completion
                    ZStack {
                        Circle()
                            .fill(completionColor.opacity(0.2))
                            .frame(width: 44, height: 44)

                        switch adventure.completionLevel {
                        case .complete:
                            Image(systemName: "star.fill")
                                .foregroundColor(completionColor)
                                .font(.system(size: 18, weight: .bold))
                        case .partial:
                            Text("\(Int(adventure.completionPercentage * 100))%")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(completionColor)
                        case .empty:
                            Image(systemName: "minus")
                                .foregroundColor(Theme.titleDenim.opacity(0.3))
                                .font(.system(size: 14))
                        }
                    }
                    .glassEffectCircleIfAvailable()

                    // Info do dia
                    VStack(alignment: .leading, spacing: 4) {
                        Text(dateLabel)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(Theme.titleDenim)

                        if adventure.mainQuest.isEmpty {
                            Text("No main quest set")
                                .font(.caption)
                                .foregroundColor(Theme.titleDenim.opacity(0.5))
                                .italic()
                        } else {
                            Text(adventure.mainQuest)
                                .font(.caption)
                                .foregroundColor(Theme.titleDenim.opacity(0.8))
                                .lineLimit(1)
                        }
                    }

                    Spacer()

                    // Feedback badge
                    if adventure.feedback != .none {
                        Image(systemName: adventure.feedback == .positive ? "hand.thumbsup.fill" : adventure.feedback == .negative ? "hand.thumbsdown.fill" : "minus.circle.fill")
                            .foregroundColor(adventure.feedback == .positive ? Theme.healthColor : adventure.feedback == .negative ? Theme.healthRose : Color(hex: "F59E0B"))
                            .font(.system(size: 16))
                    }

                    Image(systemName: isSelected ? "chevron.up" : "chevron.down")
                        .foregroundColor(Theme.titleDenim.opacity(0.5))
                        .font(.system(size: 12, weight: .semibold))
                }
                .padding(Theme.Spacing.medium)
            }

            // MARK: - Conteúdo expandido
            if isSelected {
                VStack(spacing: Theme.Spacing.medium) {
                    Divider()
                        .padding(.horizontal, Theme.Spacing.medium)

                    // Quests do dia
                    if adventure.hasAnyQuest {
                        VStack(alignment: .leading, spacing: Theme.Spacing.small) {
                            // Main Quest
                            if !adventure.mainQuest.isEmpty {
                                let mainCompleted = adventure.completedQuests.contains(where: { $0.isMainQuest })
                                HStack(spacing: Theme.Spacing.small) {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(Theme.titleDenim)
                                        .font(.system(size: 12))
                                        .frame(width: 20)

                                    Text(adventure.mainQuest)
                                        .font(.footnote)
                                        .fontWeight(.medium)
                                        .foregroundColor(Theme.titleDenim)

                                    Spacer()

                                    Image(systemName: mainCompleted ? "checkmark.circle.fill" : "xmark.circle.fill")
                                        .foregroundColor(mainCompleted ? Theme.healthColor : Theme.titleDenim.opacity(0.3))
                                        .font(.system(size: 14))
                                }
                            }

                            // Side Quests (sorted: work → health → relationship)
                            let sortedSideQuests = adventure.sideQuests.sorted { a, b in
                                func order(_ cat: QuestCategory?) -> Int {
                                    switch cat {
                                    case .work: return 0
                                    case .health: return 1
                                    case .relationship: return 2
                                    case nil: return 3
                                    }
                                }
                                return order(a.category) < order(b.category)
                            }
                            ForEach(sortedSideQuests) { quest in
                                let completed = adventure.completedQuests.contains(where: { $0.id == quest.id })
                                HStack(spacing: Theme.Spacing.small) {
                                    Image(systemName: quest.category?.icon ?? "diamond.fill")
                                        .foregroundColor(quest.category?.color ?? Theme.titleDenim)
                                        .font(.system(size: 12))
                                        .frame(width: 20)

                                    Text(quest.title)
                                        .font(.footnote)
                                        .foregroundColor(Theme.titleDenim.opacity(0.8))

                                    Spacer()

                                    Image(systemName: completed ? "checkmark.circle.fill" : "xmark.circle.fill")
                                        .foregroundColor(completed ? Theme.healthColor : Theme.titleDenim.opacity(0.3))
                                        .font(.system(size: 14))
                                }
                            }
                        }
                        .padding(.horizontal, Theme.Spacing.medium)
                    } else {
                        Text("No quests recorded for this day")
                            .font(.footnote)
                            .foregroundColor(Theme.titleDenim.opacity(0.5))
                            .italic()
                            .padding(.horizontal, Theme.Spacing.medium)
                    }

                    Divider()
                        .padding(.horizontal, Theme.Spacing.medium)

                    // MARK: - Feedback
                    VStack(spacing: Theme.Spacing.small) {
                        Text("How was this day?")
                            .font(.footnote)
                            .fontWeight(.semibold)
                            .foregroundColor(Theme.titleDenim.opacity(0.8))

                        HStack(spacing: Theme.Spacing.medium) {
                            // Thumbs Up
                            Button(action: {
                                withAnimation {
                                    onFeedback(adventure.feedback == .positive ? .none : .positive)
                                }
                            }) {
                                VStack(spacing: 4) {
                                    Image(systemName: "hand.thumbsup.fill")
                                        .font(.system(size: 26))
                                        .foregroundColor(adventure.feedback == .positive ? Theme.healthColor : Theme.titleDenim.opacity(0.35))
                                        .scaleEffect(adventure.feedback == .positive ? 1.2 : 1.0)

                                    Text("Great day!")
                                        .font(.caption2)
                                        .foregroundColor(adventure.feedback == .positive ? Theme.healthColor : Theme.titleDenim.opacity(0.5))
                                }
                                .padding(Theme.Spacing.medium)
                                .background(adventure.feedback == .positive ? Theme.healthColor.opacity(0.15) : Color.clear)
                                .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusSmall))
                                .glassEffectIfAvailable(cornerRadius: Theme.cornerRadiusSmall)
                            }
                            .accessibilityLabel("Great day")

                            // Neutral
                            Button(action: {
                                withAnimation {
                                    onFeedback(adventure.feedback == .neutral ? .none : .neutral)
                                }
                            }) {
                                VStack(spacing: 4) {
                                    Image(systemName: "minus.circle.fill")
                                        .font(.system(size: 26))
                                        .foregroundColor(adventure.feedback == .neutral ? Color(hex: "F59E0B") : Theme.titleDenim.opacity(0.35))
                                        .scaleEffect(adventure.feedback == .neutral ? 1.2 : 1.0)

                                    Text("So-so")
                                        .font(.caption2)
                                        .foregroundColor(adventure.feedback == .neutral ? Color(hex: "F59E0B") : Theme.titleDenim.opacity(0.5))
                                }
                                .padding(Theme.Spacing.medium)
                                .background(adventure.feedback == .neutral ? Color(hex: "F59E0B").opacity(0.15) : Color.clear)
                                .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusSmall))
                                .glassEffectIfAvailable(cornerRadius: Theme.cornerRadiusSmall)
                            }
                            .accessibilityLabel("So-so")

                            // Thumbs Down
                            Button(action: {
                                withAnimation {
                                    onFeedback(adventure.feedback == .negative ? .none : .negative)
                                }
                            }) {
                                VStack(spacing: 4) {
                                    Image(systemName: "hand.thumbsdown.fill")
                                        .font(.system(size: 26))
                                        .foregroundColor(adventure.feedback == .negative ? Theme.healthRose : Theme.titleDenim.opacity(0.35))
                                        .scaleEffect(adventure.feedback == .negative ? 1.2 : 1.0)

                                    Text("Tough day")
                                        .font(.caption2)
                                        .foregroundColor(adventure.feedback == .negative ? Theme.healthRose : Theme.titleDenim.opacity(0.5))
                                }
                                .padding(Theme.Spacing.medium)
                                .background(adventure.feedback == .negative ? Theme.healthRose.opacity(0.15) : Color.clear)
                                .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusSmall))
                                .glassEffectIfAvailable(cornerRadius: Theme.cornerRadiusSmall)
                            }
                            .accessibilityLabel("Tough day")
                        }
                    }
                    .padding(.bottom, Theme.Spacing.medium)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
        .glassEffectIfAvailable()
    }
}


#Preview {
    HistoryView(viewModel: QuestViewModel())
}
