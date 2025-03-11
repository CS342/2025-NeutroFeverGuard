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
struct SkinTemperatureDecodingTests {
    @Test("Decode valid Celsius temperature")
    func testDecodeValidCelsiusTemperature() {
        // Flags: 0x00 (Celsius, no timestamp)
        let data: [UInt8] = [0x00, 0x42, 0x0E, 0x00, 0xFE]
        let measurement = SkinTemperatureMeasurement(from: Data(data))

        #expect(measurement != nil)
        #expect(measurement?.temperature == 36.50)
        #expect(measurement?.unit == .celsius)
        #expect(measurement?.timestamp == nil)
    }

    @Test("Decode valid Fahrenheit temperature")
    func testDecodeValidFahrenheitTemperature() {
        // Flags: 0x01 (Fahrenheit, no timestamp)
        let data: [UInt8] = [0x01, 0xDA, 0x03, 0x00, 0xFF]
        let measurement = SkinTemperatureMeasurement(from: Data(data))

        #expect(measurement != nil)
        #expect(measurement?.temperature == 98.60)
        #expect(measurement?.unit == .fahrenheit)
        #expect(measurement?.timestamp == nil)
    }

    @Test("Handle sensor off-body NaN value")
    func testDecodeSensorOffBody() {
        // Flags: 0x00 (Celsius, no timestamp), Value: NaN (0x007FFFFF)
        let data: [UInt8] = [0x00, 0xFF, 0xFF, 0x7F, 0x00]
        let measurement = SkinTemperatureMeasurement(from: Data(data))

        #expect(measurement == nil)
    }

    @Test("Decode temperature with timestamp")
    func testDecodeTemperatureWithTimestamp() {
        // Flags: 0x02 (Celsius + Timestamp)
        // Temp: 37.20°C, Timestamp: 2025-03-10 14:30:45
        let data: [UInt8] = [
            0x02,       // Flags
            0x88, 0x0E, 0x00, 0xFE, // Temperature: 37.20°C
            0xE9, 0x07, // Year: 2025
            0x03,       // Month: 3 (March)
            0x0A,       // Day: 10
            0x0E,       // Hour: 14
            0x1E,       // Minute: 30
            0x2D        // Second: 45
        ]
        let measurement = SkinTemperatureMeasurement(from: Data(data))

        #expect(measurement != nil)
        #expect(measurement?.temperature == 37.20)
        #expect(measurement?.unit == .celsius)
        #expect(measurement?.timestamp != nil)
        
        if let timestamp = measurement?.timestamp {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: timestamp)

            #expect(components.year == 2025)
            #expect(components.month == 3)
            #expect(components.day == 10)
            #expect(components.hour == 14)
            #expect(components.minute == 30)
            #expect(components.second == 45)
        } else {
            #expect(true, "Timestamp should not be nil")
        }
    }

    @Test("Handle incomplete data")
    func testDecodeIncompleteData() {
        let incompleteData: [UInt8] = [0x00, 0x42] // Too short
        let measurement = SkinTemperatureMeasurement(from: Data(incompleteData))

        #expect(measurement == nil)
    }

    @Test("Handle corrupted timestamp data")
    func testDecodeInvalidTimestamp() {
        let data: [UInt8] = [
            0x02,       // Flags (Celsius + Timestamp present)
            0x88, 0x2E, 0x00, 0x00, // Temperature: 37.20°C
            0xE9, 0x07, // Year: 2025
            0x03        // Month: 3 (missing Day, Hour, Min, Sec)
        ]
        let measurement = SkinTemperatureMeasurement(from: Data(data))

        #expect(measurement != nil)
        #expect(measurement?.timestamp == nil)
    }
}
