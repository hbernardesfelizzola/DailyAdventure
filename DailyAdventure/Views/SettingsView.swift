//
//  SettingsView.swift
//  DailyAdventure
//
//  Created by Henrique Bernardes on 19/04/26.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage(AppearancePreference.key) private var appearance: AppearancePreference = .system
    @AppStorage("isHighContrast") private var isHighContrast = false
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @AppStorage("morningReminderEnabled") private var morningReminderEnabled = false
    @AppStorage("eveningReminderEnabled") private var eveningReminderEnabled = false
    @AppStorage("morningReminderHour") private var morningHour = 8
    @AppStorage("morningReminderMinute") private var morningMinute = 0
    @AppStorage("eveningReminderHour") private var eveningHour = 21
    @AppStorage("eveningReminderMinute") private var eveningMinute = 0

    private var morningTimeBinding: Binding<Date> {
        Binding(
            get: { SettingsView.todayDate(hour: morningHour, minute: morningMinute) },
            set: { newDate in
                let parts = Calendar.current.dateComponents([.hour, .minute], from: newDate)
                morningHour = parts.hour ?? 8
                morningMinute = parts.minute ?? 0
                if morningReminderEnabled {
                    NotificationService.shared.scheduleMorningReminder(hour: morningHour, minute: morningMinute)
                }
            }
        )
    }

    private var eveningTimeBinding: Binding<Date> {
        Binding(
            get: { SettingsView.todayDate(hour: eveningHour, minute: eveningMinute) },
            set: { newDate in
                let parts = Calendar.current.dateComponents([.hour, .minute], from: newDate)
                eveningHour = parts.hour ?? 21
                eveningMinute = parts.minute ?? 0
                if eveningReminderEnabled {
                    NotificationService.shared.scheduleEveningReminder(hour: eveningHour, minute: eveningMinute)
                }
            }
        )
    }

    private var morningSubtitle: String {
        let timeLabel = formattedShortTime(hour: morningHour, minute: morningMinute)
        let format = String(localized: "settings.notifications.morning.subtitle_format")
        return String(format: format, timeLabel)
    }

    private var eveningSubtitle: String {
        let timeLabel = formattedShortTime(hour: eveningHour, minute: eveningMinute)
        let format = String(localized: "settings.notifications.evening.subtitle_format")
        return String(format: format, timeLabel)
    }

    /// Reference date matching hour/minute for pickers (`DatePicker` bindings).
    private static func todayDate(hour: Int, minute: Int) -> Date {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        components.hour = hour
        components.minute = minute
        return Calendar.current.date(from: components) ?? Date()
    }

    private func formattedShortTime(hour: Int, minute: Int) -> String {
        let date = Self.todayDate(hour: hour, minute: minute)
        return DateFormatter.localizedString(from: date, dateStyle: .none, timeStyle: .short)
    }

    private var versionString: String {
        let info = Bundle.main.infoDictionary
        let version = info?["CFBundleShortVersionString"] as? String ?? "–"
        let build = info?["CFBundleVersion"] as? String ?? "–"
        return "DailyAdventure \(version) (\(build))"
    }

    var body: some View {
        ZStack {
            AnimatedBackgroundView()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 28) {
                    Text("Settings")
                        .font(.screenTitle)
                        .foregroundStyle(Theme.ink)
                        .accessibilityAddTraits(.isHeader)

                    // MARK: - Profile
                    SettingsSection("Profile") {
                        SettingsNameRow()
                    }

                    // MARK: - Appearance
                    SettingsSection("Appearance") {
                        VStack(spacing: 0) {
                            SettingsRow(icon: "circle.lefthalf.filled", color: Theme.workColor, title: "Theme") {
                                EmptyView()
                            }
                            .accessibilityHidden(true)

                            Picker("Theme", selection: $appearance) {
                                ForEach(AppearancePreference.allCases) { option in
                                    Text(option.title).tag(option)
                                }
                            }
                            .pickerStyle(.segmented)
                            .padding(.leading, 64)
                            .padding(.trailing, 16)
                            .padding(.bottom, 14)
                        }
                        SettingsDivider()
                        SettingsToggleRow(
                            icon: "eye.fill",
                            color: Theme.accent,
                            title: String(localized: "High Contrast"),
                            subtitle: String(localized: "Increase color contrast for better readability"),
                            isOn: $isHighContrast
                        )
                    }

                    // MARK: - Notifications
                    SettingsSection(LocalizedStringKey("settings.notifications.header")) {
                        SettingsToggleRow(
                            icon: "sunrise.fill",
                            color: Theme.neutralOrange,
                            title: String(localized: "settings.notifications.morning.title"),
                            subtitle: morningSubtitle,
                            isOn: $morningReminderEnabled
                        )
                        .onChange(of: morningReminderEnabled) { _, newValue in
                            if newValue {
                                Task {
                                    let granted = await NotificationService.shared.requestPermission()
                                    if granted {
                                        NotificationService.shared.scheduleMorningReminder(hour: morningHour, minute: morningMinute)
                                    } else {
                                        morningReminderEnabled = false
                                    }
                                }
                            } else {
                                NotificationService.shared.cancelNotification(id: NotificationService.morningIdentifier)
                            }
                        }

                        if morningReminderEnabled {
                            SettingsDivider()
                            reminderTimePickerRow(
                                title: String(localized: "settings.notifications.morning_time"),
                                binding: morningTimeBinding
                            )
                        }

                        SettingsDivider()

                        SettingsToggleRow(
                            icon: "moon.stars.fill",
                            color: Theme.workColor,
                            title: String(localized: "settings.notifications.evening.title"),
                            subtitle: eveningSubtitle,
                            isOn: $eveningReminderEnabled
                        )
                        .onChange(of: eveningReminderEnabled) { _, newValue in
                            if newValue {
                                Task {
                                    let granted = await NotificationService.shared.requestPermission()
                                    if granted {
                                        NotificationService.shared.scheduleEveningReminder(hour: eveningHour, minute: eveningMinute)
                                    } else {
                                        eveningReminderEnabled = false
                                    }
                                }
                            } else {
                                NotificationService.shared.cancelNotification(id: NotificationService.eveningIdentifier)
                            }
                        }

                        if eveningReminderEnabled {
                            SettingsDivider()
                            reminderTimePickerRow(
                                title: String(localized: "settings.notifications.evening_time"),
                                binding: eveningTimeBinding
                            )
                        }
                    }

                    // MARK: - About
                    SettingsSection("About") {
                        SettingsInfoRow(
                            icon: "star.fill",
                            color: Theme.accent,
                            title: String(localized: "What is DailyAdventure?"),
                            subtitle: String(localized: "A gamified journaling app that turns your daily tasks into epic quests!")
                        )
                        SettingsDivider()
                        SettingsInfoRow(
                            icon: "diamond.fill",
                            color: Theme.healthColor,
                            title: String(localized: "Side Quests"),
                            subtitle: String(localized: "Add tasks for Work, Health and Relationship to balance your adventure.")
                        )
                        SettingsDivider()
                        SettingsInfoRow(
                            icon: "chart.pie.fill",
                            color: Theme.workColor,
                            title: String(localized: "Check your Progress"),
                            subtitle: String(localized: "Track your daily completion and see how your adventure unfolds.")
                        )
                    }

                    // MARK: - Help
                    SettingsSection("Help") {
                        Button {
                            hasSeenOnboarding = false
                        } label: {
                            SettingsRow(
                                icon: "arrow.counterclockwise",
                                color: Theme.accent,
                                title: "View Onboarding Again",
                                subtitle: "See how DailyAdventure works"
                            ) {
                                Image(systemName: "chevron.right")
                                    .font(.footnote.weight(.semibold))
                                    .foregroundStyle(Theme.inkSecondary)
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }

                    // MARK: - Version
                    Text(verbatim: versionString)
                        .font(.caption)
                        .foregroundStyle(Theme.inkSecondary)
                        .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 120)
            }
            .scrollEdgeEffectIfAvailable()
        }
    }

    private func reminderTimePickerRow(title: String, binding: Binding<Date>) -> some View {
        HStack(spacing: Theme.Spacing.medium) {
            Text(title)
                .font(.rowText)
                .foregroundStyle(Theme.ink)

            Spacer(minLength: 8)

            DatePicker("", selection: binding, displayedComponents: .hourAndMinute)
                .labelsHidden()
                .tint(Theme.accent)
        }
        .padding(.leading, 64)
        .padding(.trailing, 16)
        .frame(minHeight: 52)
    }
}

