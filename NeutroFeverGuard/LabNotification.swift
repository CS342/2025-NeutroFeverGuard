//
// This source file is part of the NeutroFeverGuard based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Spezi
import SpeziScheduler
import Foundation

final class LabResultSchedulerModule: Module {
    @Dependency(Scheduler.self)
    private var scheduler

    init() {}

    func configure() {
        do {
            try scheduler.createOrUpdateTask(
                id: "enter-lab-result",
                title: "Remember to enter your lab results",
                instructions: "You haven't recorded your lab results for last 7 days. Record now!",
                category: .questionnaire,
                schedule: .daily(hour: 9, minute: 0, startingAt: .today),
                scheduleNotifications: true
            )
        } catch {
            // handle error (e.g., visualize in your UI)
        }
    }
    
    @MainActor
    func markRecentEventsAsComplete() {
        let today = Date()
        guard let sevenDaysLater = Calendar.current.date(byAdding: .day, value: 7, to: today) else { return }
        
        do {
            let events = try scheduler.queryEvents(for: today..<sevenDaysLater, predicate: #Predicate { $0.id == "enter-lab-result" })
            
            for event in events {
                event.complete()
                print("Marked event \(event.id) as complete")
            }
        } catch {
            print("Error querying or completing events: \(error)")
        }
    }
}

