//
// This source file is part of the NeutroFeverGuard based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

// swiftlint:disable file_length
import SpeziLocalStorage
import SpeziViews
import SwiftUI

struct LabResultsForm: View {
    @Binding var labValues: [LabTestType: String]
    
    var body: some View {
        labInputRow(type: .whiteBloodCell, unit: "cells/µL")
        labInputRow(type: .hemoglobin, unit: "g/dL")
        labInputRow(type: .plateletCount, unit: "cells/µL")
        labInputRow(type: .neutrophils, unit: "%")
        labInputRow(type: .lymphocytes, unit: "%")
        labInputRow(type: .monocytes, unit: "%")
        labInputRow(type: .eosinophils, unit: "%")
        labInputRow(type: .basophils, unit: "%")
        labInputRow(type: .blasts, unit: "%")
    }
    
    private func labInputRow(type: LabTestType, unit: String) -> some View {
        HStack {
            Text(type.rawValue)
                .frame(alignment: .leading)
            Spacer()
            TextField("", text: Binding(
                get: { labValues[type] ?? "" },
                set: { labValues[type] = $0 }
            ))
            .keyboardType(.decimalPad)
            .multilineTextAlignment(.trailing)
            .frame(width: 80)

            Text(unit)
                .frame(minWidth: 60, alignment: .leading)
                .foregroundColor(.gray)
        }
    }
}

struct MedicationForm: View {
    @Binding var medicationName: String
    @Binding var doseValue: String
    @Binding var doseUnit: DoseUnit
    
    var body: some View {
        HStack {
            Text("Name")
            Spacer()
            TextField("Medication Name", text: $medicationName).multilineTextAlignment(.trailing)
        }
        HStack {
            Text("Dose")
            Spacer()
            TextField("Amount", text: $doseValue)
                .keyboardType(.decimalPad) .multilineTextAlignment(.trailing) .frame(width: 80)
            Picker("", selection: $doseUnit) {
                ForEach(DoseUnit.allCases, id: \.self) { unit in Text(unit.rawValue).tag(unit) }
            }
            .pickerStyle(.menu) .frame(width: 70)
        }
    }
}


struct HeartRateForm: View {
    @Binding var inputValue: String
    
    var body: some View {
        HStack {
            Text("Rate (bpm)")
            Spacer()
            TextField("", text: $inputValue)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
        }
    }
}

struct TemperatureForm: View {
    @Binding var inputValue: String
    @Binding var temperatureUnit: TemperatureUnit
    
    var body: some View {
        HStack {
            Text("Temperature")
            Spacer()
            TextField("value", text: $inputValue)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
            Picker("", selection: $temperatureUnit) {
                Text("°F").tag(TemperatureUnit.fahrenheit)
                Text("°C").tag(TemperatureUnit.celsius)
            }
            .pickerStyle(.menu)
            .frame(width: 60)
        }
    }
}

struct OxygenSaturationForm: View {
    @Binding var inputValue: String
    
    var body: some View {
        HStack {
            Text("Percentage (%)")
            Spacer()
            TextField("", text: $inputValue)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
        }
    }
}

struct BloodPressureForm: View {
    @Binding var systolicValue: String
    @Binding var diastolicValue: String
    
    var body: some View {
        HStack {
            Text("Systolic (mmHg)")
            Spacer()
            TextField("", text: $systolicValue)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
        }
        HStack {
            Text("Diastolic (mmHg)")
            Spacer()
            TextField("", text: $diastolicValue)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
        }
    }
}

struct SymptomForm: View {
    @Binding var selectedSymptoms: Set<Symptom>
    @Binding var symptomSeverity: [Symptom: String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Are you experiencing any of:")
                .font(.headline)
                .padding(.bottom, 4)
            
            ForEach(Symptom.allCases, id: \.self) { symptom in
                VStack(alignment: .leading, spacing: 4) {
                    Toggle(symptom.rawValue, isOn: Binding(
                        get: { selectedSymptoms.contains(symptom) },
                        set: { isSelected in
                            if isSelected {
                                selectedSymptoms.insert(symptom)
                            } else {
                                selectedSymptoms.remove(symptom)
                                symptomSeverity.removeValue(forKey: symptom)
                            }
                        }
                    ))
                    
                    if selectedSymptoms.contains(symptom) {
                        HStack {
                            Text("Rate your \(symptom.rawValue.lowercased()) (1-10):")
                            TextField("1-10", text: Binding(
                                get: { symptomSeverity[symptom] ?? "" },
                                set: { symptomSeverity[symptom] = $0 }
                            ))
                            .keyboardType(.numberPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 80)
                            .accessibilityIdentifier("severity-\(symptom.rawValue)")
                        }
                        .padding(.leading, 8)
                    }
                }
                .padding(.vertical, 2)
            }
        }
        .padding(8)
    }
}

