//
// This source file is part of the NeutroFeverGuard based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import HealthKit
@testable import NeutroFeverGuard
import Testing

// Mock HealthKitService for testing
final class MockHealthKitService: HealthDataFetchable, @unchecked Sendable {
    var mockTemperatures: [HKQuantitySample] = []
    var throwError: Bool = false

    func queryTemperatureData() async throws -> [HKQuantitySample] {
        if throwError {
            throw NSError(domain: "HealthKitError", code: 1, userInfo: nil)
        }
        return mockTemperatures
    }
}

@MainActor
struct FeverMonitorTests {
    @Test("Test when no temperature data is available")
    func testNoData() async {
        let mockService = MockHealthKitService()
        let feverMonitor = FeverMonitor(healthDataFetcher: mockService)

        mockService.mockTemperatures = []
        let result = await feverMonitor.checkForFever()

        #expect(result == false)
    }
    
    @Test("Test normal temperatures")
    func testNormalTemperature() async {
        let mockService = MockHealthKitService()
        let feverMonitor = FeverMonitor(healthDataFetcher: mockService)

        mockService.mockTemperatures = [
            createTemperatureSample(temperature: 98.6),
            createTemperatureSample(temperature: 99.0),
            createTemperatureSample(temperature: 98.7)
        ]

        let result = await feverMonitor.checkForFever()
        #expect(result == false)
    }
    
    @Test("Test single high fever reading")
    func testSingleHighTemperature() async {
        let mockService = MockHealthKitService()
        let feverMonitor = FeverMonitor(healthDataFetcher: mockService)

        mockService.mockTemperatures = [
            createTemperatureSample(temperature: 101.5)
        ]

        let result = await feverMonitor.checkForFever()
        #expect(result == true)
    }
    
    @Test("Test multiple temperatures all above 100.4°F")
    func testAllTemperaturesAbove100_4() async {
        let mockService = MockHealthKitService()
        let feverMonitor = FeverMonitor(healthDataFetcher: mockService)

        mockService.mockTemperatures = [
            createTemperatureSample(temperature: 100.5),
            createTemperatureSample(temperature: 100.6),
            createTemperatureSample(temperature: 100.8)
        ]

        let result = await feverMonitor.checkForFever()
        #expect(result == true)
    }
    
    @Test("Test mixed temperatures where fever should not be detected")
    func testMixedTemperatures() async {
        let mockService = MockHealthKitService()
        let feverMonitor = FeverMonitor(healthDataFetcher: mockService)

        mockService.mockTemperatures = [
            createTemperatureSample(temperature: 98.5),
            createTemperatureSample(temperature: 100.5),
            createTemperatureSample(temperature: 99.2)
        ]

        let result = await feverMonitor.checkForFever()
        #expect(result == false)
    }
    
    @Test("Test latest temperature exactly at fever threshold (101.0°F)")
    func testLatestTemperatureExactly101() async {
        let mockService = MockHealthKitService()
        let feverMonitor = FeverMonitor(healthDataFetcher: mockService)

        mockService.mockTemperatures = [
            createTemperatureSample(temperature: 101.0),
            createTemperatureSample(temperature: 100.1),
            createTemperatureSample(temperature: 99.8)
        ]

        let result = await feverMonitor.checkForFever()
        #expect(result == true)
    }
    
    @Test("Test max temperature below fever threshold (100.9°F)")
    func testMaxTemperatureBelowThreshold() async {
        let mockService = MockHealthKitService()
        let feverMonitor = FeverMonitor(healthDataFetcher: mockService)

        mockService.mockTemperatures = [
            createTemperatureSample(temperature: 99.5),
            createTemperatureSample(temperature: 100.9),
            createTemperatureSample(temperature: 100.3)
        ]

        let result = await feverMonitor.checkForFever()
        #expect(result == false)
    }
    
    @Test("Test alternating high and normal temperatures")
    func testAlternatingTemperatures() async {
        let mockService = MockHealthKitService()
        let feverMonitor = FeverMonitor(healthDataFetcher: mockService)

        mockService.mockTemperatures = [
            createTemperatureSample(temperature: 101.5),
            createTemperatureSample(temperature: 98.6),
            createTemperatureSample(temperature: 102.0),
            createTemperatureSample(temperature: 99.1)
        ]

        let result = await feverMonitor.checkForFever()
        #expect(result == true)
    }
    
    @Test("Test temperature conversion from Celsius to Fahrenheit")
    func testTemperatureConversionCelsiusToFahrenheit() async {
        let mockService = MockHealthKitService()
        let feverMonitor = FeverMonitor(healthDataFetcher: mockService)

        mockService.mockTemperatures = [
            createTemperatureSample(temperature: 38.5, unit: .degreeCelsius()),  // 101.3°F
            createTemperatureSample(temperature: 100.2, unit: .degreeFahrenheit())
        ]

        let result = await feverMonitor.checkForFever()
        #expect(result == true)
    }
    
    func createTemperatureSample(temperature: Double, unit: HKUnit = .degreeFahrenheit(), date: Date = Date()) -> HKQuantitySample {
        guard let bodyTemperatureType = HKQuantityType.quantityType(forIdentifier: .bodyTemperature) else {
            fatalError("Failed to get body temperature type from HealthKit")
        }

        let quantity = HKQuantity(unit: unit, doubleValue: temperature)
        return HKQuantitySample(
            type: bodyTemperatureType,
            quantity: quantity,
            start: date,
            end: date
        )
    }
}
