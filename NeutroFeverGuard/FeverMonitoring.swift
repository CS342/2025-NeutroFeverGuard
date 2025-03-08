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
    private let healthStore = HKHealthStore()
    private init() {}

    func checkForFever() async -> Bool {
        guard let bodyTemperatureType = HKQuantityType.quantityType(forIdentifier: .bodyTemperature) else {
            print("HealthKit body temperature data is not available on this device.")
            return false
        }

        let now = Date()
        guard let hourAgo = Calendar.current.date(byAdding: .hour, value: -1, to: now) else {
            return false
        }

        let hourPredicate = HKQuery.predicateForSamples(withStart: hourAgo, end: now)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)

        do {
            let samples = try await queryHealthData(
                store: healthStore,
                sampleType: bodyTemperatureType,
                predicate: hourPredicate,
                sortDescriptors: [sortDescriptor]
            )

            print("Fetched \(samples.count) temperature samples")

            guard let temperatures = samples as? [HKQuantitySample], !temperatures.isEmpty else {
                print("No temperature samples found")
                return false
            }

            for temp in temperatures {
                let tempValue = temp.quantity.doubleValue(for: HKUnit.degreeFahrenheit())
                print("Temperature: \(tempValue)°F at \(temp.startDate)")
            }

            if let latest = temperatures.first {
                let latestTemp = latest.quantity.doubleValue(for: HKUnit.degreeFahrenheit())
                print("Latest temperature: \(latestTemp)°F")
                if latestTemp >= 101.0 {
                    print("Fever detected: Latest temperature is >= 101.0°F")
                    return true
                }
            }

            let allHighTemps = temperatures.allSatisfy { sample in
                let temp = sample.quantity.doubleValue(for: HKUnit.degreeFahrenheit())
                return temp >= 100.4
            }

            if allHighTemps {
                print("Fever detected: All temperatures in the last hour are >= 100.4°F")
            } else {
                print("No fever detected")
            }

            return allHighTemps
        } catch {
            print("Error fetching health data: \(error)")
            return false
        }
    }

    private func queryHealthData(
        store: HKHealthStore,
        sampleType: HKSampleType,
        predicate: NSPredicate?,
        sortDescriptors: [NSSortDescriptor]
    ) async throws -> [HKSample] {
        try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: sampleType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: sortDescriptors
            ) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                continuation.resume(returning: samples ?? [])
            }
            store.execute(query)
        }
    }
}
