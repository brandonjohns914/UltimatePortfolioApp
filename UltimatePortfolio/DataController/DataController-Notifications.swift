//
//  DataControoler-Notificiations.swift
//  UltimatePortfolio
//
//  Created by Brandon Johns on 2/1/24.
//

import Foundation
import UserNotifications


extension DataController {
    
    /// Places the reminders
    /// checks and waits for authoriziation status
    /// .authorized place the reminder
    /// .notDetermined wait for the authorization to come in
    /// - Parameter issue: issue selected for the reminder
    /// - Returns: true if a reminder is created or false if not
    func addReminder(for issue: Issue) async -> Bool {
        do {
            let center = UNUserNotificationCenter.current()
            let settings = await center.notificationSettings()

            switch settings.authorizationStatus {
            case .notDetermined:
                let success = try await requestNotifications()

                if success {
                    try await placeReminders(for: issue)
                } else {
                    return false
                }

            case .authorized:
                try await placeReminders(for: issue)

            default:
                return false
            }

            return true
        } catch {
            return false
        }
    }
    
    
    /// Removes Reminders
    /// checks for the unique ID for the issue
    /// asks notificaiton center to remove any pending requests
    /// - Parameter issue: issue is the searched issue
    func removeReminders(for issue: Issue) {
        let center = UNUserNotificationCenter.current()
        let id = issue.objectID.uriRepresentation().absoluteString
        center.removePendingNotificationRequests(withIdentifiers: [id])
    }
    
    /// Private function to request notification authorization from IOS
    /// - Returns: whether or not authorization for .alert and .sounds was granted
    private func requestNotifications() async throws -> Bool {
        let center = UNUserNotificationCenter.current()
        return try await center.requestAuthorization(options: [.alert, .sound])
    }
    
    /// Places reminders only if authoriziation was granted
    /// creates when the notification should be shown
    /// content is the issueTitle and sound
    /// components set the the alert for hour and minute that came from issueReminderTime
    ///  id converts to a string and then passes the id, content, and trigger for alert
    /// - Parameter issue: is the Issue that the reminder is set for
    private func placeReminders(for issue: Issue) async throws {
        let content = UNMutableNotificationContent()
        content.sound = .default
        content.title = issue.issueTitle

        if let issueContent = issue.content {
            content.subtitle = issueContent
        }
        
        // for final code
//        let components = Calendar.current.dateComponents([.hour, .minute], from: issue.issueReminderTime)
//        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        // for testing
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        let id = issue.objectID.uriRepresentation().absoluteString
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        return try await UNUserNotificationCenter.current().add(request)
        
    }
}
