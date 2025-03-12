//
// This source file is part of the NeutroFeverGuard based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
import HealthKit

/*
 Helper Function: check the date is not in future
 */
func isValidDate(_ date: Date) throws {
    guard date <= Date() else {
        throw DataError.invalidDate
    }
}

enum LabTestType: String, CaseIterable, Codable {
    case whiteBloodCell = "White Blood Cell Count"
    case hemoglobin = "Hemoglobin"
    case plateletCount = "Platelet Count"
    case neutrophils = "% Neutrophils"
    case lymphocytes = "% Lymphocytes"
    case monocytes = "% Monocytes"
    case eosinophils = "% Eosinophils"
    case basophils = "% Basophils"
    case blasts = "% Blasts"
}


enum TemperatureUnit: String {
   case celsius = "Celsius"
   case fahrenheit = "Fahrenheit"
   
   var hkUnit: HKUnit {
       switch self {
       case .celsius:
           return HKUnit.degreeCelsius()
       case .fahrenheit:
           return HKUnit.degreeFahrenheit()
       }
   }
}

/*
 Heart Rate: date + time measured, and rate in BPM
 */

struct HeartRateEntry {
    static let healthKitType = HKQuantityType(.heartRate)
    static let unit = HKUnit.count().unitDivided(by: HKUnit.minute())
    
    let date: Date
    let bpm: Double
    
    init(date: Date, bpm: Double) throws {
        try isValidDate(date)
        self.date = date
        self.bpm = bpm
    }
}


/*
 Temperature: date + time measured, and temperature in either degrees celsius or
 */
struct TemperatureEntry {
    static let healthKitType = HKQuantityType(.bodyTemperature)
    
    let date: Date
    let value: Double
    let unit: TemperatureUnit
    
    init(date: Date, value: Double, unit: TemperatureUnit) throws {
        try isValidDate(date)
        self.date = date
        self.value = value
        self.unit = unit
    }
}


/*
 Oxygen saturation: date + time measured, and oxygen saturation in %.
 */
struct OxygenSaturationEntry {
    static let healthKitType = HKQuantityType(.oxygenSaturation)
    static let unit = HKUnit.percent()
    
    let date: Date
    let percentage: Double
    
    init(date: Date, percentage: Double) throws {
        try isValidDate(date)
        guard percentage >= 0 && percentage <= 100 else {
            throw DataError.invalidPercentage
        }
        self.date = date
        self.percentage = percentage
    }
}

/*
 Blood Pressure: date + time measured, and two pressures (systolic and diastolic) in mmHg.
 */
// swiftlint:disable:next file_types_order
struct BloodPressureEntry {
    static let systolicType = HKQuantityType(.bloodPressureSystolic)
    static let diastolicType = HKQuantityType(.bloodPressureDiastolic)
    static let unit = HKUnit.millimeterOfMercury()
    
    let date: Date
    let systolic: Double
    let diastolic: Double
    
    init(date: Date, systolic: Double, diastolic: Double) throws {
        try isValidDate(date)
        guard systolic >= 0, diastolic >= 0 else {
            throw DataError.invalidBloodPressure
        }
        self.date = date
        self.systolic = systolic
        self.diastolic = diastolic
    }
}
  
  /*
 Lab values:
 - Date and time of lab measured
 - Name of lab: white blood cell count, hemoglobin, platelet count, %neutrophils, %lymphocytes, %monocytes, %eosinophils, %basophils, %blasts
 - Lab values: include the number associated with the lab name above
 */

struct LabEntry: Codable {
    var date: Date
    var values: [LabTestType: Double]
    
    init(date: Date, values: [LabTestType: Double]) throws {
        try isValidDate(date)
        self.date = date
        self.values = values
    }
}

/*
 Medication administrations for chemotherapy:
 - Start date and time of administration
 - Optional end date and time of administration
 - Medication name
 - Medication dose
 */

enum DoseUnit: String, CaseIterable, Codable {
    case mgUnit = "mg"
    case mcgUnit = "mcg"
    case gUnit = "g"
    case mLUnit = "mL"
    case percentUnit = "%"
}

struct MedicationEntry: Codable {
    var date: Date
    var name: String
    var doseValue: Double
    var doseUnit: DoseUnit

    init(date: Date, name: String, doseValue: Double, doseUnit: DoseUnit) throws {
        try isValidDate(date)
        self.date = date
        self.name = name
        self.doseValue = doseValue
        self.doseUnit = doseUnit
    }
}

enum Symptom: String, CaseIterable, Codable {
    case nausea = "Nausea"
    case vomiting = "Vomiting"
    case diarrhea = "Diarrhea"
    case chills = "Chills"
    case cough = "Cough"
    case pain = "Pain"
}

struct SymptomEntry: Codable {
    // periphery:ignore
    var date: Date
    // periphery:ignore
    var symptoms: [Symptom: Int]  // Maps symptoms to their severity (1-10)
    
    init(date: Date, symptoms: [Symptom: Int]) throws {
        try isValidDate(date)
        // Validate that all severity ratings are between 1 and 10
        for (_, severity) in symptoms {
            guard severity >= 1 && severity <= 10 else {
                throw DataError.invalidSeverity
            }
        }
        self.date = date
        self.symptoms = symptoms
    }
}

struct MasccEntry: Codable {
    // periphery:ignore
    var date: Date
    // periphery:ignore
    var symptoms: [Symptom: Int]  // Maps symptoms to their severity (1-10)
    
    init(date: Date, symptoms: [Symptom: Int]) throws {
        try isValidDate(date)
        // Validate that all severity ratings are between 1 and 10
        for (_, severity) in symptoms {
            guard severity >= 1 && severity <= 10 else {
                throw DataError.invalidSeverity
            }
        }
        self.date = date
        self.symptoms = symptoms
    }
}
