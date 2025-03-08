//
// This source file is part of the NeutroFeverGuard based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SpeziOnboarding
import SwiftUI


struct InterestingModules: View {
    @Environment(OnboardingNavigationPath.self) private var onboardingNavigationPath
    
    
    var body: some View {
        SequentialOnboardingView(
            title: "What To Do",
            subtitle: "INTERESTING_MODULES_SUBTITLE",
            content: [
                SequentialOnboardingView.Content(
                    title: "Consent Form",
                    description: "INTERESTING_MODULES_AREA1_DESCRIPTION"
                ),
                SequentialOnboardingView.Content(
                    title: "Permissions",
                    description: "INTERESTING_MODULES_AREA2_DESCRIPTION"
                ),
                SequentialOnboardingView.Content(
                    title: "Signing up",
                    description: "INTERESTING_MODULES_AREA3_DESCRIPTION"
                ),
                SequentialOnboardingView.Content(
                    title: "Entering Your Data",
                    description: "INTERESTING_MODULES_AREA4_DESCRIPTION"
                )
            ],
            actionText: "Next",
            action: {
                onboardingNavigationPath.nextStep()
            }
        )
    }
}


#if DEBUG
#Preview {
    OnboardingStack {
        InterestingModules()
    }
}
#endif
