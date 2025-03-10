//
// This source file is part of the NeutroFeverGuard based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import FirebaseFirestore
import HealthKit
import Spezi
import SpeziHealthKit
import SpeziLocalStorage

actor HealthKitService: Module, EnvironmentAccessible, HealthDataFetchable {
    internal let healthStore = HKHealthStore()
    
    @MainActor
    func configure() { }
    
    func requestAuthorization() async throws {
        let typesToWrite: Set<HKSampleType> = [
            HeartRateEntry.healthKitType,
            TemperatureEntry.healthKitType,
            OxygenSaturationEntry.healthKitType,
            BloodPressureEntry.systolicType,
            BloodPressureEntry.diastolicType
        ]
        
        try await healthStore.requestAuthorization(toShare: typesToWrite, read: typesToWrite)
    }
    
    func saveHeartRate(_ entry: HeartRateEntry) async throws {
        let type = HeartRateEntry.healthKitType
        let quantity = HKQuantity(unit: HeartRateEntry.unit, doubleValue: entry.bpm)
        let metadata: [String: Any] = [
            HKMetadataKeyWasUserEntered: true
        ]
        
        let sample = HKQuantitySample(
            type: type,
            quantity: quantity,
            start: entry.date,
            end: entry.date,
            metadata: metadata
        )
        
        try await healthStore.save(sample)
    }
    
    func saveTemperature(_ entry: TemperatureEntry) async throws {
        let type = TemperatureEntry.healthKitType
        let quantity = HKQuantity(unit: entry.unit.hkUnit, doubleValue: entry.value)
        let metadata: [String: Any] = [
            HKMetadataKeyWasUserEntered: true
        ]
        
        let sample = HKQuantitySample(
            type: type,
            quantity: quantity,
            start: entry.date,
            end: entry.date,
            metadata: metadata
        )
        
        try await healthStore.save(sample)
    }
    
    func saveOxygenSaturation(_ entry: OxygenSaturationEntry) async throws {
        let type = OxygenSaturationEntry.healthKitType
        let quantity = HKQuantity(unit: OxygenSaturationEntry.unit, doubleValue: entry.percentage / 100.0)
        let metadata: [String: Any] = [
            HKMetadataKeyWasUserEntered: true
        ]
        
        let sample = HKQuantitySample(
            type: type,
            quantity: quantity,
            start: entry.date,
            end: entry.date,
            metadata: metadata
        )
        
        try await healthStore.save(sample)
    }
    
    func saveBloodPressure(_ entry: BloodPressureEntry) async throws {
        let systolicQuantity = HKQuantity(unit: BloodPressureEntry.unit, doubleValue: entry.systolic)
        let diastolicQuantity = HKQuantity(unit: BloodPressureEntry.unit, doubleValue: entry.diastolic)
        
        let metadata: [String: Any] = [
            HKMetadataKeyWasUserEntered: true
        ]
        
        let systolicSample = HKQuantitySample(
            type: BloodPressureEntry.systolicType,
            quantity: systolicQuantity,
            start: entry.date,
            end: entry.date,
            metadata: metadata
        )
        
        let diastolicSample = HKQuantitySample(
            type: BloodPressureEntry.diastolicType,
            quantity: diastolicQuantity,
            start: entry.date,
            end: entry.date,
            metadata: metadata
        )
        
        let bloodPressureType = HKCorrelationType(.bloodPressure)
        let correlation = HKCorrelation(
            type: bloodPressureType,
            start: entry.date,
            end: entry.date,
            objects: Set([systolicSample, diastolicSample])
        )
        
        try await healthStore.save(correlation)
    }
    
    func queryTemperatureData() async throws -> [HKQuantitySample] {
        guard let bodyTemperatureType = HKQuantityType.quantityType(forIdentifier: .bodyTemperature) else {
            print("HealthKit body temperature data is not available on this device.")
            return []
        }

        let now = Date()
        guard let hourAgo = Calendar.current.date(byAdding: .hour, value: -1, to: now) else {
            return []
        }

        let predicate = HKQuery.predicateForSamples(withStart: hourAgo, end: now)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: bodyTemperatureType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [sortDescriptor]
            ) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                continuation.resume(returning: samples as? [HKQuantitySample] ?? [])
            }
            healthStore.execute(query)
        }
    }
}
