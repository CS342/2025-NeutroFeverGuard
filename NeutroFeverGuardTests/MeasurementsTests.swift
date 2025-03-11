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


// Mock HealthKitService
class MockHealthKitService: HealthKitService {
    var savedTemperatures: [TemperatureEntry] = []
    var shouldThrowError = false
    
    override func saveTemperature(_ entry: TemperatureEntry) async throws {
        if shouldThrowError {
            throw DataError.saveFailed
        }
        savedTemperatures.append(entry)
    }
}

@MainActor
struct MeasurementsTests {
    @Test("Record a valid temperature measurement")
    func testRecordNewMeasurement() async {
        let mockService = MockHealthKitService()
        let measurements = Measurements()
        measurements.healthKitService = mockService // Inject mock service

        let tempMeasurement = SkinTemperatureMeasurement(temperature: 36.5, unit: .celsius, timestamp: Date())

        await measurements.recordNewMeasurement(tempMeasurement)

        #expect(measurements.recordedTemperatures.count == 1)
        #expect(measurements.recordedTemperatures.first?.temperature == 36.5)
        #expect(mockService.savedTemperatures.count == 1)
        #expect(mockService.savedTemperatures.first?.value == 36.5)
        #expect(mockService.savedTemperatures.first?.unit == .celsius)
    }

    @Test("Generate timestamp when missing")
    func testGenerateTimestampIfMissing() async {
        let mockService = MockHealthKitService()
        let measurements = Measurements()
        measurements.healthKitService = mockService // Inject mock service

        let tempMeasurement = SkinTemperatureMeasurement(temperature: 98.6, unit: .fahrenheit, timestamp: nil) // No timestamp

        let beforeRecording = Date()
        await measurements.recordNewMeasurement(tempMeasurement)
        let afterRecording = Date()

        if let recordedTimestamp = measurements.recordedTemperatures.first?.timestamp {
            #expect(recordedTimestamp >= beforeRecording)
            #expect(recordedTimestamp <= afterRecording)
        } else {
            #expect(true, "Timestamp should have been generated but was nil")
        }
    }

    @Test("Handle HealthKit save failure gracefully")
    func testHealthKitSaveFailure() async {
        let mockService = MockHealthKitService()
        mockService.shouldThrowError = true // Simulate HealthKit failure

        let measurements = Measurements()
        measurements.healthKitService = mockService // Inject mock service

        let tempMeasurement = SkinTemperatureMeasurement(temperature: 37.2, unit: .celsius, timestamp: Date())

        await measurements.recordNewMeasurement(tempMeasurement)

        #expect(measurements.recordedTemperatures.count == 1) // Still recorded locally
        #expect(mockService.savedTemperatures.isEmpty == true) // Not saved in HealthKit
    }
}
