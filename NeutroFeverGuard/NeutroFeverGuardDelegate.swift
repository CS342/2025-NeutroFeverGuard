//
// This source file is part of the NeutroFeverGuard based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import class FirebaseFirestore.FirestoreSettings
import class FirebaseFirestore.MemoryCacheSettings
import Spezi
import SpeziAccount
import SpeziFirebaseAccount
import SpeziFirebaseAccountStorage
import SpeziFirebaseStorage
import SpeziFirestore
import SpeziHealthKit
import SpeziKeychainStorage
import SpeziLocalStorage
import SpeziNotifications
import SpeziOnboarding
import SpeziScheduler
import SwiftUI


class NeutroFeverGuardDelegate: SpeziAppDelegate {
    override var configuration: Configuration {
        Configuration(standard: NeutroFeverGuardStandard()) {
            if !FeatureFlags.disableFirebase {
                AccountConfiguration(
                    service: FirebaseAccountService(providers: [.emailAndPassword, .signInWithApple], emulatorSettings: accountEmulator),
                    storageProvider: FirestoreAccountStorage(storeIn: FirebaseConfiguration.userCollection),
                    configuration: [
                        .requires(\.userId),
                        .requires(\.name),
                        
                        // additional values stored using the `FirestoreAccountStorage` within our Standard implementation
                        .collects(\.genderIdentity),
                        .collects(\.dateOfBirth)
                    ]
                )
                
                firestore
                if FeatureFlags.useFirebaseEmulator {
                    FirebaseStorageConfiguration(emulatorSettings: (host: "localhost", port: 9199))
                } else {
                    FirebaseStorageConfiguration()
                }
            }
            
            if HKHealthStore.isHealthDataAvailable() {
                healthKit
            }
            NeutroFeverGuardScheduler()
            Scheduler()
            OnboardingDataSource()
            LocalStorage()
            Notifications()
            NotificationManager()
            LabResultsManager()
            MedicationManager()
            SymptomManager()
            HealthKitService()
        }
    }
    
    private var accountEmulator: (host: String, port: Int)? {
        if FeatureFlags.useFirebaseEmulator {
            (host: "localhost", port: 9099)
        } else {
            nil
        }
    }
    
    
    private var firestore: Firestore {
        let settings = FirestoreSettings()
        if FeatureFlags.useFirebaseEmulator {
            settings.host = "localhost:8080"
            settings.cacheSettings = MemoryCacheSettings()
            settings.isSSLEnabled = false
        }
        
        return Firestore(
            settings: settings
        )
    }
    
    private var predicateOneMonth: NSPredicate {
        // Define the start and end time for the predicate. In this example,
        // we want to collect the samples in the previous month.
        let calendar = Calendar(identifier: .gregorian)
        let today = calendar.startOfDay(for: Date())
        // We want the end date to be tomorrow so that we can collect all the samples today.
        guard let endDate = calendar.date(byAdding: .day, value: 1, to: today) else {
            fatalError("*** Unable to calculate the end time ***")
        }
        // Define the start date to one month before.
        guard let startDate = calendar.date(byAdding: .month, value: -1, to: today) else {
            fatalError("*** Unable to calculate the start time ***")
        }
        // Initialize the NSPredicate with our start and end dates.
        return HKQuery.predicateForSamples(withStart: startDate, end: endDate)
    }
    
    private var healthKit: HealthKit {
        HealthKit {
            CollectSample(.heartRate, continueInBackground: true, predicate: predicateOneMonth)
            CollectSample(.bloodOxygen, continueInBackground: true, predicate: predicateOneMonth)
            CollectSample(.bodyTemperature, continueInBackground: true, predicate: predicateOneMonth)
        }
    }
}
