//
//  NotificationService.swift
//  DailyAdventure
//
//  Created by Henrique Bernardes on 25/04/26.
//

import UserNotifications

enum NotificationUserInfoKey {
    static let destinationRaw = "destination"
}

enum NotificationDeepLinkDestination: String {
    case today
    case progress
}

final class NotificationService {
    static let shared = NotificationService()

    static let morningIdentifier = "morning_reminder"
    static let eveningIdentifier = "evening_reminder"

    /// UserDefaults keys (keep in sync with `@AppStorage` in Settings).
    private enum DefaultsKey {
        static let morningEnabled = "morningReminderEnabled"
        static let eveningEnabled = "eveningReminderEnabled"
        static let morningHour = "morningReminderHour"
        static let morningMinute = "morningReminderMinute"
        static let eveningHour = "eveningReminderHour"
        static let eveningMinute = "eveningReminderMinute"
    }

    // MARK: - Permission

    func requestPermission() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .badge, .sound])
            return granted
        } catch {
            return false
        }
    }

    // MARK: - Schedule

    func scheduleMorningReminder(hour: Int, minute: Int) {
        cancelNotification(id: Self.morningIdentifier)

        let content = UNMutableNotificationContent()
        content.title = Self.localizedMorningTitle()
        content.body = Self.localizedMorningBody()
        content.sound = .default
        content.userInfo = [
            NotificationUserInfoKey.destinationRaw: NotificationDeepLinkDestination.today.rawValue
        ]

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: true
        )

        let request = UNNotificationRequest(
            identifier: Self.morningIdentifier,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    func scheduleEveningReminder(hour: Int, minute: Int) {
        cancelNotification(id: Self.eveningIdentifier)

        let content = UNMutableNotificationContent()
        content.title = Self.localizedEveningTitle()
        content.body = Self.localizedEveningBody()
        content.sound = .default
        content.userInfo = [
            NotificationUserInfoKey.destinationRaw: NotificationDeepLinkDestination.progress.rawValue
        ]

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: true
        )

        let request = UNNotificationRequest(
            identifier: Self.eveningIdentifier,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    func cancelNotification(id: String) {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [id])
    }

    // MARK: - Sync with persisted settings

    /// Reschedules enabled reminders using saved hour/minute; cancels disabled ones.
    func syncScheduledNotificationsWithSettings() {
        let defaults = UserDefaults.standard

        if defaults.bool(forKey: DefaultsKey.morningEnabled) {
            let hour = defaults.int(forKey: DefaultsKey.morningHour, default: 8)
            let minute = defaults.int(forKey: DefaultsKey.morningMinute, default: 0)
            scheduleMorningReminder(hour: hour, minute: minute)
        } else {
            cancelNotification(id: Self.morningIdentifier)
        }

        if defaults.bool(forKey: DefaultsKey.eveningEnabled) {
            let hour = defaults.int(forKey: DefaultsKey.eveningHour, default: 21)
            let minute = defaults.int(forKey: DefaultsKey.eveningMinute, default: 0)
            scheduleEveningReminder(hour: hour, minute: minute)
        } else {
            cancelNotification(id: Self.eveningIdentifier)
        }
    }

    // MARK: - Localized payloads (resolved when scheduling)

    private static func localizedMorningTitle() -> String {
        String(localized: "notification.morning.title")
    }

    private static func localizedMorningBody() -> String {
        String(localized: "notification.morning.body")
    }

    private static func localizedEveningTitle() -> String {
        String(localized: "notification.evening.title")
    }

    private static func localizedEveningBody() -> String {
        String(localized: "notification.evening.body")
    }
}

private extension UserDefaults {
    func int(forKey key: String, default defaultValue: Int) -> Int {
        if object(forKey: key) == nil {
            return defaultValue
        }
        return integer(forKey: key)
    }
}
