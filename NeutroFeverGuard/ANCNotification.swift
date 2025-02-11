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

// final class ANCReminder: Module {
//    @Dependency(Notifications.self)
//    private var notifications
//
//    @Application(\.notificationSettings)
//    private var settings
//
//    func checkAndSendReminder() async throws {
//        let lastRecordedTime = getLatestLabTime()
//        let daysSinceLastRecord = Calendar.current.dateComponents([.day], from: lastRecordedTime, to: Date()).day ?? 0
//
//        if daysSinceLastRecord >= 7 {
//            try await sendReminderNotification()
//        }
//    }
//
//    private func sendReminderNotification() async throws {
//        let status = await settings().authorizationStatus
//        guard status == .authorized || status == .provisional else { return }
//
//        let content = UNMutableNotificationContent()
//        content.title = "Reminder: Update Your Lab Values"
//        content.body = "You haven't recorded your ANC values for over a week. Please update them."
//        content.sound = .default
//
//        let request = UNNotificationRequest(
//            identifier: "ANCReminder",
//            content: content,
//            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
//        )
//
//        try await notifications.add(request: request)
//    }
//
//    private func getLatestLabTime() -> Date {
//        return Calendar.current.date(byAdding: .day, value: -8, to: Date())!
//    }
// }
