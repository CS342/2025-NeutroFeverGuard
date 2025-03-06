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
    @Binding var medication: MedicationEntry
    @State private var date: Date
    @State private var time: Date
    @State private var doseValue: String
    @State private var alertMessage: String = ""
    var onSave: () -> Void
    var onCancel: () -> Void
    
    var isFormValid: Bool {
        var ret = !medication.name.isEmpty && !doseValue.isEmpty
        return ret
    }
    
    var body: some View {
        NavigationStack {
            Form {
                DatePicker("Date", selection: $date, displayedComponents: .date)
                DatePicker("Time", selection: $time, displayedComponents: .hourAndMinute)
                HStack {
                    Text("Name")
                    Spacer()
                    TextField("Medication Name", text: $medication.name) .multilineTextAlignment(.trailing)
                }
                HStack {
                    Text("Dose")
                    Spacer()
                    TextField("Amount", text: $doseValue) .keyboardType(.decimalPad) .multilineTextAlignment(.trailing) .frame(width: 80)
                    Picker("", selection: $medication.doseUnit) {
                        ForEach(DoseUnit.allCases, id: \.self) { unit in Text(unit.rawValue).tag(unit) }
                    }.pickerStyle(.menu).frame(width: 70)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) { Button("Cancel") { onCancel() } }
                ToolbarItem { Button("Save") {
                    guard let value = parseLocalizedNumber(doseValue) else {
                        alertMessage = "Invalid dose value. Please enter a number."
                        return
                    }
                    medication.doseValue = value
                    medication.date = combineDateAndTime(date, time)
                    onSave()
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
    
    init(medication: Binding<MedicationEntry>, onSave: @escaping () -> Void, onCancel: @escaping () -> Void) {
        self._medication = medication
        self._date = State(initialValue: medication.wrappedValue.date)
        self._time = State(initialValue: medication.wrappedValue.date)
        self._doseValue = State(initialValue: String(medication.wrappedValue.doseValue))
        self.onSave = onSave
        self.onCancel = onCancel
    }
}

struct MedicationView: View {
    @State private var medications: [MedicationEntry] = []
    @Environment(LocalStorage.self) var localStorage
    @Environment(Account.self) private var account: Account?
    @State private var isEditing = false
    @State private var editingMedicationIndex: Int = 0
    @Binding var presentingAccount: Bool

    var body: some View {
        NavigationView {
            List {
                if medications.isEmpty {
                    Text("No medications recorded").font(.headline)
                } else {
                    ForEach(Array(medications.enumerated()), id: \.element.name) { index, medication in
                        MedicationRow(medication: medication)
                            .swipeActions(edge: .leading) {
                                Button("Edit") { editMedication(at: index) }.tint(.blue)
                            }
                    }
                    .onDelete(perform: deleteMedication)
                }
            }
            .navigationTitle("Medication List")
            .onAppear { loadMedications() }
            .listStyle(.insetGrouped)
            .background(Color(.systemGray6))
            .toolbar {
                if account != nil { AccountButton(isPresented: $presentingAccount) }
            }
            .sheet(isPresented: $isEditing) {
                let ind = editingMedicationIndex
                MedicationEditForm(
                    medication: $medications[ind],
                    onSave: {
                        saveMedications()
                        isEditing = false
                        loadMedications()
                    },
                    onCancel: {
                        isEditing = false
                    }
                )
            }
        }
    }

    private func loadMedications() {
        do {
            medications = try localStorage.load(LocalStorageKey<[MedicationEntry]>("medications")) ?? []
            medications.sort { $0.date > $1.date }
        } catch {
            print("Failed to load medications: \(error)")
            medications = []
        }
    }
    
    private func deleteMedication(at offsets: IndexSet) {
        medications.remove(atOffsets: offsets)
        saveMedications()
    }

    private func saveMedications() {
        do {
            try localStorage.store(medications, for: LocalStorageKey<[MedicationEntry]>("medications"))
        } catch {
            print("Failed to save medications: \(error)")
        }
    }
    
    private func editMedication(at index: Int) {
        editingMedicationIndex = index
        isEditing = true
    }
}
