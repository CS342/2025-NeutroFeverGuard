# Background Checking & Lab Notification - NeutroFeverGuard
This file explains how background checking and lab results reminders work in NeutroFeverGuard.

Back to [README](README.md).

## Background Checking

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

Now you know how background checking & lab notification work in NeutroFeverGuard! Welcome back to [README](README.md).


## License

This project is licensed under the MIT License. See [Licenses](LICENSES) for more information.

![Spezi Footer](https://raw.githubusercontent.com/StanfordSpezi/.github/main/assets/FooterLight.png#gh-light-mode-only)
![Spezi Footer](https://raw.githubusercontent.com/StanfordSpezi/.github/main/assets/FooterDark.png#gh-dark-mode-only)