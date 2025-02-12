//
// This source file is part of the NeutroFeverGuard based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SpeziSecureStorage
import SpeziViews
import SwiftUI

struct DataInputForm: View {
    let dataType: String
    @State private var date = Date()
    @State private var time = Date()
    @State private var inputValue: String = ""
    @State private var systolicValue: String = ""
    @State private var diastolicValue: String = ""
    @State private var temperatureUnit: TemperatureUnit = .fahrenheit
    @State private var labValues: [String: String] = [:]
    @Environment(\.dismiss) var dismiss
    
    private let healthKitService: HealthKitService
    
    init(dataType: String) {
        self.dataType = dataType
        self.healthKitService = HealthKitService()
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
                }
            }
            .navigationTitle(dataType)
            .navigationBarItems(leading: Button("Cancel") {
                dismiss()
            }, trailing: AsyncButton("Add") {
                Task {
                    await addData()
                }
            })
        }
    }
    
    func addData() async {
        // Combine date and time components
        let calendar = Calendar.current
        let timeComponents: DateComponents = calendar.dateComponents([.hour, .minute], from: time)
        let finalDate: Date = calendar.date(bySettingHour: timeComponents.hour ?? 0,
            minute: timeComponents.minute ?? 0,
            second: 0,
            of: date
        ) ?? date
        
        do {
            
            switch dataType {
            // change to enum
            case "Heart Rate":
                if let bpm = Double(inputValue) {
                    let heartRateEntry: HeartRateEntry = try HeartRateEntry(date: finalDate, bpm: bpm)
                    try await healthKitService.saveHeartRate(heartRateEntry)
                }
            case "Temperature":
                if let value = Double(inputValue) {
                    let temperatureEntry: TemperatureEntry = try TemperatureEntry(date: finalDate, value: value, unit: temperatureUnit)
                    try await healthKitService.saveTemperature(temperatureEntry)
                }
            case "Oxygen Saturation":
                if let percentage = Double(inputValue) {
                    let oxygenEntry: OxygenSaturationEntry = try OxygenSaturationEntry(date: finalDate, percentage: percentage)
                    try await healthKitService.saveOxygenSaturation(oxygenEntry)
                }
            case "Blood Pressure":
                if let systolic = Double(systolicValue), let diastolic = Double(diastolicValue) {
                    let bloodPressureEntry: BloodPressureEntry = try BloodPressureEntry(date: finalDate, systolic: systolic, diastolic: diastolic)
                    try await healthKitService.saveBloodPressure(bloodPressureEntry)
                }
            default:
                break
            }
        } catch {
            print("Error saving to HealthKit: \(error)")
        }
        
        dismiss()
    }
}

struct LabResultsForm: View {
    @Binding var labValues: [String: String]
    
    var body: some View {
        Group {
            LabeledTextField("White Blood Cell Count", value: binding(for: "wbc"))
            LabeledTextField("Hemoglobin", value: binding(for: "hemoglobin"))
            LabeledTextField("Platelet Count", value: binding(for: "platelets"))
            LabeledTextField("Neutrophils %", value: binding(for: "neutrophils"))
            LabeledTextField("Lymphocytes %", value: binding(for: "lymphocytes"))
            LabeledTextField("Monocytes %", value: binding(for: "monocytes"))
            LabeledTextField("Eosinophils %", value: binding(for: "eosinophils"))
            LabeledTextField("Basophils %", value: binding(for: "basophils"))
            LabeledTextField("Blasts %", value: binding(for: "blasts"))
        }
    }
    
    private func binding(for key: String) -> Binding<String> {
        Binding(
            get: { labValues[key] ?? "" },
            set: { labValues[key] = $0 }
            
        )
    }
}

struct LabeledTextField: View {
    let label: String
    @Binding var value: String
    
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
    DataInputForm(dataType: "Heart Rate")
    // DataInputForm(dataType: "Oxygen Saturation")
    // DataInputForm(dataType: "Blood Pressure")
}