struct MasccForm: View {
    @Binding var selectedSymptoms: Set<MasccSymptom>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Please select all that apply:")
                .font(.headline)
                .padding(.bottom, 4)
            
            Group {
                Text("Burden of illness (select only one)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.top, 8)
                
                Toggle("Mild symptoms (+5)", isOn: bindingFor(.mildSymptoms))
                Toggle("Moderate symptoms (+3)", isOn: bindingFor(.moderateSymptoms))
                Toggle("Severe symptoms (+0)", isOn: bindingFor(.severeSymptoms))
            }
            
            Group {
                Text("Other factors")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.top, 8)
                
                Toggle("No hypotension (sBP ≥90 mmHg) (+5)", isOn: bindingFor(.noHypotension))
                Toggle("No COPD (+4)", isOn: bindingFor(.noCOPD))
                Toggle("Solid tumor or no prior fungal infection (+4)", isOn: bindingFor(.solidTumor))
                Toggle("No dehydration requiring IV fluids (+3)", isOn: bindingFor(.noDehydration))
                Toggle("Age < 60 years (+2)", isOn: bindingFor(.ageUnder60))
            }
            
            if !selectedSymptoms.isEmpty {
                Text("Total Score: \(calculateTotal())")
                    .font(.headline)
                    .padding(.top, 16)
            }
        }
        .padding()
    }
    
    private func bindingFor(_ symptom: MasccSymptom) -> Binding<Bool> {
        Binding(
            get: { selectedSymptoms.contains(symptom) },
            set: { isSelected in
                if isSelected {
                    selectedSymptoms.insert(symptom)
                } else {
                    selectedSymptoms.remove(symptom)
                }
            }
        )
    }
    
    private func calculateTotal() -> Int {
        selectedSymptoms.map(\.score).reduce(0, +)
    }
}

// swiftlint:disable type_body_length
struct DataInputForm: View {
    let dataType: String
    @Environment(LabResultsManager.self) var labResultsManager
    @Environment(MedicationManager.self) private var medicationManager
    @Environment(HealthKitService.self) var healthKitService
    @Environment(SymptomManager.self) private var symptomManager
    @Environment(MasccManager.self) private var masccManager
    
    @State private var date = Date()
    @State private var time = Date()
    @State private var inputValue: String = ""
    @State private var systolicValue: String = ""
    @State private var diastolicValue: String = ""
    @State private var temperatureUnit: TemperatureUnit = .fahrenheit
    @State private var labValues: [LabTestType: String] = [:]
    @State private var medicationName: String = ""
    @State private var doseValue: String = ""
    @State private var doseUnit: DoseUnit = .mgUnit
    @State private var alertMessage: String = ""
    @Environment(\.dismiss) var dismiss
    @Environment(NeutroFeverGuardScheduler.self) private var scheduler
    @State private var selectedSymptoms: Set<Symptom> = []
    @State private var symptomSeverity: [Symptom: String] = [:]
    @State private var showWarningAlert = false
    @State private var warningMessage = ""
    @State private var selectedMasccSymptoms: Set<MasccSymptom> = []
    
    var onDismissWithWarning: ((String) -> Void)?
    
