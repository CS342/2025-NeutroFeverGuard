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
        
        // Request authorization
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
        
        // Create systolic sample
        let systolicQuantity = HKQuantity(unit: BloodPressureEntry.unit, doubleValue: entry.systolic)
        let systolicSample = HKQuantitySample(
            type: BloodPressureEntry.systolicType,
            quantity: systolicQuantity,
            start: entry.date,
            end: entry.date,
            metadata: metadata
        )
        
        // Create diastolic sample
        let diastolicQuantity = HKQuantity(unit: BloodPressureEntry.unit, doubleValue: entry.diastolic)
        let diastolicSample = HKQuantitySample(
            type: BloodPressureEntry.diastolicType,
            quantity: diastolicQuantity,
            start: entry.date,
            end: entry.date,
            metadata: metadata
        )
        
        // Save both samples
        try await healthStore.save([systolicSample, diastolicSample])
    }
    
    func saveLabValues(_ entries: [LabEntry]) async throws {
        let metadata: [String: Any] = [
            HKMetadataKeyWasUserEntered: true
        ]
        
        // Ensure all entries are from the same date
        guard let firstDate = entries.first?.date,
              entries.allSatisfy({ $0.date == firstDate }) else {
            throw NSError(domain: "HealthKitService", code: 2, userInfo: [
                NSLocalizedDescriptionKey: "All lab values must be from the same date"
            ])
        }
        
        // Create samples for each lab value
        var samples: [HKQuantitySample] = []
        
        for entry in entries {
            // Map lab test types to appropriate HealthKit types and units
            let (type, unit) = try mapLabTestToHealthKit(entry.testType)
            
            let quantity = HKQuantity(unit: unit, doubleValue: entry.value)
            let sample = HKQuantitySample(
                type: type,
                quantity: quantity,
                start: entry.date,
                end: entry.date,
                metadata: metadata
            )
            samples.append(sample)
        }
        
        // Create a correlation to group all samples together
        fatalError("Not Implemented")
//        let correlationType = HKObjectType.correlationType(forIdentifier: .labResults)!
//        let correlation = HKCorrelation(
//            type: correlationType,
//            start: firstDate,
//            end: firstDate,
//            objects: Set(samples),
//            metadata: metadata
//        )
        
        // Save the correlation
//        try await healthStore.save(correlation)
    }
    
    private func mapLabTestToHealthKit(_ testType: LabTestType) throws -> (HKQuantityType, HKUnit) {
        fatalError("Not Implemented")
//        switch testType {
//        case .whiteBloodCell:
//            return (
//                HKQuantityType(.whiteBloodCellCount),
//                HKUnit.count().unitDivided(by: HKUnit.literUnit(with: .milli))
//            )
//        case .hemoglobin:
//            return (
//                HKQuantityType(.hemoglobin),
//                HKUnit.gramUnit(with: .deci).unitDivided(by: HKUnit.literUnit(with: .deci))
//            )
//        case .plateletCount:
//            return (
//                HKQuantityType(.plateletCount),
//                HKUnit.count().unitDivided(by: HKUnit.literUnit(with: .milli))
//            )
//        case .neutrophils, .lymphocytes, .monocytes, .eosinophils, .basophils, .blasts:
//            return (
//                HKQuantityType(.numberOfTimesFallen),
//                HKUnit.percent()
//            ) // Using a placeholder type since HealthKit doesn't have specific types for these
//        }
    }
} 
