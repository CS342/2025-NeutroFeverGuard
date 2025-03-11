//
// This source file is part of the NeutroFeverGuard based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
import Spezi
import SpeziBluetooth

struct SkinTemperatureMeasurement {
    let temperature: Float
    let unit: UnitTemperature
    let timestamp: Date? // Optional, because it may not always be present

    init?(from data: Data) {
        guard data.count >= 5 else {
            print("Received data is too short for temperature decoding.")
            return nil
        }

        let flags = data[0] // First byte is the flag
        let isFahrenheit = (flags & 0x01) != 0 // Check if temperature is in Fahrenheit
        let hasTimestamp = (flags & 0x02) != 0 // Check if timestamp is present

        var offset = 1 // Start reading after the flag byte

        // Extract 32-bit IEEE 11073 float (Temperature Value)
        let rawTempValue = data.subdata(in: offset..<offset + 4).withUnsafeBytes { rawPointer in
            rawPointer.loadUnaligned(as: UInt32.self)
        }
        offset += 4

        // Decode IEEE 11073 float format (8-bit exponent, 24-bit mantissa)
        let exponent = Int8(bitPattern: UInt8((rawTempValue >> 24) & 0xFF)) // 8-bit signed exponent
        let mantissa = Int32(rawTempValue & 0x007FFFFF) // 24-bit mantissa

        // Handle IEEE-11073 special NaN case (off-body state)
        if mantissa == 0x007FFFFF {
            print("Sensor is not on the skin. No valid temperature data.")
            return nil
        }

        // Compute the actual temperature value: `mantissa * 10^exponent`
        let temperature = Float(mantissa) * pow(10, Float(exponent))

        // Extract timestamp if present
        var timestamp: Date?
        if hasTimestamp && data.count >= offset + 7 {
            let year = Int(data[offset]) | (Int(data[offset + 1]) << 8) // Little-endian Year
            let month = Int(data[offset + 2])
            let day = Int(data[offset + 3])
            let hour = Int(data[offset + 4])
            let minute = Int(data[offset + 5])
            let second = Int(data[offset + 6])
            offset += 7

            // Create a timestamp Date object
            var dateComponents = DateComponents()
            dateComponents.year = year
            dateComponents.month = month
            dateComponents.day = day
            dateComponents.hour = hour
            dateComponents.minute = minute
            dateComponents.second = second

            if let date = Calendar.current.date(from: dateComponents) {
                timestamp = date
            } else {
                print("Failed to parse timestamp.")
            }
        }

        self.temperature = temperature
        self.unit = isFahrenheit ? .fahrenheit : .celsius
        self.timestamp = timestamp
    }
}
