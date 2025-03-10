//
// This source file is part of the NeutroFeverGuard based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import ByteCoding
import Foundation
import NIOCore
import Spezi
import SpeziBluetooth

struct SkinTemperatureMeasurement {
    enum TemperatureUnit {
        case celsius
        case fahrenheit
    }
    
    let temperature: Float?
    let unit: TemperatureUnit

    init(temperature: Float?, unit: TemperatureUnit) {
        self.temperature = temperature
        self.unit = unit
    }
}
