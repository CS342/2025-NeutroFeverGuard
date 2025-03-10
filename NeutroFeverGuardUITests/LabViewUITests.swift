//
// This source file is part of the NeutroFeverGuard based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import XCTest
import XCTestExtensions

class LabViewTests: XCTestCase {
    @MainActor
    override func setUp() async throws {
        continueAfterFailure = false

        let app = XCUIApplication()
        app.launchArguments = ["--skipOnboarding", "--mockLabData"]
        app.deleteAndLaunch(withSpringboardAppName: "NeutroFeverGuard")
    }

    @MainActor
    func testLabView() throws {
        let app = XCUIApplication()

        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))

        XCTAssertTrue(app.tabBars["Tab Bar"].buttons["Lab"].waitForExistence(timeout: 2))
        app.tabBars["Tab Bar"].buttons["Lab"].tap()

        XCTAssertTrue(app.navigationBars["Lab Results"].waitForExistence(timeout: 2))

        XCTAssertTrue(app.staticTexts["ABSOLUTE NEUTROPHIL COUNTS"].exists)
        XCTAssertTrue(app.staticTexts["🧪 Latest ANC"].exists)

        let ancValueExists = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'cells/µL'")).firstMatch.exists
        XCTAssertTrue(ancValueExists, "ANC value should be displayed")

        XCTAssertTrue(app.staticTexts["LAB RESULTS HISTORY"].exists)

        let firstLabResult = app.cells.element(boundBy: 1) // The first cell after the ANC section
        XCTAssertTrue(firstLabResult.waitForExistence(timeout: 2))
        firstLabResult.tap()

//        print(app.debugDescription)
        XCTAssertTrue(app.navigationBars.staticTexts.firstMatch.waitForExistence(timeout: 2))

        let labValueTypes = [
            "White Blood Cell Count", "Hemoglobin", "Platelet Count", "% Neutrophils",
            "% Lymphocytes", "% Monocytes", "% Eosinophils", "% Basophils", "% Blasts"
        ]

        for valueType in labValueTypes {
            XCTAssertTrue(app.staticTexts[valueType].exists, "\(valueType) should be present in the detail view")
        }
    }
    
    @MainActor
    func testLabDelete() throws {
        let app = XCUIApplication()

        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))

        XCTAssertTrue(app.tabBars["Tab Bar"].buttons["Lab"].waitForExistence(timeout: 2))
        app.tabBars["Tab Bar"].buttons["Lab"].tap()

        XCTAssertTrue(app.navigationBars["Lab Results"].waitForExistence(timeout: 2))

        XCTAssertTrue(app.staticTexts["ABSOLUTE NEUTROPHIL COUNTS"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["🧪 Latest ANC"].exists)

        let ancValueExists = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'cells/µL'")).firstMatch.exists
        XCTAssertTrue(ancValueExists, "ANC value should be displayed")

        XCTAssertTrue(app.staticTexts["LAB RESULTS HISTORY"].waitForExistence(timeout: 2))

        let firstLabResult = app.cells.element(boundBy: 1) // The first cell after the ANC section
        XCTAssertTrue(firstLabResult.waitForExistence(timeout: 2))
        firstLabResult.tap()

        print(app.debugDescription)
        
        XCTAssertTrue(app.buttons["Delete"].waitForExistence(timeout: 2))
        app.buttons["Delete"].tap()
        
        print(app.debugDescription)
        
        XCTAssertTrue(app.staticTexts["Delete Lab Record"].waitForExistence(timeout: 2))
        
        XCTAssertTrue(app.buttons["Cancel"].waitForExistence(timeout: 2))
        app.buttons["Cancel"].tap()
        XCTAssertTrue(app.staticTexts["Lab Details"].waitForExistence(timeout: 2))
        
        XCTAssertTrue(app.buttons["Delete"].waitForExistence(timeout: 2))
        app.buttons["Delete"].tap()
        XCTAssertTrue(app.staticTexts["Delete Lab Record"].waitForExistence(timeout: 2))
        
        let deleteAlertButton = app.buttons["DeleteAlertButton"]
        XCTAssertTrue(deleteAlertButton.waitForExistence(timeout: 2))
        deleteAlertButton.tap()
        
        XCTAssertTrue(app.staticTexts["No ANC data available"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["No lab results recorded"].waitForExistence(timeout: 2))
    }
}
