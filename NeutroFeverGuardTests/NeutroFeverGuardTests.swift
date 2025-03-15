//
// This source file is part of the NeutroFeverGuard based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
import HealthKit
@testable import NeutroFeverGuard
import Testing

@MainActor
struct NeutroFeverGuardTests {
    @MainActor
    @Test("HK Data Initialization Test")
    func testHKDataInitialization() async throws {
        let testDate = Date()
        let hkData = HKData(
            date: testDate,
            sumValue: 100.0,
            avgValue: 50.0,
            minValue: 10.0,
            maxValue: 90.0
        )
        
        #expect(hkData.date == testDate, "Date should match test date")
        #expect(hkData.sumValue == 100.0, "Sum value should be 100.0")
        #expect(hkData.avgValue == 50.0, "Average value should be 50.0")
        #expect(hkData.minValue == 10.0, "Minimum value should be 10.0")
        #expect(hkData.maxValue == 90.0, "Maximum value should be 90.0")
    }
    
    @MainActor
    @Test("Test Parse Value")
    func testParseValue() async throws {
        let healthStore = HKHealthStore()
        
        // Heart Rate parsing
        let heartRateQuantity = HKQuantity(unit: HKUnit(from: "count/min"), doubleValue: 70)
        let heartRateValue = parseValue(quantity: heartRateQuantity, quantityTypeIDF: .heartRate)
        #expect(heartRateValue == 70.0, "Heart rate value should be 70.0")
        
        // Oxygen Saturation parsing
        let oxygenSatQuantity = HKQuantity(unit: .percent(), doubleValue: 0.95)
        let oxygenSatValue = parseValue(quantity: oxygenSatQuantity, quantityTypeIDF: .oxygenSaturation)
        #expect(oxygenSatValue == 95.0, "Oxygen saturation value should be 95.0")
        
        // body temperature parsing
        let temperQuantity = HKQuantity(unit: .degreeCelsius(), doubleValue: 37)
        let temperSatValue = parseValue(quantity: temperQuantity, quantityTypeIDF: .bodyTemperature)
        #expect(temperSatValue == 37.0, "Body temperature value should be 37.0")
        
        // default
        let defaultQuantity = HKQuantity(unit: .degreeFahrenheit(), doubleValue: 99)
        let defaultSatValue = parseValue(quantity: defaultQuantity, quantityTypeIDF: .bodyMass)
        #expect(defaultSatValue == -1.0, "Default value should be -1.0")
    }
    
    @MainActor
    @Test
    func testparseSampleQueryData() async throws {
        let sampleDate = Date()
        let sampleQuantity = HKQuantity(unit: .percent(), doubleValue: 0.95)
        let sample = HKQuantitySample(type: HKQuantityType(.oxygenSaturation), quantity: sampleQuantity, start: sampleDate, end: sampleDate)
        
        let results = parseSampleQueryData(results: [sample], quantityTypeIDF: .oxygenSaturation)
        
        #expect(results.count == 1)
        #expect(results.first?.sumValue == 95.0)
    }
    
    @MainActor
    @Test
    func testGenerateDateRange() async throws {
        let range = generateDateRange()
        
        #expect(range.count == 3)
        #expect(range[0] is Date)
        #expect(range[1] is Date)
        #expect(range[2] is NSPredicate)
    }
        
    @MainActor
    @Test
    func testHandleAuthorizationError() async throws {
        let error = HKError(.errorAuthorizationDenied)
        let message = handleAuthorizationError(error)
        
        #expect(message == "Authorization denied by the user.")
        
        let error2 = HKError(.errorHealthDataUnavailable)
        let message2 = handleAuthorizationError(error2)
        #expect(message2 == "Health data is unavailable on this device.")
        
        let error3 = HKError(.errorInvalidArgument)
        let message3 = handleAuthorizationError(error3)
        #expect(message3 == "Invalid argument provided for HealthKit authorization.")
        
        let unknownError = NSError(domain: "TestError", code: 999, userInfo: nil)
        let unknownMessage = handleAuthorizationError(unknownError)
        
        #expect(unknownMessage == "Unknown error during HealthKit authorization: The operation couldn’t be completed. (TestError error 999.)")
    }
    
    @MainActor
    @Test("Test HK Visualization Display")
    func testHKVisualizationDisplay() async throws {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()

        let mockData = [
            HKData(date: Date(), sumValue: 100, avgValue: 96, minValue: 90, maxValue: 105),
            HKData(date: yesterday, sumValue: 0, avgValue: 96, minValue: 91, maxValue: 102)
        ]
        let view = HKVisualizationItem(
            data: mockData,
            xName: "Date",
            yName: "Oxygen Saturation (%)",
            title: "Blood Oxygen Saturation",
            threshold: 94.0,
            helperText: "Maintain oxygen saturation above 94%."
        )
        
        #expect(view != nil, "View should be initialized successfully")
    }
    
    @MainActor
    @Test("Test HK Visualization Thereshold")
    func testHKVisualizationItemThreshold() async throws {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
        let mockData = [
            HKData(date: Date(), sumValue: 100, avgValue: 96, minValue: 90, maxValue: 105),
            HKData(date: yesterday, sumValue: 0, avgValue: 96, minValue: 91, maxValue: 102)
        ]
        let view = HKVisualizationItem(
            data: mockData,
            xName: "Date",
            yName: "Body Temperature (°C)",
            title: "Body Temperature",
            threshold: 37.5,
            helperText: "Monitor your body temperature for fever signs."
        )
        
        #expect(view != nil, "View should be initialized successfully")
    }
}
