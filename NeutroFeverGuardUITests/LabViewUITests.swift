//
// This source file is part of the NeutroFeverGuard based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

//    import XCTest
//    import XCTestExtensions
//
//    class LabViewTests: XCTestCase {
//        @MainActor
//        override func setUp() async throws {
//            continueAfterFailure = false
//
//            let app = XCUIApplication()
//            app.launchArguments = ["--skipOnboarding"]
//            app.deleteAndLaunch(withSpringboardAppName: "NeutroFeverGuard")
//        }
//
//        @MainActor
//        func testLabView() throws {
//            let app = XCUIApplication()
//
//            XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))
//
//            XCTAssertTrue(app.tabBars["Tab Bar"].buttons["Lab"].waitForExistence(timeout: 2))
//            app.tabBars["Tab Bar"].buttons["Lab"].tap()
//
//            XCTAssertTrue(app.navigationBars["Lab Results"].waitForExistence(timeout: 2))
//
//            print(app.debugDescription)
//            XCTAssertTrue(app.staticTexts["ABSOLUTE NEUTROPHIL COUNTS"].exists)
//            XCTAssertTrue(app.staticTexts["🧪 Latest ANC"].exists)
//
//            let ancValueExists = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'cells/µL'")).firstMatch.exists
//            XCTAssertTrue(ancValueExists, "ANC value should be displayed")
//
//            XCTAssertTrue(app.staticTexts["LAB RESULTS HISTORY"].exists)
//
//            let firstLabResult = app.cells.element(boundBy: 1) // The first cell after the ANC section
//            XCTAssertTrue(firstLabResult.waitForExistence(timeout: 2))
//            firstLabResult.tap()
//
//            print(app.debugDescription)
//            XCTAssertTrue(app.navigationBars.staticTexts.firstMatch.waitForExistence(timeout: 2))
//            XCTAssertTrue(app.staticTexts["LAB VALUES"].exists)
//
//            let labValueTypes = [
//                "White Blood Cell Count", "Hemoglobin", "Platelet Count", "% Neutrophils",
//                "% Lymphocytes", "% Monocytes", "% Eosinophils", "% Basophils", "% Blasts"
//            ]
//
//            for valueType in labValueTypes {
//                XCTAssertTrue(app.staticTexts[valueType].exists, "\(valueType) should be present in the detail view")
//            }
//        }
//    }
