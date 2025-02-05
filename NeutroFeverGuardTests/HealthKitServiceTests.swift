import Testing
import HealthKit
@testable import NeutroFeverGuard

final class HealthKitServiceTests {
    private var healthKitService: HealthKitService!
    
    func setUp() async throws {
        healthKitService = HealthKitService()
        try await healthKitService.requestAuthorization()
    }
    
    @Test
    func testHeartRateSaveAndFetch() async throws {
        let date: Date = Date()
        let heartRate = try HeartRateEntry(date: date, bpm: 75.0)
        try await healthKitService.saveHeartRate(heartRate)
        
        let samples = try await fetchHealthData(type: HeartRateEntry.healthKitType, date: date)
        #expect(!samples.isEmpty)
        
        if let sample = samples.first as? HKQuantitySample {
            #expect(sample.quantity.doubleValue(for: HeartRateEntry.unit), equals: 75.0, within: 0.1)
            #expect(sample.startDate == date)
        }
    }
    
    @Test
    func testTemperatureSaveAndFetch() async throws {
        let date = Date()
        let temperature = try TemperatureEntry(date: date, value: 37.5, unit: .celsius)
        try await healthKitService.saveTemperature(temperature)
        
        let samples = try await fetchHealthData(type: TemperatureEntry.healthKitType, date: date)
        #expect(!samples.isEmpty)
        
        if let sample = samples.first as? HKQuantitySample {
            #expect(sample.quantity.doubleValue(for: .degreeCelsius()), equals: 37.5, within: 0.1)
            #expect(sample.startDate == date)
        }
    }
    
    @Test
    func testOxygenSaturationSaveAndFetch() async throws {
        let date = Date()
        let oxygenSaturation = try OxygenSaturationEntry(date: date, percentage: 98.0)
        try await healthKitService.saveOxygenSaturation(oxygenSaturation)
        
        let samples = try await fetchHealthData(type: OxygenSaturationEntry.healthKitType, date: date)
        #expect(!samples.isEmpty)
        
        if let sample = samples.first as? HKQuantitySample {
            #expect(sample.quantity.doubleValue(for: OxygenSaturationEntry.unit), equals: 98.0, within: 0.1)
            #expect(sample.startDate == date)
        }
    }
    
    @Test
    func testBloodPressureSaveAndFetch() async throws {
        let date = Date()
        let bloodPressure = try BloodPressureEntry(date: date, systolic: 120.0, diastolic: 80.0)
        try await healthKitService.saveBloodPressure(bloodPressure)
        
        // Check systolic
        let systolicSamples = try await fetchHealthData(type: BloodPressureEntry.systolicType, date: date)
        #expect(!systolicSamples.isEmpty)
        
        if let sample = systolicSamples.first as? HKQuantitySample {
            #expect(sample.quantity.doubleValue(for: BloodPressureEntry.unit), equals: 120.0, within: 0.1)
            #expect(sample.startDate == date)
        }
        
        // Check diastolic
        let diastolicSamples = try await fetchHealthData(type: BloodPressureEntry.diastolicType, date: date)
        #expect(!diastolicSamples.isEmpty)
        
        if let sample = diastolicSamples.first as? HKQuantitySample {
            #expect(sample.quantity.doubleValue(for: BloodPressureEntry.unit), equals: 80.0, within: 0.1)
            #expect(sample.startDate == date)
        }
    }
    
    // Helper function to fetch health data
    private func fetchHealthData(type: HKQuantityType, date: Date) async throws -> [HKSample] {
        let predicate = HKQuery.predicateForSamples(withStart: date, end: date.addingTimeInterval(1))
        let query = HKSampleQuery(
            sampleType: type,
            predicate: predicate,
            limit: 1,
            sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
        )
        
        return try await withCheckedThrowingContinuation { continuation in
            healthKitService.healthStore.execute(query) { query, results, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: results ?? [])
                }
            }
        }
    }
}