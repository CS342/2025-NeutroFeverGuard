//
// This source file is part of the NeutroFeverGuard based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import XCTest
import XCTestExtensions

class MedicationViewTests: XCTestCase {
    @MainActor
    override func setUp() async throws {
        continueAfterFailure = false

        let app = XCUIApplication()
        app.launchArguments = ["--skipOnboarding", "--mockMedData"]
        app.deleteAndLaunch(withSpringboardAppName: "NeutroFeverGuard")
    }

    @MainActor
    func testMedView() throws {
        let app = XCUIApplication()

        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))

        XCTAssertTrue(app.tabBars["Tab Bar"].buttons["Medication"].waitForExistence(timeout: 2))
        app.tabBars["Tab Bar"].buttons["Medication"].tap()

        XCTAssertTrue(app.navigationBars["Medication List"].waitForExistence(timeout: 2))

        print(app.debugDescription)
        XCTAssertTrue(app.staticTexts["test"].exists)
        XCTAssertTrue(app.staticTexts["Dose: 1.00 mg"].exists)

        let dateExists = app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH[c] 'Date:'")).firstMatch.exists
        XCTAssertTrue(dateExists, "Date label should be displayed")
        
        app.cells.firstMatch.swipeRight()
        XCTAssertTrue(app.buttons["Edit"].waitForExistence(timeout: 2))
        app.buttons["Edit"].tap()
        
        let nameField = app.textFields["Medication Name"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 2))
        
        let doseField = app.textFields["Amount"]
        XCTAssertTrue(doseField.waitForExistence(timeout: 2))
        
        XCTAssertTrue(app.buttons["Save"].waitForExistence(timeout: 2))
        app.buttons["Save"].tap()
    }
    
    @MainActor
    func testMedDelete() throws {
        let app = XCUIApplication()

        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))

        XCTAssertTrue(app.tabBars["Tab Bar"].buttons["Medication"].waitForExistence(timeout: 2))
        app.tabBars["Tab Bar"].buttons["Medication"].tap()

        
        app.cells.firstMatch.swipeLeft()
        XCTAssertTrue(app.buttons["Delete"].waitForExistence(timeout: 2))
        app.buttons["Delete"].tap()
        
        XCTAssertTrue(app.staticTexts["No medications recorded"].waitForExistence(timeout: 2))
    }
    
    @MainActor
    func testMedEditCancel() throws {
        let app = XCUIApplication()

        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))

        XCTAssertTrue(app.tabBars["Tab Bar"].buttons["Medication"].waitForExistence(timeout: 2))
        app.tabBars["Tab Bar"].buttons["Medication"].tap()

        
        app.cells.firstMatch.swipeRight()
        XCTAssertTrue(app.buttons["Edit"].waitForExistence(timeout: 2))
        app.buttons["Edit"].tap()
        
        XCTAssertTrue(app.buttons["Cancel"].waitForExistence(timeout: 2))
        app.buttons["Cancel"].tap()
        
        XCTAssertTrue(app.navigationBars["Medication List"].waitForExistence(timeout: 2))
    }
    
    @MainActor
    func testMedEditInvalid() throws {
        let app = XCUIApplication()

        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))

        XCTAssertTrue(app.tabBars["Tab Bar"].buttons["Medication"].waitForExistence(timeout: 2))
        app.tabBars["Tab Bar"].buttons["Medication"].tap()

        
        app.cells.firstMatch.swipeRight()
        XCTAssertTrue(app.buttons["Edit"].waitForExistence(timeout: 2))
        app.buttons["Edit"].tap()
    }
}
