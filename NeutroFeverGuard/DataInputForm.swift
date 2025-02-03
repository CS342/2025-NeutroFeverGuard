//
//  DataInputForm.swift
//  NeutroFeverGuard
//
//  Created by dusixian on 2025/2/2.
//

import SwiftUI

struct DataInputForm: View {
    let dataType: String
    @State private var date = Date()
    @State private var time = Date()
    @State private var inputValue: String = ""
    @State private var systolicValue: String = ""
    @State private var diastolicValue: String = ""
    @State private var temperatureUnit: TemperatureUnit = .fahrenheit
    @State private var labTestType: LabTestType = .whiteBloodCell
    @State private var alertMessage: String = ""
    @Environment(\.dismiss) var dismiss
    
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
            return !inputValue.isEmpty
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
                    LabResultsForm(inputValue: $inputValue, labTestType: $labTestType)
                }
            }
            .navigationTitle(dataType)
            .navigationBarItems(leading: Button("Cancel") {
                dismiss()
            }, trailing: Button("Add") {
                addData()
            }.disabled(!isFormValid))
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
    
    func addData() {
        switch dataType {
        case "Heart Rate":
            if let bpm = Double(inputValue) {
                do {
                    let heartRateEntry = try HeartRateEntry(date: date, bpm: bpm)
                    print("Heart Rate Entry: \(heartRateEntry)")
                } catch {
                    alertMessage = "Error: \(error)"
                }
            }
            else{
                alertMessage = "bpm must be a valid number"
            }
        case "Temperature":
            if let value = Double(inputValue) {
                do {
                    let temperatureEntry = try TemperatureEntry(date: date, value: value, unit: temperatureUnit)
                    print("Temperature Entry: \(temperatureEntry)")
                } catch {
                    alertMessage = "Error: \(error)"
                }
            }
            else{
                alertMessage = "temperaure must be a valid number"
            }
        case "Oxygen Saturation":
            if let percentage = Double(inputValue) {
                do {
                    let oxygenEntry = try OxygenSaturationEntry(date: date, percentage: percentage)
                    print("Oxygen Saturation Entry: \(oxygenEntry)")
                } catch {
                    alertMessage = "Error: \(error)"
                }
            }
            else{
                alertMessage = "percentage must be a valid number"
            }
        case "Blood Pressure":
            if let systolic = Double(systolicValue), let diastolic = Double(diastolicValue) {
                do {
                    let bloodPressureEntry = try BloodPressureEntry(date: date, systolic: systolic, diastolic: diastolic)
                    print("Blood Pressure Entry: \(bloodPressureEntry)")
                } catch {
                    alertMessage = "Error: \(error)"
                }
            }
            else{
                alertMessage = "blood pressure must be a valid number"
            }
        case "Lab Results":
            if let value = Double(inputValue) {
                do {
                    let labEntry = try LabEntry(date: date, testType: labTestType, value: value)
                    print("Lab Entry: \(labEntry)")
                } catch {
                    alertMessage = "Error: \(error)"
                }
            }
            else{
                alertMessage = "input must be a valid number"
            }
        default:
            print("Unknown data type")
        }
        dismiss()
    }
}

struct LabResultsForm: View {
    @Binding var inputValue: String
    @Binding var labTestType: LabTestType
    
    var body: some View {
        Picker("Lab Test Type", selection: $labTestType) {
            ForEach(LabTestType.allCases, id: \.self) { type in
                Text(type.rawValue).tag(type)
            }
        }
        .pickerStyle(.menu)
        
        HStack {
            Text("Value")
            Spacer()
            TextField("", text: $inputValue)
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
    DataInputForm(dataType: "Oxygen Saturation")
//    DataInputForm(dataType: "Blood Pressure")
//    DataInputForm(dataType: "Lab Results")
}
