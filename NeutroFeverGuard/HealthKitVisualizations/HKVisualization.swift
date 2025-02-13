// swiftlint:disable all
// This source file is part of the NeutroFeverGuard based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//
import Charts
import Foundation
import HealthKit
import SwiftUI

struct HKData: Identifiable {
    var date: Date
    // periphery:ignore
    var id = UUID()
    var sumValue: Double
    var avgValue: Double
    var minValue: Double
    var maxValue: Double
}

struct HKVisualization: View {
    // swiftlint:disable closure_body_length
    @State var basalBodyTemperatureData: [HKData] = []
    @State var heartRateData: [HKData] = []
    @State var oxygenSaturationData: [HKData] = []
    @State var heartRateScatterData: [HKData] = []
    @State var oxygenSaturationScatterData: [HKData] = []
    @State var basalBodyTemperatureScatterData: [HKData] = []
    
    var body: some View {
        // swiftlint:disable closure_body_length
        NavigationStack {
            List {
                Section {
                    if !heartRateData.isEmpty {
                        HKVisualizationItem(
                            data: heartRateData,
                            xName: "Time",
                            yName: "Heart Rate (bpm)",
                            title: "Heart Rate Over Time",
                            threshold: 100,
                            scatterData: heartRateData
                        )
                    } else {
                        Text("No heart rate data available.")
                            .foregroundColor(.gray)
                    }
                }
                Section {
                    if !basalBodyTemperatureData.isEmpty {
                        HKVisualizationItem(
                            data: basalBodyTemperatureData,
                            xName: "Time",
                            yName: "Body Temperature (°F)",
                            title: "Basal Body Temperature Over Time",
                            threshold: 99.0,
                            scatterData: basalBodyTemperatureData
                        )
                    } else {
                        Text("No basal body temperature data available.")
                            .foregroundColor(.gray)
                    }
                }
                Section {
                    if !oxygenSaturationData.isEmpty {
                        HKVisualizationItem(
                            data: oxygenSaturationData,
                            xName: "Time",
                            yName: "Oxygen Saturation (%)",
                            title: "Oxygen Saturation Over Time",
                            threshold: 94.0,
                            scatterData: oxygenSaturationData
                        )
                    } else {
                        Text("No oxygen saturation data available.")
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("Vitals Dashboard")
            .onAppear {
                Task {
                    if ProcessInfo.processInfo.environment["IS_UITEST"] == "1" {
                        loadMockData()
                    } else {
                        await readAllHKData()
                    }
                }
            }
        }
    // swiftlint:enable closure_body_length
    }
    
    func readAllHKData(ensureUpdate: Bool = false) async {
            print("Reading all HealthKit data with ensureUpdate: \(ensureUpdate)")
            let dateRange = generateDateRange()
            guard let startDate = dateRange[0] as? Date else {
                fatalError("*** Start date was not properly formatted ***")
            }
            guard let endDate = dateRange[1] as? Date else {
                fatalError("*** End date was not properly formatted ***")
            }
            guard let predicate = dateRange[2] as? NSPredicate else {
                fatalError("*** Predicate was not properly formatted ***")
            }
            
            print("Date Range: \(startDate) - \(endDate)")
            
            await readHealthData(for: .heartRate, ensureUpdate: ensureUpdate, startDate: startDate, endDate: endDate, predicate: predicate)
            await readHealthData(for: .oxygenSaturation, ensureUpdate: ensureUpdate, startDate: startDate, endDate: endDate, predicate: predicate)
            await readHealthData(for: .basalBodyTemperature, ensureUpdate: ensureUpdate, startDate: startDate, endDate: endDate, predicate: predicate)
            
            print("Finished reading all HealthKit data.")
        }

    private func generateDateRange() -> [Any] {
        let startOfToday = Calendar.current.startOfDay(for: Date())
        guard let endDate = Calendar.current.date(byAdding: DateComponents(hour: 23, minute: 59, second: 59), to: startOfToday) else {
            fatalError("*** Unable to create an end date ***")
        }
        guard let startDate = Calendar.current.date(byAdding: .day, value: -14, to: endDate) else {
            fatalError("*** Unable to create a start date ***")
        }
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
        return [startDate, endDate, predicate]
    }

    private func readHealthData(for identifier: HKQuantityTypeIdentifier, ensureUpdate: Bool, startDate: Date, endDate: Date, predicate: NSPredicate) async {
        switch identifier {
        case .heartRate:
            if self.heartRateData.isEmpty || ensureUpdate {
                readHKStats(startDate: startDate, endDate: endDate, predicate: predicate, quantityTypeIDF: identifier)
                await readFromSampleQuery(startDate: startDate, endDate: endDate, predicate: predicate, quantityTypeIDF: identifier)
            }
        case .oxygenSaturation:
            if self.oxygenSaturationData.isEmpty || ensureUpdate {
                readHKStats(startDate: startDate, endDate: endDate, predicate: predicate, quantityTypeIDF: identifier)
                await readFromSampleQuery(startDate: startDate, endDate: endDate, predicate: predicate, quantityTypeIDF: identifier)
            }
        case .basalBodyTemperature:
            if self.basalBodyTemperatureData.isEmpty || ensureUpdate {
                readHKStats(startDate: startDate, endDate: endDate, predicate: predicate, quantityTypeIDF: identifier)
                await readFromSampleQuery(startDate: startDate, endDate: endDate, predicate: predicate, quantityTypeIDF: identifier)
            }
        default:
            print("Unsupported identifier: \(identifier.rawValue)")
        }
    }
    
    func loadMockData() {
        let today = Date()
        self.heartRateData = (0..<10).map {
            HKData(
                   date: Calendar.current.date(byAdding: .day, value: -$0, to: today) ??  Date(),
                   sumValue: Double.random(in: 60...120),
                   avgValue: 80,
                   minValue: 60,
                   maxValue: 120
            )
        }
        self.basalBodyTemperatureData = (0..<10).map {
            HKData(
                   date: Calendar.current.date(byAdding: .day, value: -$0, to: today) ?? Date(),
                   sumValue: Double.random(in: 97...99),
                   avgValue: 98.6,
                   minValue: 97,
                   maxValue: 99
            )
        }
        self.oxygenSaturationData = (0..<10).map {
            HKData(
                   date: Calendar.current.date(byAdding: .day, value: -$0, to: today) ?? Date(),
                   sumValue: Double.random(in: 90...100),
                   avgValue: 95,
                   minValue: 90,
                   maxValue: 100
            )
        }
    }

    func handleAuthorizationError(_ error: Error) {
        if let hkError = error as? HKError {
            switch hkError.code {
            case .errorAuthorizationDenied:
                print("Authorization denied by the user.")
            case .errorHealthDataUnavailable:
                print("Health data is unavailable on this device.")
            case .errorInvalidArgument:
                print("Invalid argument provided for HealthKit authorization.")
            default:
                print("Unhandled HealthKit error: \(error.localizedDescription)")
            }
        } else {
            print("Unknown error during HealthKit authorization: \(error.localizedDescription)")
        }
    }
    
    func readFromSampleQuery(startDate: Date, endDate: Date, predicate: NSPredicate, quantityTypeIDF: HKQuantityTypeIdentifier) async {
         let healthStore = HKHealthStore()
         // Run a HKSampleQuery to fetch the health kit data.
         guard let quantityType = HKObjectType.quantityType(forIdentifier: quantityTypeIDF) else {
             fatalError("*** Unable to create a quantity type ***")
         }
         let typesToWrite: Set<HKSampleType> = [
            HKQuantityType(.heartRate),
            HKQuantityType(.basalBodyTemperature),
            HKQuantityType(.oxygenSaturation)
         ]
         do {
             try await healthStore.requestAuthorization(toShare: typesToWrite, read: typesToWrite)
             print("HealthKit authorization granted.")
         } catch {
             handleAuthorizationError(error)
         }
         let sortDescriptors = [
             NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
         ]
         let query = HKSampleQuery(
             sampleType: quantityType,
             predicate: predicate,
             limit: Int(HKObjectQueryNoLimit),
             sortDescriptors: sortDescriptors
         ) { _, results, error in
             Task { @MainActor in
                 guard error == nil else {
                     print("Error retrieving health kit data: \(String(describing: error))")
                     return
                 }
                 if let results = results {
                     // Retrieve quantity value and time for each data point.
                     let collectedData = parseSampleQueryData(results: results, quantityTypeIDF: quantityTypeIDF)
                     if quantityTypeIDF == HKQuantityTypeIdentifier.oxygenSaturation {
                         self.oxygenSaturationScatterData = collectedData
                     } else if quantityTypeIDF == HKQuantityTypeIdentifier.heartRate {
                        self.heartRateData = collectedData
                     } else if quantityTypeIDF == HKQuantityTypeIdentifier.basalBodyTemperature {
                         self.basalBodyTemperatureScatterData = collectedData
                     }
                 }
             }
         }
         healthStore.execute(query)
     }
    
    func readHKStats(startDate: Date, endDate: Date, predicate: NSPredicate, quantityTypeIDF: HKQuantityTypeIdentifier) {
        let healthStore = HKHealthStore()
        // Read the step counts per day for the past three months.
        guard let quantityType = HKObjectType.quantityType(forIdentifier: quantityTypeIDF) else {
            fatalError("*** Unable to create a quantity type ***")
        }
        let query =
            HKStatisticsCollectionQuery(
                quantityType: quantityType,
                quantitySamplePredicate: predicate,
                options: [.discreteMax, .discreteMin, .discreteAverage],
                anchorDate: startDate,
                intervalComponents: DateComponents(day: 1)
            )
        
        query.initialResultsHandler = { _, results, error in
            Task { @MainActor in
                guard error == nil else {
                    print("Error retrieving health kit data: \(String(describing: error))")
                    return
                }
                if let results = results {
                    updateQueryResult(results: results, startDate: startDate, endDate: endDate, quantityTypeIDF: quantityTypeIDF)
                }
            }
        }
        healthStore.execute(query)
    }
    
    func updateQueryResult(results: HKStatisticsCollection, startDate: Date, endDate: Date, quantityTypeIDF: HKQuantityTypeIdentifier) {
        var allData: [HKData] = []
        // Enumerate over all the statistics objects between the start and end dates.
        results.enumerateStatistics(from: startDate, to: endDate) { statistics, _ in
            if let curHKData = parseStat(statistics: statistics, quantityTypeIDF: quantityTypeIDF) {
                allData.append(curHKData)
            }
        }
        
        switch quantityTypeIDF {
        case .oxygenSaturation:
            self.oxygenSaturationData = allData
        case .heartRate:
            self.heartRateData = allData
        case .basalBodyTemperature:
            self.basalBodyTemperatureData = allData
        default:
            print("Unexpected quantity received:", quantityTypeIDF)
        }
    }
    // swiftlint:enable closure_body_length
}

func parseStat(statistics: HKStatistics, quantityTypeIDF: HKQuantityTypeIdentifier) -> HKData? {
    let date = statistics.endDate
    var curSum = 0.0
    var curMax = 0.0
    var curAvg = 0.0
    var curMin = 0.0
    if let quantity = statistics.sumQuantity() {
        curSum = parseValue(quantity: quantity, quantityTypeIDF: quantityTypeIDF)
    }
    if let quantity = statistics.maximumQuantity() {
        curMax = parseValue(quantity: quantity, quantityTypeIDF: quantityTypeIDF)
    }
    if let quantity = statistics.averageQuantity() {
        curAvg = parseValue(quantity: quantity, quantityTypeIDF: quantityTypeIDF)
    }
    if let quantity = statistics.minimumQuantity() {
        curMin = parseValue(quantity: quantity, quantityTypeIDF: quantityTypeIDF)
    }
    if curSum != 0.0 || curMin != 0.0 || curMin != 0.0 || curMax != 0.0 {
        return HKData(date: date, sumValue: curSum, avgValue: curAvg, minValue: curMin, maxValue: curMax)
    }
    return nil
}

func parseValue(quantity: HKQuantity, quantityTypeIDF: HKQuantityTypeIdentifier) -> Double {
    switch quantityTypeIDF {
    case .oxygenSaturation:
        return quantity.doubleValue(for: .percent()) * 100
    case .heartRate:
        return quantity.doubleValue(for: HKUnit(from: "count/min"))
    case .basalBodyTemperature:
        return quantity.doubleValue(for: .degreeCelsius())
    default:
        print("Unexpected quantity received:", quantityTypeIDF)
        return -1.0
    }
}

// Parses the raw HealthKit data.
func parseSampleQueryData(results: [HKSample], quantityTypeIDF: HKQuantityTypeIdentifier) -> [HKData] {
    // Retrieve quantity value and time for each data point.
    
    // initialize empty data array
    var collectedData: [HKData] = []
    
    for result in results {
        guard let result: HKQuantitySample = result as? HKQuantitySample else {
            print("Unexpected HK Quantity sample received.")
            continue
        }
        var value = -1.0
        // oxygen saturation collect
        if quantityTypeIDF == HKQuantityTypeIdentifier.oxygenSaturation {
            value = result.quantity.doubleValue(for: HKUnit.percent()) * 100
            
        // hear rate collect
        } else if quantityTypeIDF == HKQuantityTypeIdentifier.heartRate {
            value = result.quantity.doubleValue(for: HKUnit(from: "count/min"))
        
        // body temperature collect
        } else if quantityTypeIDF == HKQuantityTypeIdentifier.basalBodyTemperature {
            value = result.quantity.doubleValue(for: .degreeCelsius())
        }
        
        // retrieve the date the data was recorded
        let date = result.startDate
        collectedData.append(HKData(date: date, sumValue: value, avgValue: -1.0, minValue: -1.0, maxValue: -1.0))
    }
    return collectedData
}

#Preview {
    let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()

    let mockData = [
        HKData(date: Date(), sumValue: 100, avgValue: 96, minValue: 90, maxValue: 105),
        HKData(date: yesterday, sumValue: 0, avgValue: 96, minValue: 91, maxValue: 102)
    ]
    
    HKVisualizationItem(
        data: mockData,
        xName: "Date",
        yName: "Oxygen Saturation (%)",
        title: "Blood Oxygen Saturation",
        threshold: 94.0,
        helperText: "Maintain oxygen saturation above 94%."
    )
}
