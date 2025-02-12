//
// This source file is part of the NeutroFeverGuard based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

@testable import NeutroFeverGuard
import HealthKit
import XCTest


class NeutroFeverGuardTests: XCTestCase {
    @MainActor
    func testContactsCount() throws {
        XCTAssertEqual(Contacts(presentingAccount: .constant(true)).contacts.count, 1)
    }
}

class HKVisualizationTests: XCTestCase {
    @MainActor
    func testHKDataInitialization() throws {
        // Test HKData struct initialization
        let testDate = Date()
        let hkData = HKData(
            date: testDate,
            sumValue: 100.0,
            avgValue: 50.0,
            minValue: 10.0,
            maxValue: 90.0
        )
        
        XCTAssertEqual(hkData.date, testDate)
        XCTAssertEqual(hkData.sumValue, 100.0)
        XCTAssertEqual(hkData.avgValue, 50.0)
        XCTAssertEqual(hkData.minValue, 10.0)
        XCTAssertEqual(hkData.maxValue, 90.0)
    }
    
    @MainActor
    func testParseValue() throws {
        // Test parsing different HealthKit quantity types
        let healthStore = HKHealthStore()
        
        // Heart Rate parsing
        let heartRateQuantity = HKQuantity(unit: HKUnit(from: "count/min"), doubleValue: 70)
        let heartRateValue = parseValue(quantity: heartRateQuantity, quantityTypeIDF: .heartRate)
        XCTAssertEqual(heartRateValue, 70.0)
        
        // Oxygen Saturation parsing
        let oxygenSatQuantity = HKQuantity(unit: .percent(), doubleValue: 0.95)
        let oxygenSatValue = parseValue(quantity: oxygenSatQuantity, quantityTypeIDF: .oxygenSaturation)
        XCTAssertEqual(oxygenSatValue, 95.0)
    }
}
