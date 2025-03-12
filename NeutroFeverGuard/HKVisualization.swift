// This source file is part of the NeutroFeverGuard based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//
import Charts
import Foundation
import HealthKit
import SpeziAccount
import SwiftUI

struct HKData: Identifiable {
    var date: Date
    var id = UUID()
    var sumValue: Double
    var avgValue: Double
    var minValue: Double
    var maxValue: Double
}

// swiftlint:disable closure_body_length
struct HealthDataListView: View {
    @Binding var heartRateData: [HKData]
    @Binding var heartRateScatterData: [HKData]
    @Binding var bodyTemperatureData: [HKData]
    @Binding var bodyTemperatureScatterData: [HKData]
    @Binding var oxygenSaturationData: [HKData]
    @Binding var oxygenSaturationScatterData: [HKData]
    
    var body: some View {
        List {
            Section {
                if !heartRateData.isEmpty {
                    HKVisualizationItem(
                        data: heartRateData,
                        xName: "Time",
                        yName: "Heart Rate (bpm)",
                        title: "Heart Rate Over Time",
                        threshold: 100,
                        scatterData: heartRateScatterData
                    )
                } else {
                    Text("No heart rate data available.")
                        .foregroundColor(.gray)
                }
            }
            Section {
                if !bodyTemperatureData.isEmpty {
                    HKVisualizationItem(
                        data: bodyTemperatureData,
                        xName: "Time",
                        yName: "Body Temperature (°F)",
                        title: "Body Temperature Over Time",
                        threshold: 99.0,
                        scatterData: bodyTemperatureScatterData
                    )
                } else {
                    Text("No body temperature data available.")
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
                        scatterData: oxygenSaturationScatterData
                    )
                } else {
                    Text("No oxygen saturation data available.")
                        .foregroundColor(.gray)
                }
            }
        }
    }
}
// swiftlint:enable closure_body_length

struct HKVisualization: View {
    @State var bodyTemperatureData: [HKData] = []
    @State var heartRateData: [HKData] = []
    @State var oxygenSaturationData: [HKData] = []
    @State var heartRateScatterData: [HKData] = []
    @State var oxygenSaturationScatterData: [HKData] = []
    @State var bodyTemperatureScatterData: [HKData] = []
    
    @Environment(Account.self) private var account: Account?
    @Binding var presentingAccount: Bool
    
    init(presentingAccount: Binding<Bool>) { self._presentingAccount = presentingAccount }

    var body: some View {
        self.readAllHKData()
        return NavigationStack {
            HealthDataListView(
                heartRateData: $heartRateData,
                heartRateScatterData: $heartRateScatterData,
                bodyTemperatureData: $bodyTemperatureData,
                bodyTemperatureScatterData: $bodyTemperatureScatterData,
                oxygenSaturationData: $oxygenSaturationData,
                oxygenSaturationScatterData: $oxygenSaturationScatterData
            )
            .navigationTitle("HKVIZ_NAVIGATION_TITLE")
            .onAppear {
                readAllHKData(ensureUpdate: true)
            }
            .toolbar {
                if account != nil {
                    AccountButton(isPresented: $presentingAccount)
                }
            }
        }
    }
    
    func readAllHKData(ensureUpdate: Bool = false) {
        if FeatureFlags.mockVizData {
            loadMockData()
            return
        }
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
        readHealthData(for: .heartRate, ensureUpdate: ensureUpdate, startDate: startDate, endDate: endDate, predicate: predicate)
        readHealthData(for: .oxygenSaturation, ensureUpdate: ensureUpdate, startDate: startDate, endDate: endDate, predicate: predicate)
        readHealthData(for: .bodyTemperature, ensureUpdate: ensureUpdate, startDate: startDate, endDate: endDate, predicate: predicate)
        print("Finished reading all HealthKit data.")
    }
    
    func loadMockData() {
        let loadData = { (view: HKVisualization) in
            let today = Date()
            let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today) ?? today
            let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: today) ?? today
            
            // Heart Rate Mock Data (60-100 bpm normal range)
            view.heartRateData = [
                HKData(date: today, sumValue: 75, avgValue: 75, minValue: 65, maxValue: 85),
                HKData(date: yesterday, sumValue: 82, avgValue: 82, minValue: 70, maxValue: 95),
                HKData(date: twoDaysAgo, sumValue: 90, avgValue: 90, minValue: 80, maxValue: 105)
            ]
                