// MARK: - Estrutura

/// Rótulo em caixa alta + card com as linhas da seção.
struct SettingsSection<Content: View>: View {
    let title: LocalizedStringKey
    @ViewBuilder var content: Content

    init(_ title: LocalizedStringKey, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionLabel(title)
                .padding(.horizontal, 4)
                .accessibilityAddTraits(.isHeader)

            VStack(spacing: 0) {
                content
            }
            .padding(.vertical, 4)
            .cardSurface(cornerRadius: Theme.Radius.list)
        }
    }
}

struct SettingsDivider: View {
    var body: some View {
        Divider()
            .overlay(Theme.separator)
            .padding(.leading, 64)
    }
}

/// Linha padrão: ícone em quadrado arredondado, título/subtítulo e um elemento à direita.
struct SettingsRow<Trailing: View>: View {
    let icon: String
    let color: Color
    let title: Text
    let subtitle: Text?
    @ViewBuilder var trailing: Trailing

    init(icon: String, color: Color, title: LocalizedStringKey, subtitle: LocalizedStringKey? = nil,
         @ViewBuilder trailing: () -> Trailing = { EmptyView() }) {
        self.icon = icon
        self.color = color
        self.title = Text(title)
        self.subtitle = subtitle.map { Text($0) }
        self.trailing = trailing()
    }

