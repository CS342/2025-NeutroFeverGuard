//
// This source file is part of the NeutroFeverGuard based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SpeziHealthKit
import SpeziOnboarding
import SwiftUI


struct HealthKitPermissions: View {
    @Environment(HealthKit.self) private var healthKitDataSource
    @Environment(OnboardingNavigationPath.self) private var onboardingNavigationPath

    @State private var healthKitProcessing = false
    
    let accessRequirements = HealthKit.DataAccessRequirements(
        read: [
            HKQuantityType(.heartRate),
            HKQuantityType(.oxygenSaturation),
            HKQuantityType(.bodyTemperature),
            HKQuantityType(.bloodPressureSystolic),
            HKQuantityType(.bloodPressureDiastolic)
        ],
        write: [
            HKQuantityType(.heartRate),
            HKQuantityType(.oxygenSaturation),
            HKQuantityType(.bodyTemperature),
            HKQuantityType(.bloodPressureSystolic),
            HKQuantityType(.bloodPressureDiastolic)
        ]
    )

    var body: some View {
        OnboardingView(
            contentView: {
                VStack {
                    OnboardingTitleView(
                        title: "Health Data Access",
                        subtitle: "HEALTHKIT_PERMISSIONS_SUBTITLE"
                    )
                    Spacer()
                    Image(systemName: "heart.text.square.fill")
                        .font(.system(size: 150))
                        .foregroundColor(.accentColor)
                        .accessibilityHidden(true)
                    Text("HEALTHKIT_PERMISSIONS_DESCRIPTION")
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 16)
                    Spacer()
                }
            }, actionView: {
                OnboardingActionsView(
                    "Grant Access",
                    action: {
                        do {
                            healthKitProcessing = true
                            // HealthKit is not available in the preview simulator.
                            if ProcessInfo.processInfo.isPreviewSimulator {
                                try await _Concurrency.Task.sleep(for: .seconds(5))
                            } else {
                                try await healthKitDataSource.askForAuthorization(for: accessRequirements)
                            }
                        } catch {
                            print("Could not request HealthKit permissions.")
                        }
                        healthKitProcessing = false
                        
                        onboardingNavigationPath.nextStep()
                    }
                )
            }
        )
            .navigationBarBackButtonHidden(healthKitProcessing)
            // Small fix as otherwise "Login" or "Sign up" is still shown in the nav bar
            .navigationTitle(Text(verbatim: ""))
    }
}


#if DEBUG
#Preview {
    OnboardingStack {
        HealthKitPermissions()
    }
        .previewWith(standard: NeutroFeverGuardStandard()) {
            HealthKit()
        }
}
#endif
