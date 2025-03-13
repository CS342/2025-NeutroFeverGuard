//
// This source file is part of the NeutroFeverGuard based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import XCTest
import XCTestExtensions
import XCTHealthKit

class BloodPressureTests: XCTestCase {
    @MainActor
    override func setUp() async throws {
        continueAfterFailure = false
        
        let app = XCUIApplication()
        app.launchArguments = ["--skipOnboarding"]
        app.deleteAndLaunch(withSpringboardAppName: "NeutroFeverGuard")
    }
    
    @MainActor
    func testBloodPressureDataInput() throws {
        let app = XCUIApplication()
        
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))
        
        XCTAssertTrue(app.tabBars["Tab Bar"].buttons["Add Data"].waitForExistence(timeout: 5))
        app.tabBars["Tab Bar"].buttons["Add Data"].tap()
        
        XCTAssertTrue(app.staticTexts["Blood Pressure"].waitForExistence(timeout: 5))
        app.staticTexts["Blood Pressure"].tap()
        
        XCTAssertTrue(app.navigationBars["Blood Pressure"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Systolic (mmHg)"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Diastolic (mmHg)"].waitForExistence(timeout: 5))
        
        let textFields = app.textFields.allElementsBoundByIndex
        XCTAssertEqual(textFields.count, 2)
        
        let systolicField = textFields[0].coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        systolicField.tap()
        textFields[0].typeText("120")

        let diastolicField = textFields[1].coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        diastolicField.tap()
        textFields[1].typeText("80")
        
        XCTAssertTrue(app.buttons["Add"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Add"].isEnabled)
        app.buttons["Add"].tap()
        try app.handleHealthKitAuthorization()
        if app.buttons["Add"].waitForExistence(timeout: 20) {
            app.buttons["Add"].tap()
            try app.handleHealthKitAuthorization()
        }
        XCTAssertTrue(app.staticTexts["What data would you like to add?"].waitForExistence(timeout: 5))
        
        // invalid input
        XCTAssertTrue(app.staticTexts["Blood Pressure"].waitForExistence(timeout: 5))
        app.staticTexts["Blood Pressure"].tap()
        
        XCTAssertTrue(app.buttons["Add"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["Add"].isEnabled)
        
        let textFields2 = app.textFields.allElementsBoundByIndex
        
        let systolicField2 = textFields2[0].coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        systolicField2.tap()
        textFields2[0].typeText("120")

        let diastolicField2 = textFields2[1].coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        diastolicField2.tap()
        textFields2[1].typeText("invalid")
        
        app.buttons["Add"].tap()
        if app.buttons["Add"].waitForExistence(timeout: 20) {
            app.buttons["Add"].tap()
            try app.handleHealthKitAuthorization()
        }
        XCTAssertTrue(app.staticTexts["Error"].waitForExistence(timeout: 5))
    }
}
