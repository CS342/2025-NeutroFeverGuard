//
// This source file is part of the NeutroFeverGuard based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SpeziAccount
import SpeziLocalStorage
import SwiftUI

struct MedicationRow: View {
    let medication: MedicationEntry

    var body: some View {
        VStack(alignment: .leading) {
            Text(medication.name)
                .font(.headline)
            Text("Dose: \(String(format: "%.2f", medication.doseValue)) \(medication.doseUnit.rawValue)")
                .font(.subheadline)
            Text("Date: \(formatDate(medication.date))")
                .font(.subheadline)
        }
    }
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct MedicationView: View {
    @State private var medications: [MedicationEntry] = []
    @Environment(LocalStorage.self) var localStorage
    @Environment(Account.self) private var account: Account?
    @Binding var presentingAccount: Bool

    var body: some View {
        NavigationView {
            List {
                if medications.isEmpty {
                    Text("No medications recorded")
                        .font(.headline)
                } else {
                    ForEach(medications, id: \.name) {medication in
                        MedicationRow(medication: medication)
                    }
                }
            }
            .navigationTitle("Medication List")
            .onAppear {
                loadMedications()
            }
            .listStyle(.insetGrouped)
            .background(Color(.systemGray6))
            .toolbar {
                if account != nil {
                    AccountButton(isPresented: $presentingAccount)
                }
            }
        }
    }

    private func loadMedications() {
        var results: [MedicationEntry]
        do {
            results = try localStorage.load(LocalStorageKey<[MedicationEntry]>("medications")) ?? []
            results.sort { $0.date > $1.date }
            medications = results
        } catch {
            print("Failed to load medications : \(error)")
            medications = []
        }
    }
}
