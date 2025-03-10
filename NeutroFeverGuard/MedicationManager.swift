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
@MainActor
class MedicationManager: Module, EnvironmentAccessible {
    var medications: [MedicationEntry] = []
    var mockMedData: [MedicationEntry] = []
    
    @ObservationIgnored @Dependency(LocalStorage.self) private var localStorage
    @ObservationIgnored @Dependency(FirebaseConfiguration.self) private var firebaseConfig
    
    
    func configure() {
        loadMedications() // Load data on startup
        if FeatureFlags.mockMedData {
            do {
                mockMedData = [
                    try MedicationEntry(date: Date(), name: "test", doseValue: 1, doseUnit: .mgUnit)
                ]
            } catch {
                print("Failed to load mock medication data")
            }
        }
    }
    
    func refresh() {
        loadMedications()  // Refresh medications
    }
    
    private func loadMedications() {
        if FeatureFlags.mockMedData {
            medications = mockMedData
            return
        }
        do {
            medications = try localStorage.load(LocalStorageKey<[MedicationEntry]>("medications")) ?? []
            medications.sort { $0.date > $1.date }
        } catch {
            print("Failed to load medication results: \(error)")
            medications = []
        }
    }
    
    func addMedEntry(_ newEntry: MedicationEntry) {
        medications.append(newEntry)
        saveMedResults()
    }
    
    func deleteMedEntry(at offsets: IndexSet) {
        medications.remove(atOffsets: offsets)
        saveMedResults()
    }

    func updateMedEntry(at index: Int, with updatedEntry: MedicationEntry) {
        guard medications.indices.contains(index)
            else { return }
        medications[index] = updatedEntry
        saveMedResults()
    }
    
    private func saveMedResults() {
        if FeatureFlags.mockMedData {
            mockMedData = medications
            return
        }
        do {
            try localStorage.store(medications, for: LocalStorageKey<[MedicationEntry]>("medications"))
            // Save to Firestore
            if !FeatureFlags.disableFirebase {
                try firebaseConfig.userDocumentReference
                    .collection("Medications")
                    .document(UUID().uuidString)
                    .setData(from: medications)
            }
            refresh()
        } catch {
            print("Failed to save Med results: \(error)")
        }
    }
    
//    func formatDate(_ date: Date) -> String {
//        let formatter = DateFormatter()
//        formatter.dateStyle = .medium
//        return formatter.string(from: date)
//    }
//    
//    func formatDateTime(_ date: Date) -> String {
//        let formatter = DateFormatter()
//        formatter.dateStyle = .medium
//        formatter.timeStyle = .short
//        return formatter.string(from: date)
//    }
//    
//    func formatTime(_ date: Date) -> String {
//        let formatter = DateFormatter()
//        formatter.timeStyle = .short
//        return formatter.string(from: date)
//    }
}
