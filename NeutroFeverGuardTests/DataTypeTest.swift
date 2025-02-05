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
        let invalidDate = Date().addingTimeInterval(60 * 60 * 24) // 未来的日期
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
        let invalidDate = Date().addingTimeInterval(60 * 60 * 24) // 未来的日期
        let testType = LabTestType.whiteBloodCell
        let value = 5.0
        
        try LabEntry(date: validDate, testType: testType, value: value)
        
        #expect(throws: DataError.invalidDate) {
            try LabEntry(date: invalidDate, testType: testType, value: value)
        }
    }
}
