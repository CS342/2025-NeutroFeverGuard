//
// This source file is part of the NeutroFeverGuard based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import XCTest
import XCTestExtensions

class HKVisualizationTestsNoData: XCTestCase {
    @MainActor
    override func setUp() async throws {
        continueAfterFailure = false
        
        let app = XCUIApplication()
        app.launchArguments = ["--skipOnboarding"]
        app.deleteAndLaunch(withSpringboardAppName: "NeutroFeverGuard")
    }
    
    @MainActor
    func testNoData() throws {
        let app = XCUIApplication()
        
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))
        
        XCTAssertTrue(app.tabBars["Tab Bar"].buttons["Dashboard"].waitForExistence(timeout: 2))
        app.tabBars["Tab Bar"].buttons["Dashboard"].tap()
        try app.handleHealthKitAuthorization()
        
        let noHeartRate = app.staticTexts["No heart rate data avaiable."]
        XCTAssertTrue(noHeartRate.waitForExistence(timeout: 5), "Heart Rate chart title should exist")
        let noTemp = app.staticTexts["No body temperature data avaiable."]
        XCTAssertTrue(noTemp.waitForExistence(timeout: 5), "Heart Rate chart title should exist")
        let noOxygen = app.staticTexts["No oxygen saturation data avaiable."]
        XCTAssertTrue(noOxygen.waitForExistence(timeout: 5), "Heart Rate chart title should exist")
    }
}
