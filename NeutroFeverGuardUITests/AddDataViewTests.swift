//
// This source file is part of the NeutroFeverGuard based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import XCTest
import XCTestExtensions


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
        
        XCTAssertTrue(app.tabBars["Tab Bar"].buttons["Add Data"].waitForExistence(timeout: 2))
        app.tabBars["Tab Bar"].buttons["Add Data"].tap()
        
        XCTAssertTrue(app.staticTexts["What data would you like to add?"].waitForExistence(timeout: 2))
        
        XCTAssertTrue(app.staticTexts["Heart Rate"].waitForExistence(timeout: 2))
        app.staticTexts["Heart Rate"].tap()
        
        XCTAssertTrue(app.navigationBars["Heart Rate"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["Rate (bpm)"].waitForExistence(timeout: 2))
        
        let heartRateField = app.textFields.element
        XCTAssertTrue(heartRateField.waitForExistence(timeout: 2))
        heartRateField.tap()
        heartRateField.typeText("75")
        
        XCTAssertTrue(app.buttons["Add"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["Add"].isEnabled)
        app.buttons["Add"].tap()
        
        XCTAssertTrue(app.staticTexts["What data would you like to add?"].waitForExistence(timeout: 2))
    }
    
    @MainActor
    func testTemperatureDataInput() throws {
        let app = XCUIApplication()
        
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))
        
        XCTAssertTrue(app.tabBars["Tab Bar"].buttons["Add Data"].waitForExistence(timeout: 2))
        app.tabBars["Tab Bar"].buttons["Add Data"].tap()
        
        XCTAssertTrue(app.staticTexts["Temperature"].waitForExistence(timeout: 2))
        app.staticTexts["Temperature"].tap()
        
        XCTAssertTrue(app.navigationBars["Temperature"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["Temperature"].waitForExistence(timeout: 2))
        
        let temperatureField = app.textFields["value"]
        XCTAssertTrue(temperatureField.waitForExistence(timeout: 2))
        temperatureField.tap()
        temperatureField.typeText("98.6")
        
        let unitPicker = app.pickers.element
        XCTAssertTrue(app.buttons["°F"].waitForExistence(timeout: 2))
        app.buttons["°F"].tap()
        XCTAssertTrue(app.staticTexts["°F"].waitForExistence(timeout: 2))
        app.staticTexts["°F"].tap()
        
        XCTAssertTrue(app.buttons["Add"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["Add"].isEnabled)
        app.buttons["Add"].tap()
        
        XCTAssertTrue(app.staticTexts["What data would you like to add?"].waitForExistence(timeout: 2))
    }
    
    @MainActor
    func testBloodPressureDataInput() throws {
        let app = XCUIApplication()
        
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))
        
        XCTAssertTrue(app.tabBars["Tab Bar"].buttons["Add Data"].waitForExistence(timeout: 2))
        app.tabBars["Tab Bar"].buttons["Add Data"].tap()
        
        XCTAssertTrue(app.staticTexts["Blood Pressure"].waitForExistence(timeout: 2))
        app.staticTexts["Blood Pressure"].tap()
        
        XCTAssertTrue(app.navigationBars["Blood Pressure"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["Systolic (mmHg)"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["Diastolic (mmHg)"].waitForExistence(timeout: 2))
        
        let textFields = app.textFields.allElementsBoundByIndex
        XCTAssertEqual(textFields.count, 2)
        
        textFields[0].tap()
        textFields[0].typeText("120")
        
        textFields[1].tap()
        textFields[1].typeText("80")
        
        XCTAssertTrue(app.buttons["Add"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["Add"].isEnabled)
        app.buttons["Add"].tap()
        
        XCTAssertTrue(app.staticTexts["What data would you like to add?"].waitForExistence(timeout: 2))
    }
    
    @MainActor
    func testLabResultsDataInput() throws {
        let app = XCUIApplication()
        
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))
        
        XCTAssertTrue(app.tabBars["Tab Bar"].buttons["Add Data"].waitForExistence(timeout: 2))
        app.tabBars["Tab Bar"].buttons["Add Data"].tap()
        
        XCTAssertTrue(app.staticTexts["Lab Results"].waitForExistence(timeout: 2))
        app.staticTexts["Lab Results"].tap()
        
        XCTAssertTrue(app.navigationBars["Lab Results"].waitForExistence(timeout: 2))
        
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
            XCTAssertTrue(testRow.waitForExistence(timeout: 2))
            
            let textField = app.cells.containing(.staticText, identifier: test).textFields.firstMatch
            textField.tap()
            textField.typeText(labValues[index])
        }
        
        XCTAssertTrue(app.buttons["Add"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["Add"].isEnabled)
        app.buttons["Add"].tap()
        
        XCTAssertTrue(app.staticTexts["What data would you like to add?"].waitForExistence(timeout: 2))
    }
    
    @MainActor
    func testCancelDataInput() throws {
        let app = XCUIApplication()
        
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))
        
        XCTAssertTrue(app.tabBars["Tab Bar"].buttons["Add Data"].waitForExistence(timeout: 2))
        app.tabBars["Tab Bar"].buttons["Add Data"].tap()
        
        XCTAssertTrue(app.staticTexts["Heart Rate"].waitForExistence(timeout: 2))
        app.staticTexts["Heart Rate"].tap()
        
        XCTAssertTrue(app.navigationBars["Heart Rate"].waitForExistence(timeout: 2))
        
        XCTAssertTrue(app.buttons["Cancel"].waitForExistence(timeout: 2))
        app.buttons["Cancel"].tap()
        
        XCTAssertTrue(app.staticTexts["What data would you like to add?"].waitForExistence(timeout: 2))
    }
}
