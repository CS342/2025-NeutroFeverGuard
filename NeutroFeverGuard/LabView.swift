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

struct ANCView: View {
    let ancValue: Double
    let latestRecordedTime: String

    var body: some View {
        let status = getANCStatus(ancValue)

        VStack(alignment: .leading, spacing: 8) {
            Text("🧪 Latest ANC")
                .font(.headline)
            Text("\(ancValue, specifier: "%.1f") cells/µL")
                .font(.largeTitle)
                .bold()
                .foregroundColor(status.color)
                .padding(.vertical, 8)
            
            Text(status.text)
                .font(.subheadline)
                .foregroundColor(status.color)
                .bold()
            Text("Last recorded: \(latestRecordedTime)")
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
    
    private func getANCStatus(_ ancValue: Double) -> (text: String, color: Color) {
        switch ancValue {
        case let anc where anc >= 500:
            return ("Normal", .green)
        case let anc where anc >= 100:
            return ("Severe Neutropenia", .orange)
        default:
            return ("Profound Neutropenia", .red)
        }
    }
}


struct LabResultDetailView: View {
    var record: LabEntry

    var body: some View {
        Form {
            Section(header: Text("Lab Values")) {
                labValueRow(type: .whiteBloodCell, unit: "cells/µL")
                labValueRow(type: .hemoglobin, unit: "g/dL")
                labValueRow(type: .plateletCount, unit: "cells/µL")
                labValueRow(type: .neutrophils, unit: "%")
                labValueRow(type: .lymphocytes, unit: "%")
                labValueRow(type: .monocytes, unit: "%")
                labValueRow(type: .eosinophils, unit: "%")
                labValueRow(type: .basophils, unit: "%")
                labValueRow(type: .blasts, unit: "%")
            }
        }
        .navigationTitle(formatDate(record.date))
    }

    @ViewBuilder
    private func labValueRow(type: LabTestType, unit: String) -> some View {
        HStack {
            Text(type.rawValue)
            Spacer()
            Text("\(record.values[type] ?? 0, specifier: "%.1f") \(unit)")
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct LabView: View {
    @State private var labRecords: [LabEntry] = []
    @State private var latestRecordedTime: String = "None"
    @Environment(LocalStorage.self) var localStorage
    @Environment(Account.self) private var account: Account?
    @Binding var presentingAccount: Bool

    private var ancValue: Double? {
        guard let latestRecord = labRecords.first,
              let neutrophils = latestRecord.values[.neutrophils],
              let wbc = latestRecord.values[.whiteBloodCell] else {
            return nil
        }
        return (neutrophils / 100.0) * wbc
    }

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Absolute Neutrophil Counts")) {
                    if let anc = ancValue, let latestRecord = labRecords.first {
                        NavigationLink(destination: LabResultDetailView(record: latestRecord)) {
                            ANCView(ancValue: anc, latestRecordedTime:latestRecordedTime)
                        }
                    } else {
                        Text("No ANC data available")
                            .foregroundColor(.gray)
                    }
                }
                
                Section(header: Text("Lab Results History")) {
                    if labRecords.isEmpty {
                        Text("No lab results recorded")
                            .foregroundColor(.gray)
                    } else {
                        ForEach(labRecords, id: \.date) { record in
                            NavigationLink(destination: LabResultDetailView(record: record)) {
                                Text(formatDate(record.date))
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Lab Results")
            .background(Color(.systemGray6))
            .toolbar {
                if account != nil {
                    AccountButton(isPresented: $presentingAccount)
                }
            }
            .onAppear {
                loadLabResults()
            }
        }
    }
    
    private func loadLabResults() {
        var results: [LabEntry]
        do {
            results = try localStorage.read([LabEntry].self, storageKey: "labResults")
            results.sort { $0.date > $1.date }
            labRecords = results
            
            if let latestRecord = results.first {
                latestRecordedTime = formatDate(latestRecord.date)
            } else {
                latestRecordedTime = "None"
            }
        } catch {
            print("Failed to load lab results: \(error)")
            labRecords = []
            latestRecordedTime = "None"
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}


#Preview {
    LabView(presentingAccount: .constant(false))
}
