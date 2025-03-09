//
// This source file is part of the NeutroFeverGuard based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
import HealthKit

actor FeverMonitor: Sendable {
    static let shared = FeverMonitor()
    // private let healthStore = HKHealthStore()
    // private init() {}
    
    private let healthDataFetcher: HealthDataFetchable

    init(healthDataFetcher: HealthDataFetchable = HealthKitService()) {
        self.healthDataFetcher = healthDataFetcher
    }

    func checkForFever() async -> Bool {
        do {
            let temperatures = try await healthDataFetcher.queryTemperatureData()

            print("Fetched \(temperatures.count) temperature samples")

            guard !temperatures.isEmpty else {
                print("No temperature samples found")
                return false
            }

            for temp in temperatures {
                let tempFahrenheit = convertToFahrenheit(temp.quantity)
                print("Temperature: \(tempFahrenheit)°F at \(temp.startDate)")
            }

            if let latest = temperatures.first {
                let latestTempFahrenheit = convertToFahrenheit(latest.quantity)
                print("Latest temperature: \(latestTempFahrenheit)°F")
                if latestTempFahrenheit >= 101.0 {
                    print("Fever detected: Latest temperature is >= 101.0°F")
                    return true
                }
            }

            let allHighTemps = temperatures.allSatisfy { sample in
                let tempFahrenheit = convertToFahrenheit(sample.quantity)
                return tempFahrenheit >= 100.4
            }

            if allHighTemps {
                print("Fever detected: All temperatures in the last hour are >= 100.4°F")
                return true
            } else {
                print("No fever detected")
                return false
            }
        } catch {
            print("Error fetching health data: \(error)")
            return false
        }
    }

    private func convertToFahrenheit(_ quantity: HKQuantity) -> Double {
        if quantity.is(compatibleWith: HKUnit.degreeFahrenheit()) {
            return quantity.doubleValue(for: HKUnit.degreeFahrenheit())
        } else if quantity.is(compatibleWith: HKUnit.degreeCelsius()) {
            return celsiusToFahrenheit(quantity.doubleValue(for: HKUnit.degreeCelsius()))
        } else {
            print("Unknown temperature unit!")
            return 0.0  // Fallback in case of an unknown unit
        }
    }

    private func celsiusToFahrenheit(_ tempCelsius: Double) -> Double {
        (tempCelsius * 9 / 5) + 32
    }
}
