//
// This source file is part of the NeutroFeverGuard based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//
// swiftlint:disable file_types_order

import SpeziLocalStorage
import SpeziViews
import SwiftUI

struct DataInputForm: View {
    let dataType: String
    @Environment(LocalStorage.self) var localStorage
    private var healthKitService: HealthKitService {
        HealthKitService(localStorage: localStorage)
    }
    
    @State private var date = Date()
    @State private var time = Date()
    @State private var inputValue: String = ""
    @State private var systolicValue: String = ""
    @State private var diastolicValue: String = ""
    @State private var temperatureUnit: TemperatureUnit = .fahrenheit
    @State private var labValues: [LabTestType: String] = [:]
    @State private var alertMessage: String = ""
    @Environment(\.dismiss) var dismiss
    
    // swiftlint:disable:next type_contents_order
    init(dataType: String) {
        self.dataType = dataType
    }
    
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
        default:
            return false
        }
    }
    
    
    var body: some View {
        // swiftlint:disable:next closure_body_length
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
                }
            }
            .navigationTitle(dataType)
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: AsyncButton("Add") {
                    do {
                        try await healthKitService.requestAuthorization()
                        await addData()
                    } catch {
                        print("Error requesting HealthKit authorization: \(error)")
                    }
                }.disabled(!isFormValid)
            )
            .alert(isPresented: .constant(!alertMessage.isEmpty)) {
                Alert(
                    title: Text("Error"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK")) {
                        alertMessage = ""
                    }
                )
            }
        }
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
        default:
            alertMessage = "Unknown data type"
        }
    }

    func addHeartRate() async {
        guard let bpm = Double(inputValue) else {
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
        guard let value = Double(inputValue) else {
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
        guard let percentage = Double(inputValue) else {
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
        guard let systolic = Double(systolicValue), let diastolic = Double(diastolicValue) else {
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
            if let value = Double(valueString) {
                parsedValues[testType] = value
            } else {
                alertMessage = "\(testType.rawValue) must be a valid number"
                return
            }
        }
        
        do {
            let labEntry = try LabEntry(date: combineDateAndTime(date, time), values: parsedValues)
            try await healthKitService.saveLabEntry(labEntry)
            dismiss()
        } catch {
            alertMessage = "Error: \(error)"
        }
    }
}

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

struct LabeledTextField: View {
    let label: String
    @Binding var value: String
    
    // swiftlint:disable:next type_contents_order
    init(_ label: String, value: Binding<String>) {
        self.label = label
        self._value = value
    }
    
    var body: some View {
        HStack {
            Text(label)
            Spacer()
            TextField("value", text: $value)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
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

#Preview {
//    DataInputForm(dataType: "Temperature")
//    DataInputForm(dataType: "Heart Rate")
//    DataInputForm(dataType: "Oxygen Saturation")
//    DataInputForm(dataType: "Blood Pressure")
    DataInputForm(dataType: "Lab Results")
}
