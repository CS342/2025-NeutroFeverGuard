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

// swiftlint:disable type_body_length
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
        let labValues = [ "5000", "14.2", "250000", "60", "30", "5", "3", "1", "0" ]
        
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

        let labValues2 = [ "invalid", "14.2", "250000", "60", "30", "5", "3", "1", "0" ]
        
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
    func testMedicationDataInput() throws {
        let app = XCUIApplication()
        
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))
        
        XCTAssertTrue(app.tabBars["Tab Bar"].buttons["Add Data"].waitForExistence(timeout: 5))
        app.tabBars["Tab Bar"].buttons["Add Data"].tap()
        
        XCTAssertTrue(app.staticTexts["Medication"].waitForExistence(timeout: 5))
        app.staticTexts["Medication"].tap()
        
        XCTAssertTrue(app.navigationBars["Medication"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Name"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Dose"].waitForExistence(timeout: 5))
        
        let nameField = app.textFields["Medication Name"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 5))
        nameField.tap()
        nameField.typeText("Aspirin")
        
        let doseField = app.textFields["Amount"]
        XCTAssertTrue(doseField.waitForExistence(timeout: 5))
        doseField.tap()
        doseField.typeText("100")
        
        XCTAssertTrue(app.buttons["mg"].waitForExistence(timeout: 5))
        app.buttons["mg"].tap()
        XCTAssertTrue(app.staticTexts["mg"].waitForExistence(timeout: 5))
        app.staticTexts["mg"].tap()
        
        XCTAssertTrue(app.buttons["Add"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Add"].isEnabled)
        app.buttons["Add"].tap()
        try app.handleHealthKitAuthorization()
        XCTAssertTrue(app.staticTexts["What data would you like to add?"].waitForExistence(timeout: 5))
        
        XCTAssertTrue(app.staticTexts["Medication"].waitForExistence(timeout: 5))
        app.staticTexts["Medication"].tap()
        
        XCTAssertTrue(app.buttons["Add"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["Add"].isEnabled)
        
        let nameField2 = app.textFields["Medication Name"]
        XCTAssertTrue(nameField2.waitForExistence(timeout: 5))
        nameField2.tap()
        nameField2.typeText("Aspirin")
        
        let doseField2 = app.textFields["Amount"]
        XCTAssertTrue(doseField2.waitForExistence(timeout: 5))
        doseField2.tap()
        doseField2.typeText("invalid")
        
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

    @MainActor
    func testSymptomsDataInput() throws {
        let app = XCUIApplication()
        
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))
        
        XCTAssertTrue(app.tabBars["Tab Bar"].buttons["Add Data"].waitForExistence(timeout: 5))
        app.tabBars["Tab Bar"].buttons["Add Data"].tap()
        
        XCTAssertTrue(app.staticTexts["Symptoms"].waitForExistence(timeout: 5))
        app.staticTexts["Symptoms"].tap()
        
        XCTAssertTrue(app.navigationBars["Symptoms"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Are you experiencing any of the following:"].waitForExistence(timeout: 5))
        
        let symptoms = ["Nausea", "Pain", "Cough"]
        let severities = ["3", "5", "8"]
        
        for (index, symptom) in symptoms.enumerated() {
            let toggle = app.switches[symptom]
            XCTAssertTrue(toggle.waitForExistence(timeout: 5))
            toggle.tap()
            
            let severityField = app.textFields["1-10"]
            XCTAssertTrue(severityField.waitForExistence(timeout: 5))
            severityField.tap()
            severityField.typeText(severities[index])
            
            if severities[index] == "5" {
                XCTAssertTrue(app.staticTexts["Contact your provider about moderately severe \(symptom.lowercased())"].waitForExistence(timeout: 5))
            } else if severities[index] == "8" {
                XCTAssertTrue(app.staticTexts["Contact your provider about severe \(symptom.lowercased())"].waitForExistence(timeout: 5))
            }
        }
        
        XCTAssertTrue(app.buttons["Add"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Add"].isEnabled)
        app.buttons["Add"].tap()
        try app.handleHealthKitAuthorization()
        XCTAssertTrue(app.staticTexts["What data would you like to add?"].waitForExistence(timeout: 5))
        
        app.staticTexts["Symptoms"].tap()
        
        XCTAssertTrue(app.buttons["Add"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["Add"].isEnabled)
        
        let toggle = app.switches["Nausea"]
        XCTAssertTrue(toggle.waitForExistence(timeout: 5))
        toggle.tap()
        
        let severityField = app.textFields["1-10"]
        XCTAssertTrue(severityField.waitForExistence(timeout: 5))
        severityField.tap()
        severityField.typeText("11")
        
        app.buttons["Add"].tap()
        XCTAssertTrue(app.staticTexts["Error"].waitForExistence(timeout: 5))
        
        let lastSymptom = app.switches["Pain"]
        while !lastSymptom.exists {
            app.swipeUp()
        }
        XCTAssertTrue(lastSymptom.exists)
    }
}
