// periphery:ignore all
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
import NeutroFeverGuard
import SpeziAccount
import SwiftUI

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


func generateDateRange() -> [Any] {
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

func handleAuthorizationError(_ error: Error) -> String {
    if let hkError = error as? HKError {
        switch hkError.code {
        case .errorAuthorizationDenied:
            return "Authorization denied by the user."
        case .errorHealthDataUnavailable:
            return "Health data is unavailable on this device."
        case .errorInvalidArgument:
            return "Invalid argument provided for HealthKit authorization."
        default:
            return "Unhandled HealthKit error: \(error.localizedDescription)"
        }
    } else {
        return "Unknown error during HealthKit authorization: \(error.localizedDescription)"
    }
}

struct HKData: Identifiable {
    var date: Date
    var id = UUID()
    var sumValue: Double
    var avgValue: Double
    var minValue: Double
    var maxValue: Double
}

struct HKVisualization: View {
    // swiftlint:disable closure_body_length
    @Environment(LabResultsManager.self) private var labResultsManager
    @State var bodyTemperatureData: [HKData] = []
    @State var heartRateData: [HKData] = []
    @State var oxygenSaturationData: [HKData] = []
    @State var heartRateScatterData: [HKData] = []
    @State var oxygenSaturationScatterData: [HKData] = []
    @State var bodyTemperatureScatterData: [HKData] = []
    @State var neutrophilData: [HKData] = []
    @State var neutrophilScatterData: [HKData] = []
    
    var vizList: some View {
        self.readAllHKData()
        return List {
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
            Section {
                if !neutrophilData.isEmpty {
                    HKVisualizationItem(
                        data: neutrophilData,
                        xName: "Date",
                        yName: "Neutrophil Count",
                        title: "Neutrophil Count Over Past Week",
                        threshold: 15, // Adjust the threshold if necessary
                        scatterData: neutrophilScatterData
                    )
                } else {
                    Text("No neutrophil count data available.")
                        .foregroundColor(.gray)
                }
            }        }
    }
    
    @Environment(Account.self) private var account: Account?
    @Binding var presentingAccount: Bool
    
    init(presentingAccount: Binding<Bool>) {
        self._presentingAccount = presentingAccount
    }
    
    var body: some View {
        self.readAllHKData()
        
        return NavigationStack {
            vizList
            .navigationTitle("Dashboard")
            .onAppear {
                // Ensure that data up-to-date when the view is activated.
                self.readAllHKData(ensureUpdate: true)
                labResultsManager.loadLabResults()
                loadNeutrophilData() // Ensure this is called
            }
            .toolbar {
                if account != nil {
                    AccountButton(isPresented: $presentingAccount)
                }
            }
        }
    }
    
    private func loadNeutrophilData() {
        let rawData = labResultsManager.getAllAncValues().filter {
            $0.date >= Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        }
        
        // Convert to HKData for bar plot
        neutrophilData = rawData.map { record in
            HKData(
                date: record.date,
                sumValue: record.ancValue,
                avgValue: record.ancValue,
                minValue: record.ancValue,
                maxValue: record.ancValue
            )
        }

        // Create scatter data (with some random variation to separate points)
        neutrophilScatterData = rawData.map { record in
            HKData(
                date: record.date,
                sumValue: record.ancValue + Double.random(in: -0.5...0.5), // Add slight variation for visualization
                avgValue: -1.0,
                minValue: -1.0,
                maxValue: -1.0
            )
        }

        print("✅ Converted neutrophil data: \(neutrophilData)")
        print("✅ Scatter neutrophil data: \(neutrophilScatterData)")
    }

    private func getNeutrophilCountsForPastWeek() -> [(date: Date, ancValue: Double)] {
        let oneWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let allValues = labResultsManager.getAllAncValues()
        
        print("🔍 All ANC Values: \(allValues)")
        
        let filteredValues = allValues.filter { $0.date >= oneWeekAgo }
        print("✅ Filtered ANC Values: \(filteredValues)")
        
        return filteredValues
    }
  
    func readAllHKData(ensureUpdate: Bool = false) {
        if FeatureFlags.mockVizData {
            loadMockDataNew()
            return
        }
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
        readHealthData(for: .heartRate, ensureUpdate: ensureUpdate, startDate: startDate, endDate: endDate, predicate: predicate)
        readHealthData(for: .oxygenSaturation, ensureUpdate: ensureUpdate, startDate: startDate, endDate: endDate, predicate: predicate)
        readHealthData(for: .bodyTemperature, ensureUpdate: ensureUpdate, startDate: startDate, endDate: endDate, predicate: predicate)
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
    func loadMockDataNew() {
        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today) ?? today
        let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: today) ?? today
        let minMaxAvgStatData = [
            HKData(date: today, sumValue: 0, avgValue: 50, minValue: 1, maxValue: 100)
        ]
    
        // Clear out bar data to prevent rendering of bar graphs
        self.heartRateData = minMaxAvgStatData
        self.bodyTemperatureData = minMaxAvgStatData
        self.oxygenSaturationData = minMaxAvgStatData
        
        // ✅ Heart Rate Scatter Data (60-100 bpm normal range)
        self.heartRateScatterData = [
            HKData(date: today, sumValue: 75, avgValue: 75, minValue: 75, maxValue: 75),
            HKData(date: yesterday, sumValue: 82, avgValue: 82, minValue: 82, maxValue: 82),
            HKData(date: twoDaysAgo, sumValue: 90, avgValue: 90, minValue: 90, maxValue: 90)
        ]
        
        // ✅ Body Temperature Scatter Data (97-99°F normal range)
        self.bodyTemperatureScatterData = [
            HKData(date: today, sumValue: 98.6, avgValue: 98.6, minValue: 98.6, maxValue: 98.6),
            HKData(date: yesterday, sumValue: 98.9, avgValue: 98.9, minValue: 98.9, maxValue: 98.9),
            HKData(date: twoDaysAgo, sumValue: 99.1, avgValue: 99.1, minValue: 99.1, maxValue: 99.1)
        ]
        
        // ✅ Oxygen Saturation Scatter Data (94-100% normal range)
        self.oxygenSaturationScatterData = [
            HKData(date: today, sumValue: 98, avgValue: 98, minValue: 98, maxValue: 98),
            HKData(date: yesterday, sumValue: 97, avgValue: 97, minValue: 97, maxValue: 97),
            HKData(date: twoDaysAgo, sumValue: 96, avgValue: 96, minValue: 96, maxValue: 96)
        ]
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
        return -1.0
    }
}

#Preview {

}
