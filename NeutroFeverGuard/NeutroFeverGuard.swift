//
// This source file is part of the NeutroFeverGuard based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Spezi
import SpeziFirebaseAccount
import SpeziViews
import SwiftUI


@main
struct NeutroFeverGuard: App {
    @UIApplicationDelegateAdaptor(NeutroFeverGuardDelegate.self) var appDelegate
    @AppStorage(StorageKeys.onboardingFlowComplete) var completedOnboardingFlow = false

    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if completedOnboardingFlow {
                     // HKVisualization()
                      HomeView()
                     // HKVisualizationItem(data: [], xName: "Preview x axis", yName: "Preview y axis", title: "Preview Title")
                } else {
                    EmptyView()
                }
            }
                .sheet(isPresented: !$completedOnboardingFlow) {
                    OnboardingFlow()
                }
                .testingSetup()
                .spezi(appDelegate)
        }
    }
}
