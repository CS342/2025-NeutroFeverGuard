// swiftlint:disable orphaned_doc_comment
//
// This source file is part of the NeutroFeverGuard based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

/// A collection of feature flags for the NeutroFeverGuard.
enum FeatureFlags {
    /// Skips the onboarding flow to enable easier development of features in the application and to allow UI tests to skip the onboarding flow.
    static let skipOnboarding = CommandLine.arguments.contains("--skipOnboarding")
    /// Always show the onboarding when the application is launched. Makes it easy to modify and test the onboarding flow without the need to manually remove the application or reset the simulator.
    static let showOnboarding = CommandLine.arguments.contains("--showOnboarding")
    /// Disables the Firebase interactions, including the login/sign-up step and the Firebase Firestore upload.
    static let disableFirebase = CommandLine.arguments.contains("--disableFirebase")
    #if targetEnvironment(simulator)
    /// Defines if the application should connect to the local firebase emulator. Always set to true when using the iOS simulator.
    static let useFirebaseEmulator = true
    #else
    /// Defines if the application should connect to the local firebase emulator. Always set to true when using the iOS simulator.
    static let useFirebaseEmulator = CommandLine.arguments.contains("--useFirebaseEmulator")
    #endif
    /// Automatically sign in into a test account upon app launch.

    /// Requires ``disableFirebase`` to be `false`.
    static let setupTestAccount = CommandLine.arguments.contains("--setupTestAccount")
    
//    static let mockLabData = CommandLine.arguments.contains("--mockLabData")
    
    /// Defines whether to use the mock data for testing the application. This should only be set to true in UI tests.
//     static let mockTestData = CommandLine.arguments.contains("--mockTestData")
}
