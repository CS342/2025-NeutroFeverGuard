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
class MasccManager: Module, EnvironmentAccessible {
    var masccRecords: [MasccEntry] = []
    
    @ObservationIgnored @Dependency(LocalStorage.self) private var localStorage
    @ObservationIgnored @Dependency(FirebaseConfiguration.self) private var firebaseConfig
    
    func configure() {
        loadMasccRecords()
    }
    
    private func loadMasccRecords() {
        do {
            masccRecords = try localStorage.load(LocalStorageKey<[MasccEntry]>("mascc_records")) ?? []
        } catch {
            print("Failed to load Mascc records: \(error)")
            masccRecords = []
        }
    }
    
    @MainActor
    func addMasccEntry(_ entry: masccEntry) {
        masccRecords.append(entry)
        saveMascc()
    }
    
    @MainActor
    private func saveMascc() {
        do {
            try localStorage.store(masccRecords, for: LocalStorageKey<[MasccEntry]>("mascc_records"))
            // Save to Firestore
            if !FeatureFlags.disableFirebase {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                for record in masccRecords {
                    let dateString = dateFormatter.string(from: record.date)
                    try firebaseConfig.userDocumentReference
                        .collection("mascc_records")
                        .document(dateString)
                        .setData(from: record)
                }
            }
        } catch {
            print("Failed to save symptoms: \(error)")
        }
    }
}

