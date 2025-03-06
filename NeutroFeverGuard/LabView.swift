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
    @Environment(LabResultsManager.self) private var labResultsManager

    var body: some View {
        let status = labResultsManager.getANCStatus()

        VStack(alignment: .leading, spacing: 8) {
            Text("🧪 Latest ANC")
                .font(.headline)
            if let ancValue = labResultsManager.getAncValue() {
                Text("\(ancValue, specifier: "%.1f") cells/µL")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(status.color)
                    .padding(.vertical, 8)
            } else {
                Text("No ANC data available")
                    .foregroundColor(.gray)
            }
            Text(status.text)
                .font(.subheadline)
                .foregroundColor(status.color)
                .bold()
            Text("Last recorded: \(labResultsManager.latestRecordedTime)")
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}


struct LabResultDetailView: View {
    var record: LabEntry
    
    @Environment(LabResultsManager.self) private var labResultsManager

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
        .navigationTitle(labResultsManager.formatDate(record.date))
    }

    @ViewBuilder
    private func labValueRow(type: LabTestType, unit: String) -> some View {
        HStack {
            Text(type.rawValue)
            Spacer()
            Text("\(record.values[type] ?? 0, specifier: "%.1f") \(unit)")
        }
    }
}

struct LabView: View {
    @Environment(LabResultsManager.self) private var labResultsManager
    @Environment(LocalStorage.self) var localStorage
    @Environment(Account.self) private var account: Account?
    @Binding var presentingAccount: Bool

    var body: some View {
        NavigationView {
            List {
                ancSection()
                labHistorySection()
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Lab Results")
            .background(Color(.systemGray6))
            .toolbar { toolbarContent() }
            .onAppear { labResultsManager.refresh() }
        }
    }
    
    private func ancSection() -> some View {
        Section(header: Text("Absolute Neutrophil Counts")) {
            if labResultsManager.getAncValue() != nil, !labResultsManager.labRecords.isEmpty {
                if let latestRecord = labResultsManager.labRecords.first {
                    NavigationLink(destination: LabResultDetailView(record: latestRecord)) {
                        ANCView()
                    }
                }
            } else {
                Text("No ANC data available").foregroundColor(.gray)
            }
        }
    }

    private func labHistorySection() -> some View {
        Section(header: Text("Lab Results History")) {
            if labResultsManager.labRecords.isEmpty {
                Text("No lab results recorded").foregroundColor(.gray)
            } else {
                ForEach(labResultsManager.labRecords, id: \.date) { record in
                    NavigationLink(destination: LabResultDetailView(record: record)) {
                        Text(labResultsManager.formatDate(record.date))
                    }
                }
            }
        }
    }

    private func toolbarContent() -> some ToolbarContent {
        ToolbarItem {
            if account != nil {
                AccountButton(isPresented: $presentingAccount)
            }
        }
    }
}

#Preview {
    LabView(presentingAccount: .constant(false))
}
