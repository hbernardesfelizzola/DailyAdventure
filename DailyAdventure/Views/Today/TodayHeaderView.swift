//
//  TodayHeaderView.swift
//  DailyAdventure
//

import SwiftUI
import WeatherKit

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
    var weatherProvider: WeatherProvider

    var body: some View {
        switch phase {
        case .empty:
            VStack(alignment: .leading, spacing: 10) {
                eyebrow
                Text(greeting)
                    .font(.system(.title3, design: .serif))
                    .foregroundStyle(Theme.inkSecondary)
                Text("What's today's adventure?")
                    .font(.system(.largeTitle, design: .serif, weight: .bold))
                    .foregroundStyle(Theme.ink)
                    .accessibilityAddTraits(.isHeader)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

        case .inProgress:
            HStack(alignment: .center, spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    eyebrow
                    Text(greeting)
                        .font(.system(.title, design: .serif, weight: .bold))
                        .foregroundStyle(Theme.ink)
                        .accessibilityAddTraits(.isHeader)
                    Text("\(completedCount) of \(totalCount) quests done")
                        .font(.subheadline)
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
                    .font(.system(.largeTitle, design: .serif, weight: .bold))
                    .foregroundStyle(Theme.ink)
                    .accessibilityAddTraits(.isHeader)
                Text("\(completedCount) of \(totalCount) quests · \(daysAdventured) days of adventure")
                    .font(.subheadline)
                    .foregroundStyle(Theme.inkSecondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Data + clima

    private var eyebrow: some View {
        HStack(spacing: 8) {
            Text(Date().formatted(.dateTime.weekday(.wide).day().month(.wide)).uppercased())
                .font(.footnote.weight(.semibold))
                .tracking(0.8)
                .foregroundStyle(Theme.inkSecondary)

            // A marca "Weather" + link legal precisam aparecer junto com o dado —
            // por isso só mostramos a temperatura quando a atribuição já carregou.
            if let temp = weatherProvider.temperatureString,
               let attribution = weatherProvider.attribution {
                Text("·").foregroundStyle(Theme.inkSecondary)
                WeatherBadge(temperature: temp, attribution: attribution)
            }
        }
    }

    private var greeting: LocalizedStringKey {
        switch Calendar.current.component(.hour, from: Date()) {
        case 5..<12: return "Good morning."
        case 12..<18: return "Good afternoon."
        default: return "Good evening."
        }
    }
}

private struct WeatherBadge: View {
    let temperature: String
    let attribution: WeatherAttribution
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Link(destination: attribution.legalPageURL) {
            HStack(spacing: 4) {
                Text(temperature)
                    .font(.footnote.weight(.semibold))
                AsyncImage(
                    url: colorScheme == .dark ? attribution.combinedMarkDarkURL : attribution.combinedMarkLightURL
                ) { image in
                    image.resizable().scaledToFit()
                } placeholder: {
                    Color.clear
                }
                .frame(height: 11)
            }
            .foregroundStyle(Theme.inkSecondary)
            .frame(minHeight: 44)
        }
        .accessibilityLabel(Text("Temperature \(temperature). Weather data attribution, opens legal page"))
    }
}

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
