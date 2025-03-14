//
// This source file is part of the NeutroFeverGuard based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
import Spezi
import SpeziScheduler
import SpeziViews
import class ModelsR4.Questionnaire
import class ModelsR4.QuestionnaireResponse


@Observable
final class NeutroFeverGuardScheduler: Module, DefaultInitializable, EnvironmentAccessible {
    @Dependency(Scheduler.self) @ObservationIgnored private var scheduler
    
    @MainActor var viewState: ViewState = .idle
    
    init() {}
    
    /// Add or update the current list of task upon app startup.
    func configure() {
        do {
//            try scheduler.createOrUpdateTask(
//                id: "social-support-questionnaire",
//                title: "Social Support Questionnaire",
//                instructions: "Please fill out the Social Support Questionnaire every day.",
//                category: .questionnaire,
//                schedule: .daily(hour: 8, minute: 0, startingAt: .today) // you can change this to schedule stuff.
//            ) { context in
//                context.questionnaire = Bundle.main.questionnaire(withName: "SocialSupportQuestionnaire")
//            }
            
            try scheduler.createOrUpdateTask(
                id: "enter-lab-result",
                title: "Enter Lab Results",
                instructions: "You haven't recorded your lab results for last 7 days. Record now!",
                category: .measurement,
                schedule: .daily(hour: 9, minute: 0, startingAt: .today),
                scheduleNotifications: true
            )
        } catch {
            viewState = .error(AnyLocalizedError(error: error, defaultErrorDescription: "Failed to create or update scheduled tasks."))
        }
    }
    
    @MainActor
    func markRecentEventsAsComplete(_ recordTime: Date = Date()) {
        //        print("in markRecentEventsAsComplete")
        guard let sevenDaysLater = Calendar.current.date(byAdding: .day, value: 7, to: recordTime)
        else { return }
        
        do {
            let events = try scheduler.queryEvents(for: recordTime..<sevenDaysLater, predicate: #Predicate { $0.id == "enter-lab-result" })
            //            print("find event")
            //            print(events)
            for event in events {
                try event.complete()
                //                print("Marked event \(event.id) as complete")
            }
        } catch {
            print("Error querying or completing events: \(error)")
        }
    }
    
    @MainActor
    func restartNotification(from date: Date) {
        do {
            try scheduler.deleteAllVersions(ofTask: "enter-lab-result")
        } catch {
            print("can't delete task")
        }
        do {
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

    
//    @MainActor
//    func printUpcomingLabResultEvents() {
//        let today = Date()
//        guard let fourteenDaysLater = Calendar.current.date(byAdding: .day, value: 14, to: today) else { return }
//        
//        do {
//            let events = try scheduler.queryEvents(for: today..<fourteenDaysLater, predicate: #Predicate { $0.id == "enter-lab-result" })
//            
//            if events.isEmpty {
//                print("No lab result events found for the next 14 days.")
//            } else {
//                for event in events {
//                    let dateFormatter = DateFormatter()
//                    dateFormatter.dateStyle = .medium
//                    dateFormatter.timeStyle = .short
//                    
//                    let dateStr = dateFormatter.string(from: event.occurrence.start)
//                    let status = event.isCompleted ? "Completed" : "Not Completed"
//                    
//                    print("Event on \(dateStr): \(status)")
//                }
//            }
//        } catch {
//            print("Error querying upcoming events: \(error)")
//        }
//    }
}


// extension Task.Context {
//     @Property(coding: .json) var questionnaire: Questionnaire?
// }


extension Outcome {
    // periphery:ignore - demonstration of how to store additional context within an outcome
    @Property(coding: .json) var questionnaireResponse: QuestionnaireResponse?
}
