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
    @Environment(LabResultsManager.self) private var labResultsManager
    @State private var editedRecord: LabEntry
    @State private var editedIndex: Int
    @State private var showDeleteAlert = false
    @Environment(\.dismiss) var dismiss
    @Environment(NeutroFeverGuardScheduler.self) private var scheduler

    var body: some View {
        Form {
            Section {
                HStack {
                    Text("Date")
                    Spacer()
                    Text("\(labResultsManager.formatDate(editedRecord.date))")
                }
                HStack {
                    Text("Time")
                    Spacer()
                    Text("\(labResultsManager.formatTime(editedRecord.date))")
                }
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
            HStack {
                Spacer()
                Button("Delete", role: .destructive) {
                    showDeleteAlert = true
                }
                Spacer()
            }
        }
        .navigationTitle("Lab Details")
        .alert("Delete Lab Record", isPresented: $showDeleteAlert) {
                Button("Delete", role: .destructive) {
                    deleteRecord()
                }
                Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete this lab record? This action cannot be undone.")
        }
    }
    
    init(record: LabEntry, index: Int) {
        _editedRecord = State(initialValue: record)
        _editedIndex = State(initialValue: index)
    }
    
    private func deleteRecord() {
        labResultsManager.deleteLabEntry(at: editedIndex)
        labResultsManager.refresh()
        if editedIndex == 0 {
            if !labResultsManager.labRecords.isEmpty {
                let nextRecordDate = labResultsManager.labRecords[0].date
                if let newStartDate = Calendar.current.date(byAdding: .day, value: 7, to: nextRecordDate) {
                    scheduler.restartNotification(from: newStartDate)
                }
            } else {
                scheduler.restartNotification(from: Date())
            }
        }
        dismiss()
    }

    @ViewBuilder
    private func labValueRow(type: LabTestType, unit: String) -> some View {
        HStack {
            Text(type.rawValue)
            Spacer()
            Text("\(editedRecord.values[type] ?? 0, specifier: "%.1f") \(unit)")
        }
    }
}

struct LabView: View {
    @Environment(LabResultsManager.self) private var labResultsManager
    @Environment(Account.self) private var account: Account?
    @Binding var presentingAccount: Bool
//    @Environment(NeutroFeverGuardScheduler.self) private var scheduler

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
            .onAppear {
                labResultsManager.refresh()
//                scheduler.printUpcomingLabResultEvents()
            }
        }
    }
    
    private func ancSection() -> some View {
        Section(header: Text("Absolute Neutrophil Counts")) {
            if labResultsManager.getAncValue() != nil, !labResultsManager.labRecords.isEmpty {
                if let latestRecord = labResultsManager.labRecords.first {
                    NavigationLink(destination: LabResultDetailView(record: latestRecord, index: 0)) {
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
                ForEach(Array(labResultsManager.labRecords.enumerated()), id: \.element.date) { index, record in
                    NavigationLink(destination: LabResultDetailView(record: record, index: index)) {
                        Text(labResultsManager.formatDateTime(record.date))
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
