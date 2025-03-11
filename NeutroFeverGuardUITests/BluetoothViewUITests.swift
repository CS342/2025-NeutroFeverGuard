//
// This source file is part of the NeutroFeverGuard based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import XCTest

final class BluetoothViewUITests: XCTestCase {
    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false // Stops test execution if a failure occurs
        app.launch()
    }

    func testNoMeasurementWarningAppears() throws {
        // Ensure app launches
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 5))

        // Simulate no measurement warning by toggling the state
        let warningText = "No valid temperature detected. Ensure the sensor is placed correctly."

        // Check if the warning is displayed
        let warningElement = app.staticTexts[warningText]
        XCTAssertTrue(warningElement.exists, "No Measurement Warning should be visible")
    }

    func testBluetoothOffMessageAppears() throws {
        // Check for Bluetooth Off Message
        let bluetoothWarning = app.staticTexts["Please turn on your Bluetooth."]
        XCTAssertTrue(bluetoothWarning.exists, "Bluetooth warning should appear when Bluetooth is off")
    }
}
