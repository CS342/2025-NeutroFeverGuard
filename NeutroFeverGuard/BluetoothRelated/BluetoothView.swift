//
// This source file is part of the NeutroFeverGuard based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//
import SpeziAccount
import SpeziBluetooth
import SwiftUI

struct MyDeviceSection: View {
    let myDevice: CoreSensor
    let handleDeviceConnection: (CoreSensor) -> Void

    var body: some View {
        Section(header: Text("My Device").font(.headline)) {
            HStack {
                VStack(alignment: .leading) {
                    Text("State:").font(.subheadline).foregroundColor(.secondary)
                    Text(myDevice.state.description)
                        .font(.body)
                        .bold()
                        .foregroundColor(myDevice.state == .connected ? .green : .red)
                }
                Spacer()
                Button(action: { handleDeviceConnection(myDevice) }) {
                    Label(
                        myDevice.state == .connected ? "Disconnect" : "Connect",
                        systemImage: myDevice.state == .connected ? "wifi" : "wifi.slash"
                    )
                        .foregroundColor(.blue)
                }
            }
        }
    }
}

struct NearbyDevicesSection: View {
    let bluetooth: Bluetooth
    let connectToDevice: (CoreSensor) -> Void

    var body: some View {
        Section(header: devicesHeader) {
            ForEach(bluetooth.nearbyDevices(for: CoreSensor.self), id: \.id) { device in
                HStack {
                    Image(systemName: "sensor.tag.radiowaves.forward") // swiftlint:disable:this accessibility_label_for_image
                        .foregroundColor(.blue)
                    Text(device.name ?? "Unknown Device")
                    Spacer()
                    Button(action: { connectToDevice(device) }) {
                        Label("Connect", systemImage: "link")
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
            }
        }
    }

    private var devicesHeader: some View {
        HStack {
            Text("Nearby Devices").font(.headline)
            if bluetooth.isScanning {
                ProgressView().scaleEffect(0.8)
            }
        }
    }
}

struct ConnectedDevicesSection: View {
    let connectedDevices: ConnectedDevices<CoreSensor>
    let connectToDevice: (CoreSensor) -> Void

    var body: some View {
        Section(header: Text("Connected Devices").font(.headline)) {
            ForEach(connectedDevices) { device in
                HStack {
                    Image( systemName: device.state == .connected ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(device.state == .connected ? .green : .red)
                        .accessibilityHidden(true)
                    Text(device.name ?? "Unknown Device")
                    Spacer()
                    if device.state != .connected {
                        Button(action: { connectToDevice(device) }) {
                            Label("Reconnect", systemImage: "arrow.triangle.2.circlepath")
                        }
                        .foregroundColor(.blue)
                    }
                }
            }
        }
    }
}
struct BluetoothOffMessage: View {
    let onManualEntry: () -> Void

    var body: some View {
        Section {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.yellow)
                        .accessibilityHidden(true)
                    Text("Please turn on your Bluetooth and CORE sensor.")
                        .font(.headline)
                        .foregroundColor(.red)
                }

                Text("If you don’t have a sensor, you can manually enter your data.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Button(action: onManualEntry) {
                    Text("Enter Data Manually")
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
    }
}

struct NoMeasurementWarningView: View {
    var body: some View {
        Section {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.yellow)
                    .accessibilityHidden(true)
                Text("No valid temperature detected. Ensure the sensor is placed correctly.")
                    .foregroundColor(.red)
            }
        }
    }
}

struct BluetoothView: View {
    @Environment(Bluetooth.self) var bluetooth
    @Environment(CoreSensor.self) var myDevice: CoreSensor?
    @Environment(ConnectedDevices<CoreSensor>.self) var connectedDevices
    @Environment(Account.self) private var account: Account?
    @Environment(NoMeasurementWarningState.self) var warningState
    @Binding var selectedTab: HomeView.Tabs
    @Binding var presentingAccount: Bool
    @State private var showErrorAlert = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationStack {
            List {
                if bluetooth.nearbyDevices(for: CoreSensor.self).isEmpty {
                    BluetoothOffMessage {
                        selectedTab = .addData
                    }
                }
                if warningState.isActive {
                    NoMeasurementWarningView()
                }
                if let myDevice {
                    MyDeviceSection(myDevice: myDevice, handleDeviceConnection: handleDeviceConnection)
                }

                if connectedDevices.isEmpty {
                    NearbyDevicesSection(bluetooth: bluetooth, connectToDevice: connectToDevice)
                }

                ConnectedDevicesSection(connectedDevices: connectedDevices, connectToDevice: connectToDevice)
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Bluetooth Devices")
            .alert(isPresented: $showErrorAlert) {
                Alert(title: Text("Connection Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
            .onAppear {
                Task {
                    await bluetooth.powerOn()
                }
            }
            .scanNearbyDevices(with: bluetooth, autoConnect: true)
            .toolbar {
                if account != nil {
                    AccountButton(isPresented: $presentingAccount)
                }
            }
        }
    }

    init(presentingAccount: Binding<Bool>, selectedTab: Binding<HomeView.Tabs>) {
        self._presentingAccount = presentingAccount
        self._selectedTab = selectedTab
    }
    
    private func handleDeviceConnection(_ device: CoreSensor) {
        Task {
            do {
                if device.state == .connected {
                    await device.disconnect()
                } else {
                    try await device.connect()
                }
            } catch {
                showError(message: "Failed to connect to \(device.name ?? "device").")
            }
        }
    }

    private func connectToDevice(_ device: CoreSensor) {
        Task {
            do {
                try await device.connect()
            } catch {
                showError(message: "Could not connect to \(device.name ?? "device").")
            }
        }
    }

    private func showError(message: String) {
        errorMessage = message
        showErrorAlert = true
    }
}
