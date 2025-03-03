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


class AddDataViewTests: XCTestCase {
    @MainActor
    override func setUp() async throws {
        continueAfterFailure = false
        
        let app = XCUIApplication()
        app.launchArguments = ["--skipOnboarding"]
        app.deleteAndLaunch(withSpringboardAppName: "NeutroFeverGuard")
    }
    
    @MainActor
    func testHeartRateDataInput() throws {
        let app = XCUIApplication()
        
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))
        
        XCTAssertTrue(app.tabBars["Tab Bar"].buttons["Add Data"].waitForExistence(timeout: 5))
        app.tabBars["Tab Bar"].buttons["Add Data"].tap()
        
        XCTAssertTrue(app.staticTexts["What data would you like to add?"].waitForExistence(timeout: 5))
        
        XCTAssertTrue(app.staticTexts["Heart Rate"].waitForExistence(timeout: 5))
        app.staticTexts["Heart Rate"].tap()
        
        XCTAssertTrue(app.navigationBars["Heart Rate"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Rate (bpm)"].waitForExistence(timeout: 5))
        
        let heartRateField = app.textFields.element
        XCTAssertTrue(heartRateField.waitForExistence(timeout: 5))
        heartRateField.tap()
        heartRateField.typeText("75")
        
        XCTAssertTrue(app.buttons["Add"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Add"].isEnabled)
        app.buttons["Add"].tap()
        try app.handleHealthKitAuthorization()
        XCTAssertTrue(app.staticTexts["What data would you like to add?"].waitForExistence(timeout: 5))
        
        // invalid input
        XCTAssertTrue(app.staticTexts["Heart Rate"].waitForExistence(timeout: 5))
        app.staticTexts["Heart Rate"].tap()
        
        let heartRateField2 = app.textFields.element
        XCTAssertTrue(heartRateField2.waitForExistence(timeout: 5))
        heartRateField2.tap()
        
        XCTAssertTrue(app.buttons["Add"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["Add"].isEnabled)
        
        heartRateField.typeText("invalid")
        XCTAssertTrue(app.buttons["Add"].waitForExistence(timeout: 5))
        app.buttons["Add"].tap()
        XCTAssertTrue(app.staticTexts["Error"].waitForExistence(timeout: 5))
    }
    
    @MainActor
    func testTemperatureDataInput() throws {
        let app = XCUIApplication()
        
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))
        
        XCTAssertTrue(app.tabBars["Tab Bar"].buttons["Add Data"].waitForExistence(timeout: 5))
        app.tabBars["Tab Bar"].buttons["Add Data"].tap()
        
        XCTAssertTrue(app.staticTexts["Temperature"].waitForExistence(timeout: 5))
        app.staticTexts["Temperature"].tap()
        
        XCTAssertTrue(app.navigationBars["Temperature"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Temperature"].waitForExistence(timeout: 5))
        
        let temperatureField = app.textFields["value"]
        XCTAssertTrue(temperatureField.waitForExistence(timeout: 5))
        temperatureField.tap()
        temperatureField.typeText("98.6")
        
        XCTAssertTrue(app.buttons["°F"].waitForExistence(timeout: 5))
        app.buttons["°F"].tap()
        XCTAssertTrue(app.staticTexts["°F"].waitForExistence(timeout: 5))
        app.staticTexts["°F"].tap()
        
        XCTAssertTrue(app.buttons["Add"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Add"].isEnabled)
        app.buttons["Add"].tap()
        try app.handleHealthKitAuthorization()
        XCTAssertTrue(app.staticTexts["What data would you like to add?"].waitForExistence(timeout: 5))
        
        // invalid input
        XCTAssertTrue(app.staticTexts["Temperature"].waitForExistence(timeout: 5))
        app.staticTexts["Temperature"].tap()
        
        XCTAssertTrue(app.buttons["Add"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["Add"].isEnabled)
        
        let temperatureField2 = app.textFields["value"]
        XCTAssertTrue(temperatureField2.waitForExistence(timeout: 5))
        temperatureField2.tap()
        temperatureField2.typeText("invalid")
        
        XCTAssertTrue(app.buttons["Add"].waitForExistence(timeout: 5))
        app.buttons["Add"].tap()
        XCTAssertTrue(app.staticTexts["Error"].waitForExistence(timeout: 5))
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
        
        textFields[0].tap()
        textFields[0].typeText("120")
        
        textFields[1].tap()
        textFields[1].typeText("80")
        
        XCTAssertTrue(app.buttons["Add"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Add"].isEnabled)
        app.buttons["Add"].tap()
        try app.handleHealthKitAuthorization()
        XCTAssertTrue(app.staticTexts["What data would you like to add?"].waitForExistence(timeout: 5))
        
        // invalid input
        XCTAssertTrue(app.staticTexts["Blood Pressure"].waitForExistence(timeout: 5))
        app.staticTexts["Blood Pressure"].tap()
        
        XCTAssertTrue(app.buttons["Add"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["Add"].isEnabled)
        
        let textFields2 = app.textFields.allElementsBoundByIndex
        textFields2[0].tap()
        textFields2[0].typeText("120")
        
        textFields2[1].tap()
        textFields2[1].typeText("invalid")
        
        app.buttons["Add"].tap()
        XCTAssertTrue(app.staticTexts["Error"].waitForExistence(timeout: 5))
    }
    
    @MainActor
    func testOxygenSaturationDataInput() throws {
        let app = XCUIApplication()
        
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))
        
        XCTAssertTrue(app.tabBars["Tab Bar"].buttons["Add Data"].waitForExistence(timeout: 5))
        app.tabBars["Tab Bar"].buttons["Add Data"].tap()
        
        XCTAssertTrue(app.staticTexts["Oxygen Saturation"].waitForExistence(timeout: 5))
        app.staticTexts["Oxygen Saturation"].tap()
        
        XCTAssertTrue(app.navigationBars["Oxygen Saturation"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Percentage (%)"].waitForExistence(timeout: 5))
        
        let textFields = app.textFields.allElementsBoundByIndex
        XCTAssertEqual(textFields.count, 1)
        
        textFields[0].tap()
        textFields[0].typeText("99")
        
        XCTAssertTrue(app.buttons["Add"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Add"].isEnabled)
        app.buttons["Add"].tap()
        try app.handleHealthKitAuthorization()
        XCTAssertTrue(app.staticTexts["What data would you like to add?"].waitForExistence(timeout: 5))
        
        // invalid input
        XCTAssertTrue(app.staticTexts["Oxygen Saturation"].waitForExistence(timeout: 5))
        app.staticTexts["Oxygen Saturation"].tap()
        
        XCTAssertTrue(app.buttons["Add"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["Add"].isEnabled)
        
        let textFields2 = app.textFields.allElementsBoundByIndex
        textFields2[0].tap()
        textFields2[0].typeText("invalid")
        
        XCTAssertTrue(app.buttons["Add"].waitForExistence(timeout: 5))
        app.buttons["Add"].tap()
        XCTAssertTrue(app.staticTexts["Error"].waitForExistence(timeout: 5))
    }
    
    @MainActor
    func testLabResultsDataInput() throws {
        let app = XCUIApplication()
        
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))
        
        XCTAssertTrue(app.tabBars["Tab Bar"].buttons["Add Data"].waitForExistence(timeout: 5))
        app.tabBars["Tab Bar"].buttons["Add Data"].tap()
        
        XCTAssertTrue(app.staticTexts["Lab Results"].waitForExistence(timeout: 5))
        app.staticTexts["Lab Results"].tap()
        
        XCTAssertTrue(app.navigationBars["Lab Results"].waitForExistence(timeout: 5))
        
        let labTests = [
            "White Blood Cell Count", "Hemoglobin", "Platelet Count", "% Neutrophils",
            "% Lymphocytes", "% Monocytes", "% Eosinophils", "% Basophils", "% Blasts"
        ]
        let labValues = [
            "5000", "14.2", "250000",
            "60", "30", "5", "3", "1", "0"
        ]
        
        for (index, test) in labTests.enumerated() {
            let testRow = app.staticTexts[test]
            XCTAssertTrue(testRow.waitForExistence(timeout: 5))
            
            let textField = app.cells.containing(.staticText, identifier: test).textFields.firstMatch
            textField.tap()
            textField.typeText(labValues[index])
        }
        
        XCTAssertTrue(app.buttons["Add"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Add"].isEnabled)
        app.buttons["Add"].tap()
        try app.handleHealthKitAuthorization()
        XCTAssertTrue(app.staticTexts["What data would you like to add?"].waitForExistence(timeout: 5))
        
        // invalid input
        XCTAssertTrue(app.staticTexts["Lab Results"].waitForExistence(timeout: 5))
        app.staticTexts["Lab Results"].tap()
        
        XCTAssertTrue(app.buttons["Add"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["Add"].isEnabled)

        let labValues2 = [
            "invalid", "14.2", "250000", "60", "30", "5", "3", "1", "0"
        ]
        
        for (index, test) in labTests.enumerated() {
            let testRow = app.staticTexts[test]
            XCTAssertTrue(testRow.waitForExistence(timeout: 5))
            
            let textField = app.cells.containing(.staticText, identifier: test).textFields.firstMatch
            textField.tap()
            textField.typeText(labValues2[index])
        }
        
        XCTAssertTrue(app.buttons["Add"].waitForExistence(timeout: 5))
        app.buttons["Add"].tap()
        XCTAssertTrue(app.staticTexts["Error"].waitForExistence(timeout: 5))
    }
    
    @MainActor
    func testCancelDataInput() throws {
        let app = XCUIApplication()
        
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))
        
        XCTAssertTrue(app.tabBars["Tab Bar"].buttons["Add Data"].waitForExistence(timeout: 5))
        app.tabBars["Tab Bar"].buttons["Add Data"].tap()
        
        XCTAssertTrue(app.staticTexts["Heart Rate"].waitForExistence(timeout: 5))
        app.staticTexts["Heart Rate"].tap()
        
        XCTAssertTrue(app.navigationBars["Heart Rate"].waitForExistence(timeout: 5))
        
        XCTAssertTrue(app.buttons["Cancel"].waitForExistence(timeout: 5))
        app.buttons["Cancel"].tap()
        try app.handleHealthKitAuthorization()
        XCTAssertTrue(app.staticTexts["What data would you like to add?"].waitForExistence(timeout: 5))
    }
}
