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
class LabResultsManager: Module, EnvironmentAccessible {
    var latestRecordedTime: String = "None"
    var labRecords: [LabEntry] = []
    var mockLabData: [LabEntry] = []
    
    @ObservationIgnored @Dependency(LocalStorage.self) private var localStorage
    @ObservationIgnored @Dependency(FirebaseConfiguration.self) private var firebaseConfig
    
    func configure() {
        loadLabResults() // Load data on startup
        if FeatureFlags.mockLabData {
            do {
                mockLabData = [
                    try LabEntry(date: Date(), values: [
                        .whiteBloodCell: 4000, . neutrophils: 40, .hemoglobin: 13.5, .plateletCount: 250000,
                        .lymphocytes: 30, .monocytes: 5, .eosinophils: 3, .basophils: 1, .blasts: 0
                    ])
                ]
            } catch {
                print("Failed to load mock data")
            }
            return
        }
    }
    
    func refresh() {
        loadLabResults()  // Refresh lab results
    }
    
    private func loadLabResults() {
        var results: [LabEntry] = []
        
        do {
            if FeatureFlags.mockLabData {
                results = mockLabData
            } else {
                results = try localStorage.load(LocalStorageKey<[LabEntry]>("labResults")) ?? []
            }
        } catch {
            print("Failed to load lab results: \(error)")
            results = []
        }
        
        results.sort { $0.date > $1.date }
        self.labRecords = results
        if let latestRecord = results.first {
            latestRecordedTime = formatDate(latestRecord.date)
        } else {
            latestRecordedTime = "None"
        }
    }
    
    @MainActor
    func addLabEntry(_ newEntry: LabEntry) {
        labRecords.append(newEntry)
        saveLabResults()
    }
    
    @MainActor
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
  
    @MainActor
    private func saveLabResults() {
        if FeatureFlags.mockLabData {
            mockLabData = labRecords
        }
        do {
            try localStorage.store(labRecords, for: LocalStorageKey<[LabEntry]>("labResults"))
            // Save to Firestore
            if !FeatureFlags.disableFirebase {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                
                for lab in labRecords {
                    let dateString = dateFormatter.string(from: lab.date)
                    try firebaseConfig.userDocumentReference
                        .collection("LabResults")
                        .document(dateString)
                        .setData(from: lab)
                }
            }
            refresh()
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
