<!--

This source file is part of the NeutroFeverGuard based on the Stanford Spezi Template Application project

SPDX-FileCopyrightText: 2025 Stanford University

SPDX-License-Identifier: MIT

-->

# Fever Monitoring & Lab Notifications - NeutroFeverGuard
This file explains how fever monitoring and notifications and lab results reminders work in NeutroFeverGuard.

Back to [README](../README.md).

## Fever Monitoring and Notification
NeutroFeverGuard continously monitors  body temperature, heart rate and oxygen saturation through HealthKit. We use [SpeziHealthKit](https://swiftpackageindex.com/StanfordSpezi/SpeziHealthKit/1.0.0-beta.4/documentation/spezihealthkit) to read these in the background continuously and push it to HealthKit.

```swift
private var healthKit: HealthKit {
        HealthKit {
            CollectSample(.heartRate, continueInBackground: true, predicate: predicateOneMonth)
            CollectSample(.bloodOxygen, continueInBackground: true, predicate: predicateOneMonth)
            CollectSample(.bodyTemperature, continueInBackground: true, predicate: predicateOneMonth)
        }
    }
```

Based on latest Absolute Neutrophil Count (ANC), we determine whether the patient is neutropenic (ANC<500). If the patient is neutropenic, and the continuously read temperature indicates fever (>=101 F once or >=100.4 F steadily in the last hour), we send a timely notification warning to patient to contact their care provider.

```swift
func add(sample: HKSample) async {
        if FeatureFlags.disableFirebase {
            logger.debug("Received new HealthKit sample: \(sample)")
            if let condition = await checkForFebrileNeutropenia() {
                notificationManager.sendLocalNotification(
                    title: "Health Alert",
                    body: "Risk detected: \(condition), please contact your care provider."
                )
            }
            return
        }
        
        do {
            try await healthKitDocument(id: sample.id)
                .setData(from: sample.resource)
            // Check if the condition is met before sending a notification
            if let condition = await checkForFebrileNeutropenia() {
                notificationManager.sendLocalNotification(
                    title: "Health Alert",
                    body: "Risk detected: \(condition), please contact your care provider."
                )
            }
        } catch {
            logger.error("Could not store HealthKit sample: \(error)")
        }
    }
```
These local notifications can be received both when the app is foreground or background. Here is how you do that:

```swift
@Observable
class NotificationManager: Module, NotificationHandler {
    @MainActor
    func receiveIncomingNotification(_ notification: UNNotification) async -> UNNotificationPresentationOptions? {
        [.badge, .banner, .list]
    }
    // more functions here.
```

## Lab Notification

NeutroFeverGuard helps chemotherapy patients track lab results by sending daily reminders at **9:00 AM** if no data has been recorded for over 7 days. This is handled through the [SpeziScheduler](https://github.com/StanfordSpezi/SpeziScheduler) module.  

Whenever a user records new lab results, the app automatically marks the next **7 days' events as complete** to avoid unnecessary reminders.  

Example:  
- Result recorded on March 1 → Events from March 1 to March 7 marked complete  
- Next reminder on March 8 if no new result is added

When a lab result is deleted, the app checks whether the deleted result corresponds to the **most recent completed event**:  

1. If not the latest result → No action needed, future notifications continue as scheduled.  
2. If it’s the latest result → Restart the notification schedule to re-enable reminders, because there’s no direct "unmark as complete" method in `SpeziScheduler`.

If a recent lab result is deleted, we reset the schedule with this logic:

```swift
@MainActor
func restartNotification(from date: Date) {
    do {
        // Delete all existing task versions and their outcomes
        try scheduler.deleteAllVersions(ofTask: "enter-lab-result")
    } catch {
        print("Failed to delete previous task versions")
    }
    
    do {
        // Create a fresh task starting from the given date
        try scheduler.createOrUpdateTask(
            id: "enter-lab-result",
            title: "Enter Lab Results",
            instructions: "You haven't recorded your lab results for last 7 days. Record now!",
            category: .measurement,
            schedule: .daily(hour: 9, minute: 0, startingAt: date),
            scheduleNotifications: true,
            shadowedOutcomesHandling: .delete
        )
    } catch {
        viewState = .error(AnyLocalizedError(error: error, defaultErrorDescription: "Failed to create or update scheduled tasks."))
    }
}
```
> [!NOTE]  
> **Why Delete Before Create?** When restarting the "enter-lab-result" task schedule, previously completed events remained marked as complete, even after calling `createOrUpdateTask` with `shadowedOutcomesHandling: .delete`. This happened because `createOrUpdateTask` updates the task definition but doesn’t automatically clear old outcomes that still match the new schedule.

Now you know how fever monitoring and notifications and lab results reminders work in NeutroFeverGuard! Welcome back to [README](../README.md).