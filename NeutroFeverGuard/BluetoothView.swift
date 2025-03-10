//
// This source file is part of the NeutroFeverGuard based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SpeziBluetooth
import SwiftUI


struct BluetoothView: View {
    @Environment(Bluetooth.self) var bluetooth
    @Environment(CoreSensor.self) var myDevice: CoreSensor?


    var body: some View {
        List {
            if let myDevice {
                Section {
                    Text("Device")
                    Spacer()
                    Text("\(myDevice.state.description)")
                }
            }


            Section {
                ForEach(bluetooth.nearbyDevices(for: CoreSensor.self), id: \.id) { device in
                    Text("\(device.name ?? "unknown")")
                }
            } header: {
                HStack {
                    Text("Devices")
                        .padding(.trailing, 10)
                    if bluetooth.isScanning {
                        ProgressView()
                    }
                }
            }
        }
        .scanNearbyDevices(with: bluetooth, autoConnect: true)
    }
}
