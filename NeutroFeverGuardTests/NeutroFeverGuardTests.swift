//
// This source file is part of the NeutroFeverGuard based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
import HealthKit
import Testing
@testable import NeutroFeverGuard

struct NeutroFeverGuardTests {
    @Test("HK Data Initialization Test")
    func testHKDataInitialization() {
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
    
    @Test("Test Parse Value")
    func testParseValue() {
        let healthStore = HKHealthStore()
        
        // Heart Rate parsing
        let heartRateQuantity = HKQuantity(unit: HKUnit(from: "count/min"), doubleValue: 70)
        let heartRateValue = parseValue(quantity: heartRateQuantity, quantityTypeIDF: .heartRate)
        #expect(heartRateValue == 70.0, "Heart rate value should be 70.0")
        
        // Oxygen Saturation parsing
        let oxygenSatQuantity = HKQuantity(unit: .percent(), doubleValue: 0.95)
        let oxygenSatValue = parseValue(quantity: oxygenSatQuantity, quantityTypeIDF: .oxygenSaturation)
        #expect(oxygenSatValue == 95.0, "Oxygen saturation value should be 95.0")
    }
    @MainActor
    @Test("Test HK Visualization Display")
    func testHKVisualizationDisplay() {
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
    func testHKVisualizationItemThreshold() {
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
