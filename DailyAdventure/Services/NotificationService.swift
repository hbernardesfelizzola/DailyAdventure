//
//  NotificationService.swift
//  DailyAdventure
//
//  Created by Henrique Bernardes on 25/04/26.
//


import UserNotifications
import SwiftUI

class NotificationService {
    static let shared = NotificationService()
    
    // MARK: - Solicitar permissão
    func requestPermission() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .badge, .sound])
            return granted
        } catch {
            return false
        }
    }
    
    // MARK: - Agendar lembrete matinal
    func scheduleMorningReminder(hour: Int = 8, minute: Int = 0) {
        cancelNotification(id: "morning_reminder")
        
        let content = UNMutableNotificationContent()
        content.title = "⚔️ Your adventure awaits!"
        content.body = "What is today's adventure? Set your quests and make it count!"
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: true
        )
        
        let request = UNNotificationRequest(
            identifier: "morning_reminder",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    // MARK: - Agendar lembrete noturno
    func scheduleEveningReminder(hour: Int = 21, minute: Int = 0) {
        cancelNotification(id: "evening_reminder")
        
        let content = UNMutableNotificationContent()
        content.title = "🏰 How was your adventure today?"
        content.body = "Don't forget to review your day and complete your quests!"
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: true
        )
        
        let request = UNNotificationRequest(
            identifier: "evening_reminder",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    // MARK: - Cancelar notificação específica
    func cancelNotification(id: String) {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [id])
    }
    
    // MARK: - Cancelar todas
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
