//
//  BluetoothService.swift
//  NeutroFeverGuard
//
//  Created by Merve Cerit on 3/6/25.
//
import Foundation
import Spezi
import SpeziBluetooth

struct DeviceInformationService: BluetoothService {
    static let id: BTUUID = "180A"
    
    @Characteristic(id: "2A29") var manufacturer: String?
    @Characteristic(id: "2A26") var firmwareRevision: String?
}

class CoreSensor: BluetoothDevice {
    @DeviceState(\.id) var id: UUID
    @DeviceState(\.name) var name: String?
    @DeviceState(\.state) var state: PeripheralState
    
    @Service var deviceInformation = DeviceInformationService()
    
    @DeviceAction(\.connect) var connect
    @DeviceAction(\.disconnect) var disconnect
    
    required init() {}
}
