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
    
    @Characteristic(id: "2A1C", notify: true) var skinTemperature: String?
}

final class CoreSensor: BluetoothDevice, @unchecked Sendable, Identifiable {
    @Dependency(Measurements.self) private var measurements

    @DeviceState(\.id) var id: UUID
    @DeviceState(\.name) var name: String?
    @DeviceState(\.state) var state: PeripheralState
    
    @Service var deviceInformation = DeviceInformationService()
    // @Service var batteryService = BatteryService()
    // @Service var coreTemperatureService = CoreTemperatureService()
    @Service var skinTemperatureService = SkinTemperatureService()
    
    @DeviceAction(\.connect) var connect
    @DeviceAction(\.disconnect) var disconnect
    
    required init() {}
    
    func autoConnect(bluetooth: Bluetooth) {
        guard let storedDeviceID = loadPreviousDeviceID() else {
            return
        }

        Task {
            guard let device = await bluetooth.retrieveDevice(for: storedDeviceID, as: CoreSensor.self) else {
                print("No previously connected device found or it's out of range.")
                return
            }
            
            do {
                try await device.connect()
                print("Successfully connected to previously paired device: \(device.name ?? "Unknown")")
            } catch {
                print("Failed to connect to previously paired device: \(error.localizedDescription)")
            }
        }
    }

    private func savePreviousDeviceID(_ id: UUID) {
        UserDefaults.standard.set(id.uuidString, forKey: "LastConnectedDeviceID")
    }

    private func loadPreviousDeviceID() -> UUID? {
        guard let uuidString = UserDefaults.standard.string(forKey: "LastConnectedDeviceID") else {
            return nil
        }
        return UUID(uuidString: uuidString)
    }
    

    func configure() {
        skinTemperatureService.$skinTemperature.onChange { [weak self] skintemperature in
            guard let self = self else {
                return
            }

            if skintemperature.isEmpty == false {
                print("Skin Temperature: \(skintemperature) °C")
                // let measurement = SkinTemperatureMeasurement(temperature: skintemperature, unit: .celsius)
                // self.handleNewMeasurement(measurement)
            } else {
                print("No skin temperature data received.")
            }
        }
    }

    private func handleNewMeasurement(_ measurement: SkinTemperatureMeasurement) {
        measurements.recordNewMeasurement(measurement)
    }
}
