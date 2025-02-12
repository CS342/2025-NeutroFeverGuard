//
// This source file is part of the NeutroFeverGuard based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Spezi
import SpeziScheduler

class LabResultSchedulerModule: Module {
    @Dependency(Scheduler.self)
    private var scheduler


    init() {}


    func configure() {
        do {
            try scheduler.createOrUpdateTask(
                id: "enter-lab-result",
                title: "Remember to enter your lab results",
                instructions: "You haven't recorded your lab results for last 7 days. Record now!",
                category: Task.Category(rawValue: "measurement"),
                schedule: .daily(hour: 9, minute: 0, startingAt: .today)
            )
        } catch {
            // handle error (e.g., visualize in your UI)
        }
    }
}
