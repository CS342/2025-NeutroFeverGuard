//
// This source file is part of the NeutroFeverGuard based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import FirebaseFirestore
import Spezi
import SpeziLocalStorage
import SwiftUI

@Observable
class SymptomManager: Module, EnvironmentAccessible {
    var symptomRecords: [SymptomEntry] = []
    
    @ObservationIgnored @Dependency(LocalStorage.self) private var localStorage
    @ObservationIgnored @Dependency(FirebaseConfiguration.self) private var firebaseConfig
    
    func configure() {
        loadSymptoms()
    }
    
    private func loadSymptoms() {
        do {
            symptomRecords = try localStorage.load(LocalStorageKey<[SymptomEntry]>("symptoms")) ?? []
        } catch {
            print("Failed to load symptoms: \(error)")
            symptomRecords = []
        }
    }
    
    @MainActor
    func addSymptomEntry(_ entry: SymptomEntry) {
        symptomRecords.append(entry)
        saveSymptoms()
    }
    
    @MainActor
    private func saveSymptoms() {
        do {
            try localStorage.store(symptomRecords, for: LocalStorageKey<[SymptomEntry]>("symptoms"))
            
            if !FeatureFlags.disableFirebase {
                let symptomsCollection = try firebaseConfig.userDocumentReference.collection("Symptoms")
                for symptom in symptomRecords {
                    try symptomsCollection
                        .document(UUID().uuidString)
                        .setData(from: symptom)
                }
            }
        } catch {
            print("Failed to save symptoms: \(error)")
        }
    }
}