    var isFormValid: Bool {
        switch dataType {
        case "Heart Rate":
            return !inputValue.isEmpty
        case "Temperature":
            return !inputValue.isEmpty
        case "Oxygen Saturation":
            return !inputValue.isEmpty
        case "Blood Pressure":
            return !systolicValue.isEmpty && !diastolicValue.isEmpty
        case "Lab Results":
            return LabTestType.allCases.allSatisfy { testType in
                !(labValues[testType] ?? "").isEmpty
            }
        case "Medication":
            return !medicationName.isEmpty && !doseValue.isEmpty
        case "Symptoms":
            return !selectedSymptoms.isEmpty && selectedSymptoms.allSatisfy { symptom in
                guard let severityStr = symptomSeverity[symptom],
                      let severity = Int(severityStr) else {
                    return false
                }
                return severity >= 1 && severity <= 10
            }
        case "MASCC Index":
            let hasOneSymptomSeverity = [MasccSymptom.mildSymptoms, .moderateSymptoms, .severeSymptoms]
                .filter { selectedMasccSymptoms.contains($0) }
                .count == 1
            return hasOneSymptomSeverity
        default:
            return false
        }
    }
    
    
    var body: some View {
        NavigationView {
            Form {
                DatePicker("Date", selection: $date, displayedComponents: .date)
                DatePicker("Time", selection: $time, displayedComponents: .hourAndMinute)
                if dataType == "Heart Rate" {
                    HeartRateForm(inputValue: $inputValue)
                } else if dataType == "Temperature" {
                    TemperatureForm(inputValue: $inputValue, temperatureUnit: $temperatureUnit)
                } else if dataType == "Oxygen Saturation" {
                    OxygenSaturationForm(inputValue: $inputValue)
                } else if dataType == "Blood Pressure" {
                    BloodPressureForm(systolicValue: $systolicValue, diastolicValue: $diastolicValue)
                } else if dataType == "Lab Results" {
                    LabResultsForm(labValues: $labValues)
                } else if dataType == "Medication" {
                    MedicationForm( medicationName: $medicationName, doseValue: $doseValue, doseUnit: $doseUnit)
                } else if dataType == "Symptoms" {
                    SymptomForm(selectedSymptoms: $selectedSymptoms, symptomSeverity: $symptomSeverity)
                } else if dataType == "MASCC Index" {
                    MasccForm(selectedSymptoms: $selectedMasccSymptoms)
                }
            }
            .navigationTitle(dataType)
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: AsyncButton("Add") {
                    do {
                        try await healthKitService.requestAuthorization()
                        await addData()
                    } catch { print("Error requesting HealthKit authorization: \(error)") }
                }.disabled(!isFormValid)
            )
        }
        .alert("Error", isPresented: .constant(!alertMessage.isEmpty)) {
            Button("OK") { alertMessage = "" }
        } message: {
            Text(alertMessage)
        }
        .alert("Warning", isPresented: $showWarningAlert) {
            Button("Acknowledge") {
                showWarningAlert = false
            }
        } message: {
            Text(warningMessage)
        }
    }
    
    init(dataType: String, onDismissWithWarning: ((String) -> Void)? = nil) {
        self.dataType = dataType
        self.onDismissWithWarning = onDismissWithWarning
    }
    
    func addData() async {
        switch dataType {
        case "Heart Rate":
            await addHeartRate()
        case "Temperature":
            await addTemperature()
        case "Oxygen Saturation":
            await addOxygenSaturation()
        case "Blood Pressure":
            await addBloodPressure()
        case "Lab Results":
            await addLabResult()
        case "Medication":
            await addMedication()
        case "Symptoms":
            await addSymptoms()
        case "MASCC Index":
            await addMascc()
        default:
            alertMessage = "Unknown data type"
        }
    }

    func addHeartRate() async {
        guard let bpm = parseLocalizedNumber(inputValue) else {
            alertMessage = "BPM must be a valid number"
            return
        }
        do {
            let heartRateEntry = try HeartRateEntry(date: combineDateAndTime(date, time), bpm: bpm)
            try await healthKitService.saveHeartRate(heartRateEntry)
            dismiss()
        } catch let error as DataError {
            alertMessage = "Error: \(error.errorMessage)"
        } catch {
            alertMessage = "Error: \(error)"
        }
    }

    func addTemperature() async {
        guard let value = parseLocalizedNumber(inputValue) else {
            alertMessage = "Temperature must be a valid number"
            return
        }
        do {
            let temperatureEntry = try TemperatureEntry(date: combineDateAndTime(date, time), value: value, unit: temperatureUnit)
            try await healthKitService.saveTemperature(temperatureEntry)
            dismiss()
        } catch let error as DataError {
            alertMessage = "Error: \(error.errorMessage)"
        } catch {
            alertMessage = "Error: \(error)"
        }
    }

    func addOxygenSaturation() async {
        guard let percentage = parseLocalizedNumber(inputValue) else {
            alertMessage = "Percentage must be a valid number"
            return
        }
        do {
            let oxygenEntry = try OxygenSaturationEntry(date: combineDateAndTime(date, time), percentage: percentage)
            try await healthKitService.saveOxygenSaturation(oxygenEntry)
            dismiss()
        } catch let error as DataError {
            alertMessage = "Error: \(error.errorMessage)"
        } catch {
            alertMessage = "Error: \(error)"
        }
    }

    func addBloodPressure() async {
        guard let systolic = parseLocalizedNumber(systolicValue),
              let diastolic = parseLocalizedNumber(diastolicValue) else {
            alertMessage = "Blood pressure values must be valid numbers"
            return
        }
        do {
            let bloodPressureEntry = try BloodPressureEntry(date: combineDateAndTime(date, time), systolic: systolic, diastolic: diastolic)
            try await healthKitService.saveBloodPressure(bloodPressureEntry)
            dismiss()
        } catch let error as DataError {
            alertMessage = "Error: \(error.errorMessage)"
        } catch {
            alertMessage = "Error: \(error)"
        }
    }

    func addLabResult() async {
        var parsedValues: [LabTestType: Double] = [:]
        
        for (testType, valueString) in labValues {
            if let value = parseLocalizedNumber(valueString) {
                parsedValues[testType] = value
            } else {
                alertMessage = "\(testType.rawValue) must be a valid number"
                return
            }
        }
        
        do {
            let labEntry = try LabEntry(date: combineDateAndTime(date, time), values: parsedValues)
            labResultsManager.addLabEntry(labEntry)
            
            scheduler.markRecentEventsAsComplete(combineDateAndTime(date, time))
            
            dismiss()
        } catch {
            alertMessage = "Error: \(error)"
        }
    }
    
    func addMedication() async {
        guard !medicationName.isEmpty, !doseValue.isEmpty else {
            alertMessage = "Medication name and dosage cannot be empty"
            return
        }
        
        do {
            guard let value = parseLocalizedNumber(doseValue) else {
                alertMessage = "Dose value must be valid numbers"
                return
            }
            let medicationEntry = try MedicationEntry(
                date: combineDateAndTime(date, time),
                name: medicationName,
                doseValue: value,
                doseUnit: doseUnit
            )
            medicationManager.addMedEntry(medicationEntry)
            dismiss()
        } catch let error as DataError {
            alertMessage = "Error: \(error.errorMessage)"
        } catch {
            alertMessage = "Error: \(error)"
        }
    }
    
    private func generateWarningMessage(from symptoms: [Symptom: Int]) -> String {
        var warnings: [String] = []
        
        for (symptom, severity) in symptoms {
            if severity >= 7 {
                warnings.append("severe \(symptom.rawValue.lowercased())")
            } else if severity >= 4 {
                warnings.append("moderately severe \(symptom.rawValue.lowercased())")
            }
        }
        
        if warnings.isEmpty {
            return ""
        }
        
        let prefix = "You should see your provider for "
        
        if warnings.count == 1 {
            return prefix + warnings[0]
        } else if warnings.count == 2 {
            return prefix + warnings.joined(separator: " and ")
        } else {
            // For 3 or more items, join all but the last with commas, then add "and" before the last
            // swiftlint:disable force_unwrapping
            let lastWarning = warnings.last!
            let allButLast = warnings.dropLast()
            return prefix + allButLast.joined(separator: ", ") + ", and " + lastWarning
        }
    }
    
    func addSymptoms() async {
        var symptoms: [Symptom: Int] = [:]
        
        for symptom in selectedSymptoms {
            if let severityStr = symptomSeverity[symptom],
               let severity = Int(severityStr) {
                symptoms[symptom] = severity
            }
        }
        
        do {
            let symptomEntry = try SymptomEntry(
                date: combineDateAndTime(date, time),
                symptoms: symptoms
            )
            symptomManager.addSymptomEntry(symptomEntry)
            
            // Generate warning message if needed
            let warning = generateWarningMessage(from: symptoms)
            dismiss()
            
            if !warning.isEmpty {
                onDismissWithWarning?(warning)
            }
        } catch {
            alertMessage = "Error: \(error)"
        }
    }
    
    func generateMasccWarning(score: Int) -> String {
        if score < 21 {
            return "⚠️ Your MASCC score is \(score). This indicates HIGH RISK for complications. Seek medical attention."
        } else {
            return "✓ Your MASCC score is \(score). This indicates LOW RISK. Continue monitoring your symptoms."
        }
    }

    func addMascc() async {
        do {
            let masccEntry = try MasccEntry(
                date: combineDateAndTime(date, time),
                symptoms: Array(selectedMasccSymptoms)
            )
            
            masccManager.addMasccEntry(masccEntry)
            
            let totalScore = selectedMasccSymptoms.map(\.score).reduce(0, +)
            let warning = generateMasccWarning(score: totalScore)
            dismiss()
            onDismissWithWarning?(warning)
        } catch {
            alertMessage = "Error: \(error)"
        }
    }
}

#Preview {
//    DataInputForm(dataType: "Temperature")
//    DataInputForm(dataType: "Heart Rate")
//    DataInputForm(dataType: "Oxygen Saturation")
//    DataInputForm(dataType: "Blood Pressure")
//    DataInputForm(dataType: "Lab Results")
    DataInputForm(dataType: "Medication")
}
