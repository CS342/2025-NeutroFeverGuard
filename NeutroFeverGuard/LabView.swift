//
//  LabView.swift
//  NeutroFeverGuard
//
//  Created by 杜思娴 on 2025/2/10.
//

import SpeziAccount
import SwiftUI

struct LabView: View {
    @State private var latestNeutrophilPercentage: Double = 55.0
    @State private var latestLeukocyteCount: Double = 4000.0
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
                // Section for Latest ANC
                Section(header: Text("Absolute Neutrophil Counts")) {
                    NavigationLink(destination: LabResultDetailView(record: labRecords[0])) {
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("🧪 Latest ANC")
                                    .font(.headline)
                                Text("\(ancValue, specifier: "%.1f")/µL")
                                   .font(.largeTitle)
                                   .bold()
                                   .foregroundColor(ancValue < 1500 ? .red : .green)
                                   .padding(.vertical, 8)
                                Text("Last recorded: \(latestRecordedTime)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
//                                Text("Your ANC is \(ancValue < 1500 ? "low" : "normal")")
//                                    .font(.subheadline)
//                                    .foregroundColor(ancValue < 1500 ? .red : .green)
                            }
                        }
                    }
                }

                // Section for Lab Records
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

#Preview {
    LabView(presentingAccount: .constant(false))
}
