<!--

This source file is part of the NeutroFeverGuard based on the Stanford Spezi Template Application project

SPDX-FileCopyrightText: 2025 Stanford University

SPDX-License-Identifier: MIT

-->

# Working with CORE Sensor - Bluetooth Connection - NeutroFeverGuard
This file explains how bluetooth connection with CORE Sensor work in NeutroFeverGuard.

Back to [README](../README.md).

## CORE Sensor and its related Specifications
Core Body Temperature Sensor a non-invasive, wearable sensor that can monitor skin and core body temperature continuously. This sensor follows BLE and ANT protocols and they have documentation on their specs [here](https://github.com/CoreBodyTemp/CoreBodyTemp/blob/main/CORE%20Connectivity%20Implementation%20Notes.pdf). In our code, we used Health Thermometer Service that measures skin temperature, so following code BUUIDs and characteristics might need to be customized for your use case and functionalities.

## Discovery & Connection
First, we need to be able to scan for Bluetooth devices, discover our CORE Sensor and connect. As you might guess, at any point of time, there are hundreds of bluetooth devices around; and we don't want to overload user with all of these devices.

We add this snipped to our delegate to initialize the bluetooth module and discover only the "advertised service", so that we return only CORE Sensor. 

```swift
    Bluetooth {
        Discover(CoreSensor.self, by: .advertisedService("180A"))
    }
```
> [!TIP]  
> Where did we learn this service ID number? We used [LightBlue app](https://apps.apple.com/us/app/lightblue/id557428110) and the sensor specs provided above.


## Reading and Decoding Data
We subscribed to the Health Thermometer Service(Skin Temperature Service in the code), to receive data when sensor captured any.

```swift
// This is service provided by the CORE Sensor, used spec doc and LightBlue app to learn about IDs below.
struct SkinTemperatureService: BluetoothService {
    static let id: BTUUID = "1809"
    
    @Characteristic(id: "2A1C", notify: true) var skinTemperature: Data?
}
// notify means that everytime there is new data, we will receive, we are subscribed.
```
The data that the sensor sends is not directly in human-readable temperature format. The specs detail that this service uses a 5-byte payload in IEEE 11073 format. So, we need to decode it to convert into temperature value. See our detailed code for decoding [here](https://github.com/CS342/2025-NeutroFeverGuard/blob/main/NeutroFeverGuard/BluetoothRelated/MeasurementType.swift), we do this when we create a Skin Temperature Measurement Type.

```swift
final class CoreSensor: BluetoothDevice, @unchecked Sendable, ObservableObject, Identifiable {
    @Dependency(Measurements.self) private var measurements
    @Dependency(NoMeasurementWarningState.self) private var warningState

    @DeviceState(\.id) var id: UUID
    @DeviceState(\.name) var name: String?
    @DeviceState(\.state) var state: PeripheralState
    
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
```
As can be seen above, we also handle the cases where the Sensor is connected but the temperature values are NaN values. To see how we use these functions and update UI, see our [code](https://github.com/CS342/2025-NeutroFeverGuard/blob/main/NeutroFeverGuard/BluetoothRelated/BluetoothView.swift).

## Pushing Data into HealthKit

After we read and decode, next step is converting the temperature value in HealthKit-acceptable body temperature format and pushing our data to HealthKit. After pushing it to HealthKit, our background checking will read it back and push it to Firebase.

```swift
func recordNewMeasurement(_ measurement: SkinTemperatureMeasurement) async {
        let timestamp = measurement.timestamp ?? Date() // if we dont get timestamp from the sensor, then we need to generate.

        recordedTemperatures.append(measurement)
        print("New Temperature Recorded: \(measurement.temperature) \(measurement.unit == .celsius ? "°C" : "°F") at \(timestamp)")
        
        do {
            // Request HealthKit authorization (Temporarily placed to make sure data is pushed on iphone, remove while pushing to main)
            // try await healthKitService.requestAuthorization()
            
            // Convert measurement into HealthKit-compatible TemperatureEntry
            let temperatureEntry = try TemperatureEntry(
                date: timestamp,
                value: Double(measurement.temperature),
                unit: measurement.unit == .celsius ? .celsius : .fahrenheit
            )
            
            // Save to HealthKit
            try await healthKitService.saveTemperature(temperatureEntry)
            print("Core Sensor Skin Temperature successfully saved to HealthKit.")
        } catch let error as DataError {
            print("HealthKit save error: \(error.errorMessage)")
        } catch {
            print("Unexpected error saving to HealthKit: \(error)")
        }
    }
```

> [!TIP]  
> We built these functions on top of **SpeziBluetooth**. In addition our code and documentation, check out their [documentation](https://swiftpackageindex.com/StanfordSpezi/SpeziBluetooth/main/documentation/spezibluetooth).

Now you know how bluetooth connection with CORE Sensor work in NeutroFeverGuard! Welcome back to [README](../README.md).