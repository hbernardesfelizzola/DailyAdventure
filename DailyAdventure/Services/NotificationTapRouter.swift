//
//  NotificationTapRouter.swift
//  DailyAdventure
//

import UserNotifications

@Observable @MainActor
final class NotificationTapRouter: NSObject, UNUserNotificationCenterDelegate {
    /// Main tab index: 0 Log, 1 Today, 2 Progress, 3 Settings
    var pendingTabIndex: Int?

    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let identifier = response.notification.request.identifier
        Task { @MainActor in
            switch identifier {
            case NotificationService.morningIdentifier:
                self.pendingTabIndex = MainTab.today
            case NotificationService.eveningIdentifier:
                self.pendingTabIndex = MainTab.progress
            default:
                break
            }
        }
        completionHandler()
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }
}

enum MainTab {
    static let log = 0
    static let today = 1
    static let progress = 2
    static let settings = 3
}
