//
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

public struct HKData: Identifiable {
    var date: Date
    // periphery:ignore
    public var id = UUID()
    var sumValue: Double
    var avgValue: Double
    var minValue: Double
    var maxValue: Double
}


struct HKVisualization: View {
    // @Environment(PatientInformation.self)
    // private var patientInformation
    
    @State var basalBodyTemperatureData: [HKData] = []
    @State var heartRateData: [HKData] = []
    @State var oxygenSaturationData: [HKData] = []
    @State var heartRateScatterData: [HKData] = []
    @State var oxygenSaturationScatterData: [HKData] = []
    @State var basalBodyTemperatureScatterData: [HKData] = []
    
    var visualizationList: some View {
        self.readAllHKData()
        return List {
            Section {
                HKVisualizationItem(
                    data: self.heartRateData,
                    xName: "Time",
                    yName: "Heart Rate (beats/min)",
                    title: "HKVIZ_PLOT_HEART_TITLE",
                    scatterData: self.heartRateScatterData
                )
            }
        }
    }
    // @Binding var presentingAccount: Bool

    var body: some View {
        self.readAllHKData()
        
        return NavigationStack {
            visualizationList
                .navigationTitle("HKVIZ_NAVIGATION_TITLE")
                // .toolbar {
                  //  if AccountButton.shouldDisplay {
                    //    AccountButton(isPresented: $presentingAccount)
                    // }
                // }
                .onAppear {
                    self.readAllHKData(ensureUpdate: true)
                }
        }
    }
    // init(presentingAccount: Binding<Bool>) {
        // self._presentingAccount = presentingAccount
    // }
    
    func loadMockData() { // NEED TO CHANGE THIS
        let today = Date()
        let sumStatData = [
            HKData(date: today, sumValue: 100, avgValue: 0, minValue: 0, maxValue: 0),
            HKData(date: today, sumValue: 100, avgValue: 0, minValue: 0, maxValue: 0)
        ]
        let minMaxAvgStatData = [
            HKData(date: today, sumValue: 0, avgValue: 50, minValue: 1, maxValue: 100)
        ]
        // if self.stepData.isEmpty {
            // self.stepData = sumStatData
            // self.heartRateScatterData = sumStatData
            // self.oxygenSaturationScatterData = sumStatData
            // self.heartRateData = minMaxAvgStatData
            // self.oxygenSaturationData = minMaxAvgStatData
        // }
    }
    
    func readAllHKData(ensureUpdate: Bool = false) {
        // if FeatureFlags.mockTestData {
            // loadMockData()
            // return
        // }
        
        let dateRange = generateDateRange()

        guard let startDate = dateRange[0] as? Date else {
            fatalError("*** start date was not properly formatted ***")
        }
        guard let endDate = dateRange[1] as? Date else {
            fatalError("*** end date was not properly formatted ***")
        }
        guard let predicate = dateRange[2] as? NSPredicate else {
            fatalError("*** predicate was not properly formatted ***")
        }

        readHealthData(for: .heartRate, ensureUpdate: ensureUpdate, startDate: startDate, endDate: endDate, predicate: predicate)
        readHealthData(for: .oxygenSaturation, ensureUpdate: ensureUpdate, startDate: startDate, endDate: endDate, predicate: predicate)
        readHealthData(for: .basalBodyTemperature, ensureUpdate: ensureUpdate, startDate: startDate, endDate: endDate, predicate: predicate)
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
                readFromSampleQuery(startDate: startDate, endDate: endDate, predicate: predicate, quantityTypeIDF: identifier)
            }
        case .oxygenSaturation:
            if self.oxygenSaturationData.isEmpty || ensureUpdate {
                readHKStats(startDate: startDate, endDate: endDate, predicate: predicate, quantityTypeIDF: identifier)
                readFromSampleQuery(startDate: startDate, endDate: endDate, predicate: predicate, quantityTypeIDF: identifier)
            }
        case .basalBodyTemperature:
            if self.basalBodyTemperatureData.isEmpty || ensureUpdate {
                readHKStats(startDate: startDate, endDate: endDate, predicate: predicate, quantityTypeIDF: identifier)
                readFromSampleQuery(startDate: startDate, endDate: endDate, predicate: predicate, quantityTypeIDF: identifier)
            }
        default:
            print("Unsupported identifier: \(identifier.rawValue)")
        }
    }
    
    
    func readFromSampleQuery(
         startDate: Date,
         endDate: Date,
         predicate: NSPredicate,
         quantityTypeIDF: HKQuantityTypeIdentifier
     ) {
         let healthStore = HKHealthStore()
         // Run a HKSampleQuery to fetch the health kit data.
         guard let quantityType = HKObjectType.quantityType(forIdentifier: quantityTypeIDF) else {
             fatalError("*** Unable to create a quantity type ***")
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
                     } else if quantityTypeIDF == HKQuantityTypeIdentifier.basalBodyTemperature {
                         self.basalBodyTemperatureScatterData = collectedData
                     }
                 }
             }
         }
         healthStore.execute(query)
     }
    
    
    func readHKStats(
        startDate: Date,
        endDate: Date,
        predicate: NSPredicate,
        quantityTypeIDF: HKQuantityTypeIdentifier
    ) {
        let healthStore = HKHealthStore()
        // Read the step counts per day for the past three months.
        guard let quantityType = HKObjectType.quantityType(forIdentifier: quantityTypeIDF) else {
            fatalError("*** Unable to create a quantity type ***")
        }
        let query = if quantityTypeIDF == HKQuantityTypeIdentifier.stepCount {
            HKStatisticsCollectionQuery(
                quantityType: quantityType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum,
                anchorDate: startDate,
                intervalComponents: DateComponents(day: 1)
            )
        } else {
            HKStatisticsCollectionQuery(
                quantityType: quantityType,
                quantitySamplePredicate: predicate,
                options: [.discreteMax, .discreteMin, .discreteAverage],
                anchorDate: startDate,
                intervalComponents: DateComponents(day: 1)
            )
        }
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
    
    func updateQueryResult(
        results: HKStatisticsCollection,
        startDate: Date,
        endDate: Date,
        quantityTypeIDF: HKQuantityTypeIdentifier
    ) {
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
        default:
            print("Unexpected quantity received:", quantityTypeIDF)
        }
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
// Inputs:
//  [HKSample] is an array of raw healthKit samples
//  quantityTypeIDF identifies the type of health data (ex. heart rate)
// Output: Array of HKdata objects

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
