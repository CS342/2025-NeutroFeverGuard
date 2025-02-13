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

private func loadMockData() {
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
