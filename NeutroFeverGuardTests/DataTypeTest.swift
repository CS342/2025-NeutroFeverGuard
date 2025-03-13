//
// This source file is part of the NeutroFeverGuard based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
@testable import NeutroFeverGuard
import Testing

@MainActor
struct DataTypeTest {
    @Test
    func testHeartRateEntry() async throws {
        let validDate = Date()
        let invalidDate = Date().addingTimeInterval(60 * 60 * 24)
        let bpm = 70.0
        
        try HeartRateEntry(date: validDate, bpm: bpm)
        
        #expect(throws: DataError.invalidDate) {
            try HeartRateEntry(date: invalidDate, bpm: bpm)
        }
    }

    @Test
    func testTemperatureEntry() async throws {
        let validDate = Date()
        let invalidDate = Date().addingTimeInterval(60 * 60 * 24)
        let value = 37.0
        let unit = TemperatureUnit.celsius
        
        try TemperatureEntry(date: validDate, value: value, unit: unit)
        
        #expect(throws: DataError.invalidDate) {
            try TemperatureEntry(date: invalidDate, value: value, unit: unit)
        }
    }

    @Test
    func testOxygenSaturationEntry() async throws {
        let validDate = Date()
        let invalidDate = Date().addingTimeInterval(60 * 60 * 24)
        let validPercentage = 95.0
        let invalidPercentage = 105.0
        
        try OxygenSaturationEntry(date: validDate, percentage: validPercentage)
        
        #expect(throws: DataError.invalidDate) {
            try OxygenSaturationEntry(date: invalidDate, percentage: validPercentage)
        }
        
        #expect(throws: DataError.invalidPercentage) {
            try OxygenSaturationEntry(date: validDate, percentage: invalidPercentage)
        }
    }

    @Test
    func testBloodPressureEntry() async throws {
        let validDate = Date()
        let invalidDate = Date().addingTimeInterval(60 * 60 * 24)
        let validSystolic = 120.0
        let validDiastolic = 80.0
        let invalidSystolic = -10.0
        let invalidDiastolic = -5.0
        
        try BloodPressureEntry(date: validDate, systolic: validSystolic, diastolic: validDiastolic)
        
        #expect(throws: DataError.invalidDate) {
            try BloodPressureEntry(date: invalidDate, systolic: validSystolic, diastolic: validDiastolic)
        }
        
        #expect(throws: DataError.invalidBloodPressure) {
            try BloodPressureEntry(date: validDate, systolic: invalidSystolic, diastolic: validDiastolic)
        }
        
        #expect(throws: DataError.invalidBloodPressure) {
            try BloodPressureEntry(date: validDate, systolic: validSystolic, diastolic: invalidDiastolic)
        }
    }

    @Test
    func testLabEntry() async throws {
        let validDate = Date()
        let invalidDate = Date().addingTimeInterval(60 * 60 * 24)
        let values: [LabTestType: Double] = Dictionary(uniqueKeysWithValues: LabTestType.allCases.map { ($0, Double.random(in: 1.0...10.0)) })
        
        try LabEntry(date: validDate, values: values)
        
        #expect(throws: DataError.invalidDate) {
            try LabEntry(date: invalidDate, values: values)
        }
    }

    @Test
    func testSymptomEntry() async throws {
        let validDate = Date()
        let invalidDate = Date().addingTimeInterval(60 * 60 * 24)
        
        let validSymptoms: [Symptom: Int] = [
            .nausea: 5,
            .pain: 3,
            .cough: 7
        ]
        
        let invalidSymptoms: [Symptom: Int] = [
            .nausea: 11,
            .pain: 0,
            .cough: 5
        ]
        
        try SymptomEntry(date: validDate, symptoms: validSymptoms)
        
        #expect(throws: DataError.invalidDate) {
            try SymptomEntry(date: invalidDate, symptoms: validSymptoms)
        }
        
        #expect(throws: DataError.invalidSeverity) {
            try SymptomEntry(date: validDate, symptoms: invalidSymptoms)
        }
    }
    
    @Test
    func testMasccEntry() async throws {
        let validDate = Date()
        let invalidDate = Date().addingTimeInterval(60 * 60 * 24)
        
        let validSymptoms: [MasccSymptom] = [
            .mildSymptoms,
            .noHypotension,
            .noCOPD,
            .ageUnder60
        ]
        
        try MasccEntry(date: validDate, symptoms: validSymptoms)
        
        #expect(throws: DataError.invalidDate) {
            try MasccEntry(date: invalidDate, symptoms: validSymptoms)
        }
    }
    
    @Test
    func testDataTypesArray() {
        let view = AddDataView(presentingAccount: .constant(false))
        #expect(view.dataTypes.count == 8)
        
        let expectedNames = [
            "Temperature",
            "Heart Rate",
            "Oxygen Saturation",
            "Blood Pressure",
            "Lab Results",
            "Medication",
            "Symptoms",
            "MASCC Index"
        ]
        let actualNames = view.dataTypes.map { $0.name }

        #expect(expectedNames == actualNames)
    }
}
