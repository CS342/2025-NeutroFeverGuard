//
// This source file is part of the NeutroFeverGuard based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//
import XCTest
import XCTestExtensions


class HKVisualizationHKTests: XCTestCase {
    @MainActor
    override func setUp() async throws {
        continueAfterFailure = false
        
        let app = XCUIApplication()
        app.launchArguments = ["--skipOnboarding"]
        app.deleteAndLaunch(withSpringboardAppName: "NeutroFeverGuard")
    }
    
    @MainActor
    func testHealthKitView() throws {
        let app = XCUIApplication()
        
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))
        
        XCTAssertTrue(app.tabBars["Tab Bar"].buttons["Dashboard"].waitForExistence(timeout: 2))
        app.tabBars["Tab Bar"].buttons["Dashboard"].tap()
        try app.handleHealthKitAuthorization()
        
        XCTAssertTrue(app.staticTexts["No heart rate data available."].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["No body temperature data available."].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["No oxygen saturation data available."].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["No neutrophil count data available."].waitForExistence(timeout: 2))
    }
}