            view.heartRateScatterData = [
                HKData(date: today, sumValue: 75, avgValue: 75, minValue: 75, maxValue: 75),
                HKData(date: yesterday, sumValue: 82, avgValue: 82, minValue: 82, maxValue: 82),
                HKData(date: twoDaysAgo, sumValue: 90, avgValue: 90, minValue: 90, maxValue: 90)
            ]
                
            // Body Temperature Mock Data (97-99°F normal range)
            view.bodyTemperatureData = [
                HKData(date: today, sumValue: 98.6, avgValue: 98.6, minValue: 98.2, maxValue: 99.0),
                HKData(date: yesterday, sumValue: 98.9, avgValue: 98.9, minValue: 98.5, maxValue: 99.2),
                HKData(date: twoDaysAgo, sumValue: 99.1, avgValue: 99.1, minValue: 98.7, maxValue: 99.5)
            ]
                
            view.bodyTemperatureScatterData = [
                HKData(date: today, sumValue: 98.6, avgValue: 98.6, minValue: 98.6, maxValue: 98.6),
                HKData(date: yesterday, sumValue: 98.9, avgValue: 98.9, minValue: 98.9, maxValue: 98.9),
                HKData(date: twoDaysAgo, sumValue: 99.1, avgValue: 99.1, minValue: 99.1, maxValue: 99.1)
            ]
                
            // Oxygen Saturation Mock Data (94-100% normal range)
            view.oxygenSaturationData = [
                HKData(date: today, sumValue: 98, avgValue: 98, minValue: 96, maxValue: 99),
                HKData(date: yesterday, sumValue: 97, avgValue: 97, minValue: 95, maxValue: 98),
                HKData(date: twoDaysAgo, sumValue: 96, avgValue: 96, minValue: 94, maxValue: 97)
            ]
                
            view.oxygenSaturationScatterData = [
                HKData(date: today, sumValue: 98, avgValue: 98, minValue: 98, maxValue: 98),
                HKData(date: yesterday, sumValue: 97, avgValue: 97, minValue: 97, maxValue: 97),
                HKData(date: twoDaysAgo, sumValue: 96, avgValue: 96, minValue: 96, maxValue: 96)
            ]
        }
        loadData(self) // Pass `self` to the closure
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

    private func readHealthData(
                                for identifier: HKQuantityTypeIdentifier,
                                ensureUpdate: Bool,
                                startDate: Date,
                                endDate: Date,
                                predicate: NSPredicate
    ) {
        switch identifier {
        case .heartRate:
            if self.heartRateData.isEmpty || ensureUpdate {
                readHKStats(startDate: startDate, endDate: endDate, predicate: predicate, quantityTypeIDF: identifier)
                readFromSampleQuery(predicate: predicate, quantityTypeIDF: identifier)
            }
        case .oxygenSaturation:
            if self.oxygenSaturationData.isEmpty || ensureUpdate {
                readHKStats(startDate: startDate, endDate: endDate, predicate: predicate, quantityTypeIDF: identifier)
                readFromSampleQuery(predicate: predicate, quantityTypeIDF: identifier)
            }
        case .bodyTemperature:
            if self.bodyTemperatureData.isEmpty || ensureUpdate {
                readHKStats(startDate: startDate, endDate: endDate, predicate: predicate, quantityTypeIDF: identifier)
                readFromSampleQuery(predicate: predicate, quantityTypeIDF: identifier)
            }
        default:
            print("Unsupported identifier: \(identifier.rawValue)")
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
    
    func readFromSampleQuery(predicate: NSPredicate, quantityTypeIDF: HKQuantityTypeIdentifier) {
         let healthStore = HKHealthStore()
         // Run a HKSampleQuery to fetch the health kit data.
         guard let quantityType = HKObjectType.quantityType(forIdentifier: quantityTypeIDF) else {
             fatalError("*** Unable to create a quantity type ***")
         }
         let typesToWrite: Set<HKSampleType> = [
            HKQuantityType(.heartRate),
            HKQuantityType(.bodyTemperature),
            HKQuantityType(.oxygenSaturation)
         ]
        
        healthStore.requestAuthorization(toShare: typesToWrite, read: typesToWrite) { success, error in
            if success {
                print("HealthKit authorization granted.")
            } else if let error = error {
                Task { @MainActor in
                    handleAuthorizationError(error)
                }
            }
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
                        self.heartRateScatterData = collectedData
                     } else if quantityTypeIDF == HKQuantityTypeIdentifier.bodyTemperature {
                         self.bodyTemperatureScatterData = collectedData
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
        case .bodyTemperature:
            self.bodyTemperatureData = allData
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
    case .bodyTemperature:
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
        } else if quantityTypeIDF == HKQuantityTypeIdentifier.bodyTemperature {
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
