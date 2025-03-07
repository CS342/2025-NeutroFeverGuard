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
class LabResultsManager: Module, EnvironmentAccessible {
    private let localStorage: LocalStorage
    private var firebaseConfig = FirebaseConfiguration()
    
    var latestRecordedTime: String = "None"
    var labRecords: [LabEntry] = []
        
    init(localStorage: LocalStorage) {
        self.localStorage = localStorage
    }
    
    func configure() {
        loadLabResults() // Load data on startup
    }
    
    func refresh() {
        loadLabResults()  // Refresh lab results
    }
    
    private func loadLabResults() {
        do {
            var results = try localStorage.load(LocalStorageKey<[LabEntry]>("labResults")) ?? []
            results.sort { $0.date > $1.date }
            self.labRecords = results
            
            if let latestRecord = results.first {
                latestRecordedTime = formatDate(latestRecord.date)
            } else {
                latestRecordedTime = "None"
            }
        } catch {
            print("Failed to load lab results: \(error)")
            self.labRecords = []
            latestRecordedTime = "None"
        }
    }
    
    func addLabEntry(_ newEntry: LabEntry) {
        labRecords.append(newEntry)
        saveLabResults()
    }
    
    func deleteLabEntry(at index: Int) {
        guard labRecords.indices.contains(index)
            else { return }
        labRecords.remove(at: index)
        saveLabResults()
    }

//    func updateLabEntry(at index: Int, with updatedEntry: LabEntry) {
//        guard labRecords.indices.contains(index)
//            else { return }
//        labRecords[index] = updatedEntry
//        saveLabResults()
//    }
    
    private func saveLabResults() {
        do {
            try localStorage.store(labRecords, for: LocalStorageKey<[LabEntry]>("labResults"))
            // Save to Firestore
            if !FeatureFlags.disableFirebase {
                try firebaseConfig.userDocumentReference
                    .collection("LabResults")
                    .document(UUID().uuidString)
                    .setData(from: labRecords)
            }
        } catch {
            print("Failed to save lab results: \(error)")
        }
    }

    func getAncValue() -> Double? {
        guard let latestRecord = labRecords.first,
              let neutrophils = latestRecord.values[.neutrophils],
              let wbc = latestRecord.values[.whiteBloodCell] else {
            return nil
        }
        return (neutrophils / 100.0) * wbc
    }

    func getANCStatus() -> (text: String, color: Color) {
        guard let ancValue = getAncValue() else {
            return ("No Data", .gray)
        }

        switch ancValue {
        case let anc where anc >= 500:
            return ("Normal", .green)
        case let anc where anc >= 100:
            return ("Severe Neutropenia", .orange)
        default:
            return ("Profound Neutropenia", .red)
        }
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    func formatDateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
