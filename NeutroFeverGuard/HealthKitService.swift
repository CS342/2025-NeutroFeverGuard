//
// This source file is part of the NeutroFeverGuard based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import HealthKit
import SpeziHealthKit

actor HealthKitService {
    internal let healthStore = HKHealthStore()
    
    init() {}
    
    func requestAuthorization() async throws {
        // Define the types we want to write
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
        let quantity = HKQuantity(unit: OxygenSaturationEntry.unit, doubleValue: entry.percentage)
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
        let metadata: [String: Any] = [
            HKMetadataKeyWasUserEntered: true
        ]

        let systolicQuantity = HKQuantity(unit: BloodPressureEntry.unit, doubleValue: entry.systolic)
        let diastolicQuantity = HKQuantity(unit: BloodPressureEntry.unit, doubleValue: entry.diastolic)

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

        let bloodPressureCorrelation = HKCorrelation(
            type: HKObjectType.correlationType(forIdentifier: .bloodPressure)!,
            start: entry.date,
            end: entry.date,
            objects: [systolicSample, diastolicSample],
            metadata: metadata
        )

        try await healthStore.save(bloodPressureCorrelation)
    }
}
