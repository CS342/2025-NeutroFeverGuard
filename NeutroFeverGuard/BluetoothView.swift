//
//  BluetoothView.swift
//  NeutroFeverGuard
//
//  Created by Merve Cerit on 3/9/25.
//

import SpeziBluetooth
import SwiftUI


struct BluetoothView: View {
    @Environment(Bluetooth.self)
    var bluetooth
    @Environment(CoreSensor.self)
    var myDevice: CoreSensor?


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
                ForEach(bluetooth.nearbyDevices(for: MyDevice.self), id: \.id) { device in
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
