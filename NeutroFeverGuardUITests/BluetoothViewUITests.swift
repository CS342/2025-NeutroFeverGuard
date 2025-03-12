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
        app.launch()
    }
    
    @MainActor
    func testBluetoothView() throws {
        let app = XCUIApplication()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 5))
        XCTAssertTrue(app.tabBars["Tab Bar"].buttons["Connect"].waitForExistence(timeout: 2))
        app.tabBars["Tab Bar"].buttons["Connect"].tap()
        
        let bluetoothWarning = app.staticTexts["Please turn on your Bluetooth and CORE sensor."]
        XCTAssertTrue(bluetoothWarning.exists, "Bluetooth warning should appear when Bluetooth is off")
        
        let nearbyDevices = app.staticTexts["NEARBY DEVICES"]
        XCTAssertTrue(nearbyDevices.exists, "Nearby Devices section should appear in the Bluetooth view.")
        
        let connectedDevices = app.staticTexts["CONNECTED DEVICES"]
        XCTAssertTrue(connectedDevices.exists, "Connected Devices section should appear in the Bluetooth view.")
    }
    
    @MainActor
    func testManualDataEntryButton() throws {
        let app = XCUIApplication()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 5))
        XCTAssertTrue(app.tabBars["Tab Bar"].buttons["Connect"].waitForExistence(timeout: 2))
        app.tabBars["Tab Bar"].buttons["Connect"].tap()
        
        XCTAssertTrue(app.buttons["Enter Data Manually"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Enter Data Manually"].isEnabled)
        app.buttons["Enter Data Manually"].tap()

        XCTAssertTrue(app.staticTexts["What data would you like to add?"].waitForExistence(timeout: 5))
    }
}
