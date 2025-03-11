//
// This source file is part of the NeutroFeverGuard based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
import HealthKit
import Spezi
import SpeziBluetooth

class Measurements: Module, EnvironmentAccessible, DefaultInitializable {
    @Dependency(HealthKitService.self) private var healthKitService
    private var recordedTemperatures: [SkinTemperatureMeasurement] = []
    
    required init() {}
    
    @MainActor
    func recordNewMeasurement(_ measurement: SkinTemperatureMeasurement) async {
        let timestamp = measurement.timestamp ?? Date() // if we dont get timestamp from the sensor, then we need to generate.

        recordedTemperatures.append(measurement)
        print("New Temperature Recorded: \(measurement.temperature) \(measurement.unit == .celsius ? "°C" : "°F") at \(timestamp)")
        
        do {
            // Request HealthKit authorization (Temporarily placed to make sure data is pushed on iphone, remove while pushing to main)
            // try await healthKitService.requestAuthorization()
            
            // Convert measurement into HealthKit-compatible TemperatureEntry
            let temperatureEntry = try TemperatureEntry(
                date: timestamp,
                value: Double(measurement.temperature),
                unit: measurement.unit == .celsius ? .celsius : .fahrenheit
            )
            
            // Save to HealthKit
            try await healthKitService.saveTemperature(temperatureEntry)
            print("Core Sensor Skin Temperature successfully saved to HealthKit.")
        } catch let error as DataError {
            print("HealthKit save error: \(error.errorMessage)")
        } catch {
            print("Unexpected error saving to HealthKit: \(error)")
        }
    }
}
