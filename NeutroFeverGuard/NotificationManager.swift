//
// This source file is part of the NeutroFeverGuard based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//
import Spezi
import SpeziNotifications
import UserNotifications

@Observable
class NotificationManager: Module, NotificationHandler {
    let notificationSentKey = "FebrileNeutropeniaNotificationSent"

    @MainActor
    func receiveIncomingNotification(_ notification: UNNotification) async -> UNNotificationPresentationOptions? {
        [.badge, .banner, .list]
    }
    
    func sendLocalNotification(title: String, body: String) {
        guard !isNotificationAlreadySent() else {
            print("Notification already sent, skipping duplicate alert.")
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
                
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to send notification: \(error.localizedDescription)")
            } else {
                self.saveNotificationSent()
            }
        }
    }
    
    private func isNotificationAlreadySent() -> Bool {
        UserDefaults.standard.bool(forKey: notificationSentKey)
    }

    private func saveNotificationSent() {
        UserDefaults.standard.set(true, forKey: notificationSentKey)
    }

    func resetNotificationState() {
        UserDefaults.standard.set(false, forKey: notificationSentKey)
    }
}
