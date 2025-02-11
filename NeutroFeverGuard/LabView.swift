//
// This source file is part of the NeutroFeverGuard based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SpeziAccount
import SwiftUI

struct ANCView: View {
    let ancValue: Double
    let latestRecordedTime: String

    var body: some View {
        let status = getANCStatus(ancValue)

        VStack(alignment: .leading, spacing: 8) {
            Text("🧪 Latest ANC")
                .font(.headline)
            Text("\(ancValue, specifier: "%.1f")/µL")
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
        case let anc where anc >= 1500:
            return ("Normal", .green)
        case let anc where anc >= 1000:
            return ("Mild Neutropenia", .orange)
        case let anc where anc >= 500:
            return ("Moderate Neutropenia", .red)
        case let anc where anc >= 100:
            return ("Severe Neutropenia", .red)
        default:
            return ("Profound Neutropenia", .red)
        }
    }
}


struct LabRecord: Identifiable {
    let id = UUID()
    let date: String
    var values: [LabTestType: Double]
}


struct LabResultDetailView: View {
    var record: LabRecord

    var body: some View {
        Form {
            Section(header: Text("Lab Values")) {
                ForEach(record.values.sorted(by: { $0.key.rawValue < $1.key.rawValue }), id: \.key) { key, value in
                    HStack {
                        Text(key.rawValue)
                        Spacer()
                        Text("\(value, specifier: "%.1f")")
                    }
                }
            }
        }
        .navigationTitle(record.date)
    }
}

struct LabView: View {
    @State private var latestNeutrophilPercentage: Double = 55.0
    @State private var latestLeukocyteCount: Double = 1000.0
    @State private var latestRecordedTime: String = "Feb 8, 2025"

    @State private var labRecords: [LabRecord] = [
        LabRecord(date: "Feb 8, 2025", values: [.whiteBloodCell: 4500, .neutrophils: 55]),
        LabRecord(date: "Feb 1, 2025", values: [.whiteBloodCell: 5000, .neutrophils: 52]),
        LabRecord(date: "Jan 25, 2025", values: [.whiteBloodCell: 4800, .neutrophils: 53])
    ]

    @State private var selectedRecord: LabRecord?
    
    @Environment(Account.self) private var account: Account?
    @Binding var presentingAccount: Bool

    private var ancValue: Double {
        (latestNeutrophilPercentage / 100.0) * latestLeukocyteCount
    }

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Absolute Neutrophil Counts")) {
                    NavigationLink(destination: LabResultDetailView(record: labRecords[0])) {
                        ANCView(ancValue: ancValue, latestRecordedTime: latestRecordedTime)
                    }
                }
                Section(header: Text("Lab Results History")) {
                    ForEach(labRecords) { record in
                        NavigationLink(destination: LabResultDetailView(record: record)) {
                            Text(record.date)
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
        }
    }
}


#Preview {
    LabView(presentingAccount: .constant(false))
}
