//
// This source file is part of the NeutroFeverGuard based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Spezi
import SpeziBluetooth

class Measurements: Module, EnvironmentAccessible, DefaultInitializable {
    private var recordedTemperatures: [SkinTemperatureMeasurement] = []
    
    required init() {}

    func recordNewMeasurement(_ measurement: SkinTemperatureMeasurement) {
        recordedTemperatures.append(measurement)
        print("New Temperature: \(String(describing: measurement.temperature)) \(measurement.unit == .celsius ? "°C" : "°F")")
        
        // If integrating with HealthKit, push data here
    }
}
