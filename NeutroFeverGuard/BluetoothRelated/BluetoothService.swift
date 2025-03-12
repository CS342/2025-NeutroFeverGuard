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

// struct DeviceInformationService: BluetoothService {
//    static let id: BTUUID = "180A"
    
//    @Characteristic(id: "2A29") var manufacturer: String?
//    @Characteristic(id: "2A26") var firmwareRevision: String?
// }

// struct BatteryService: BluetoothService {
//    static let id: BTUUID = "180F"
//
//    @Characteristic(id: "2A19") var battery: String?
// }

// struct CoreTemperatureService: BluetoothService {
//    static let id: BTUUID = "00002100-5B1E-4347-B07C-97B514DAE121"
//
//    @Characteristic(id: "00002100-5B1E-4347-B07C-97B514DAE121") var coreTemperature: String?
// }

struct SkinTemperatureService: BluetoothService {
    static let id: BTUUID = "1809"
    
    @Characteristic(id: "2A1C", notify: true) var skinTemperature: Data?
}

final class CoreSensor: BluetoothDevice, @unchecked Sendable, ObservableObject, Identifiable {
    @Dependency(Measurements.self) private var measurements
    @Dependency(NoMeasurementWarningState.self) private var warningState

    @DeviceState(\.id) var id: UUID
    @DeviceState(\.name) var name: String?
    @DeviceState(\.state) var state: PeripheralState
    
    // @Service var deviceInformation = DeviceInformationService()
    // @Service var batteryService = BatteryService()
    // @Service var coreTemperatureService = CoreTemperatureService()
    @Service var skinTemperatureService = SkinTemperatureService()
    
    @DeviceAction(\.connect) var connect
    @DeviceAction(\.disconnect) var disconnect
        
    required init() {}
    
    @MainActor
    func configure() {
        skinTemperatureService.$skinTemperature.onChange { [weak self] skintemperature in
            guard let self = self, !skintemperature.isEmpty else {
                print("No skin temperature data received.")
                return
            }

            // Debug: Print raw data in hex format
            print("Raw Skin Temperature Data (Hex):", skintemperature.map { String(format: "%02X", $0) }.joined(separator: " "))

            // Decode temperature from Data
            if let measurement = SkinTemperatureMeasurement(from: skintemperature) {
                print("Decoded Skin Temperature: \(String(format: "%.2f", measurement.temperature)) \(measurement.unit)")
                await self.handleNewMeasurement(measurement)
            } else {
                print("No valid skin temperature detected. Sensor might be off-body or not initialized.")
                await self.handleNoMeasurement()
            }
        }
    }
    @MainActor
    private func handleNewMeasurement(_ measurement: SkinTemperatureMeasurement) async {
        warningState.isActive = false
        await measurements.recordNewMeasurement(measurement)
    }
    
    @MainActor
    private func handleNoMeasurement() async {
        print("No temperature detected. Sensor might be off-body or waiting for a valid reading.")
        warningState.isActive = true   // This will be used to trigger UI warning
    }
}
