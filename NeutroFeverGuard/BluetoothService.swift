//
// This source file is part of the NeutroFeverGuard based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
import Spezi
import SpeziBluetooth

struct DeviceInformationService: BluetoothService {
    static let id: BTUUID = "180A"
    
    @Characteristic(id: "2A29") var manufacturer: String?
    @Characteristic(id: "2A26") var firmwareRevision: String?
}

final class CoreSensor: BluetoothDevice, @unchecked Sendable, Identifiable {
    @DeviceState(\.id) var id: UUID
    @DeviceState(\.name) var name: String?
    @DeviceState(\.state) var state: PeripheralState
    
    @Service var deviceInformation = DeviceInformationService()
    
    @DeviceAction(\.connect) var connect
    @DeviceAction(\.disconnect) var disconnect
    
    init() {}
}
