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
    @Environment(\.dismiss) var dismiss
    
    @State private var isEditing = false
    @State private var showDeleteAlert = false
    @State private var editedRecord: LabEntry
    @State private var editedIndex: Int

    var body: some View {
        Form {
            Section {
                DatePicker("Date", selection: $editedRecord.date, displayedComponents: .date)
                    .disabled(true)
                DatePicker("Time", selection: $editedRecord.date, displayedComponents: .hourAndMinute)
                    .disabled(true)
                ForEach(LabTestType.allCases, id: \.self) { testType in
                    HStack {
                        Text(testType.rawValue)
                        Spacer()
                        TextField("Value", text: Binding(
                            get: { String(editedRecord.values[testType] ?? 0) },
                            set: { editedRecord.values[testType] = Double($0) }
                        ))
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 80)
                        .disabled(!isEditing)
                    }
                }
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
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(isEditing ? "Save" : "Edit") {
                    if isEditing {
                        saveChanges()
                    }
                    isEditing.toggle()
                }
            }
        }
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

    private func saveChanges() {
        labResultsManager.updateLabEntry(at: editedIndex, with: editedRecord)
        labResultsManager.refresh()
    }

    private func deleteRecord() {
        labResultsManager.deleteLabEntry(at: editedIndex)
        labResultsManager.refresh()
        dismiss()
    }
}

struct LabView: View {
    @Environment(LabResultsManager.self) private var labResultsManager
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