    init(icon: String, color: Color, verbatimTitle: String, verbatimSubtitle: String? = nil,
         @ViewBuilder trailing: () -> Trailing = { EmptyView() }) {
        self.icon = icon
        self.color = color
        self.title = Text(verbatim: verbatimTitle)
        self.subtitle = verbatimSubtitle.map { Text(verbatim: $0) }
        self.trailing = trailing()
    }

    var body: some View {
        HStack(spacing: 14) {
            SettingsIcon(systemImage: icon, color: color)

            VStack(alignment: .leading, spacing: 2) {
                title
                    .font(.rowText)
                    .foregroundStyle(Theme.ink)
                if let subtitle {
                    subtitle
                        .font(.footnote)
                        .foregroundStyle(Theme.inkSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            trailing
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .frame(minHeight: 52)
    }
}

struct SettingsIcon: View {
    let systemImage: String
    let color: Color

    var body: some View {
        Image(systemName: systemImage)
            .font(.callout.weight(.semibold))
            .foregroundStyle(color)
            .frame(width: 34, height: 34)
            .background(color.opacity(0.16), in: RoundedRectangle(cornerRadius: 9))
            .accessibilityHidden(true)
    }
}

/// Nome usado na saudação da Today. Salva ao terminar de editar (não a cada tecla).
struct SettingsNameRow: View {
    @AppStorage(UserProfile.nameKey) private var userName = ""
    @State private var draft = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: 14) {
            SettingsIcon(systemImage: "person.fill", color: Theme.accent)

            VStack(alignment: .leading, spacing: 2) {
                TextField("Your name", text: $draft)
                    .font(.rowText)
                    .foregroundStyle(Theme.ink)
                    .textContentType(.givenName)
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled()
                    .submitLabel(.done)
                    .focused($isFocused)
                    .onSubmit(save)

                Text("Used to greet you on the Today tab")
                    .font(.footnote)
                    .foregroundStyle(Theme.inkSecondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .frame(minHeight: 52)
        .onAppear { draft = userName }
        .onChange(of: isFocused) { _, focused in
            if !focused { save() }
        }
    }

    private func save() {
        userName = UserProfile.sanitized(draft)
        draft = userName
    }
}

struct SettingsToggleRow: View {
    let icon: String
    let color: Color
    let title: String
    let subtitle: String
    @Binding var isOn: Bool

    var body: some View {
        SettingsRow(icon: icon, color: color, verbatimTitle: title, verbatimSubtitle: subtitle) {
            Toggle(title, isOn: $isOn)
                .labelsHidden()
                .tint(Theme.accent)
        }
        .accessibilityElement(children: .combine)
    }
}

struct SettingsInfoRow: View {
    let icon: String
    let color: Color
    let title: String
    let subtitle: String

    var body: some View {
        SettingsRow(icon: icon, color: color, verbatimTitle: title, verbatimSubtitle: subtitle)
            .accessibilityElement(children: .combine)
    }
}

#Preview {
    SettingsView()
}
