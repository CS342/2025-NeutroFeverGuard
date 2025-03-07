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

struct MedicationEditForm: View {
    @Environment(MedicationManager.self) private var medicationManager
    @State var medication: MedicationEntry
    @State private var date: Date
    @State private var time: Date
    @State private var name: String
    @State private var doseValue: String
    @State private var doseUnit: DoseUnit
    var onSave: (MedicationEntry) -> Void
    var onCancel: () -> Void
    @State private var alertMessage: String = ""
    
    var isFormValid: Bool {
        !name.isEmpty && !doseValue.isEmpty
    }
    
    var body: some View {
        NavigationStack {
            Form {
                DatePicker("Date", selection: $date, displayedComponents: .date)
                DatePicker("Time", selection: $time, displayedComponents: .hourAndMinute)
                HStack {
                    Text("Name")
                    Spacer()
                    TextField("Medication Name", text: $medication.name)
                        .multilineTextAlignment(.trailing)
                }
                HStack {
                    Text("Dose")
                    Spacer()
                    TextField("Amount", text: $doseValue).keyboardType(.decimalPad) .multilineTextAlignment(.trailing) .frame(width: 80)
                    Picker("", selection: $doseUnit) {
                        ForEach(DoseUnit.allCases, id: \.self) { unit in Text(unit.rawValue).tag(unit) }
                    } .pickerStyle(.menu) .frame(width: 70)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { onCancel() }
                }
                ToolbarItem {
                    Button("Save") {
                        checkMed()
                        onSave(medication)
                    }.disabled(!isFormValid)
                }
            }
            .alert(isPresented: .constant(!alertMessage.isEmpty)) {
                Alert(
                    title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")) { alertMessage = "" }
                )
            }
        }
    }
    
    init(medication: MedicationEntry, onSave: @escaping (MedicationEntry) -> Void, onCancel: @escaping () -> Void) {
        self.medication = medication
        self.date = medication.date
        self.time = medication.date
        self.name = medication.name
        self.doseValue = String(medication.doseValue)
        self.doseUnit = medication.doseUnit
        self.onSave = onSave
        self.onCancel = onCancel
    }
    
    private func checkMed() {
        guard let value = parseLocalizedNumber(doseValue) else {
            alertMessage = "Invalid dose value. Please enter a number."
            return
        }
        medication.doseValue = value
        medication.date = combineDateAndTime(date, time)
        medication.doseUnit = doseUnit
    }
}

struct MedicationView: View {
    @Environment(MedicationManager.self) private var medicationManager
    @Environment(Account.self) private var account: Account?
    @State private var isEditing = false
    @State private var editingMedicationIndex: Int = 0
    @Binding var presentingAccount: Bool

    var body: some View {
        NavigationView {
            List {
                if medicationManager.medications.isEmpty {
                    Text("No medications recorded")
                        .font(.headline)
                } else {
                    ForEach(Array(medicationManager.medications.enumerated()), id: \.element.date) { index, medication in
                        MedicationRow(medication: medication)
                            .swipeActions(edge: .leading) {
                                Button("Edit") {
                                    editingMedicationIndex = index
                                    isEditing = true
                                }.tint(.blue)
                            }
                    }
                    .onDelete { offsets in medicationManager.deleteMedEntry(at: offsets) }
                }
            }
            .navigationTitle("Medication List")
            .onAppear { medicationManager.refresh() }
            .listStyle(.insetGrouped)
            .background(Color(.systemGray6))
            .toolbar { if account != nil { AccountButton(isPresented: $presentingAccount) } }
            .sheet(isPresented: $isEditing) {
                let index = editingMedicationIndex
                MedicationEditForm(
                    medication: medicationManager.medications[index],
                    onSave: {updatedMedication in
                        medicationManager.updateMedEntry(at: index, with: updatedMedication)
                        isEditing = false
                    },
                    onCancel: {
                        isEditing = false
                    }
                )
            }
        }
    }
}
