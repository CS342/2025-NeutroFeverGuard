//
// This source file is part of the NeutroFeverGuard based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import XCTest

final class BluetoothViewUITests: XCTestCase {
    @MainActor
    override func setUp() async throws {
        continueAfterFailure = false

        let app = XCUIApplication()
        app.launchArguments = ["--skipOnboarding"]
        app.deleteAndLaunch(withSpringboardAppName: "NeutroFeverGuard")
    }
    @MainActor
    func testNoMeasurementWarningAppears() throws {
        let app = XCUIApplication()
        // Ensure app launches
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 5))

        // Simulate no measurement warning by toggling the state
        let warningText = "No valid temperature detected. Ensure the sensor is placed correctly."

        // Check if the warning is displayed
        let warningElement = app.staticTexts[warningText]
        XCTAssertTrue(warningElement.exists, "No Measurement Warning should be visible")
    }
    @MainActor
    func testBluetoothOffMessageAppears() throws {
        let app = XCUIApplication()
        // Check for Bluetooth Off Message
        let bluetoothWarning = app.staticTexts["Please turn on your Bluetooth and CORE sensor."]
        XCTAssertTrue(bluetoothWarning.exists, "Bluetooth warning should appear when Bluetooth is off")
    }
}
