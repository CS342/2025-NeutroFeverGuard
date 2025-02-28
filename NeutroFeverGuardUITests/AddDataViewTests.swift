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
    func testDataTypesExist() throws {
        let app = XCUIApplication()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))

        XCTAssertTrue(app.tabBars["Tab Bar"].buttons["Add Data"].waitForExistence(timeout: 5))
        app.tabBars["Tab Bar"].buttons["Add Data"].tap()

        let dataTypes = [
            "Temperature", "Heart Rate", "Oxygen Saturation",
            "Blood Pressure", "Lab Results", "Medication"
        ]

        for type in dataTypes {
            XCTAssertTrue(app.staticTexts[type].waitForExistence(timeout: 5), "\(type) should be visible")
        }
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
    }
}
