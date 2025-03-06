//
// This source file is part of the NeutroFeverGuard based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import XCTest
import XCTestExtensions


class SchedulerTests: XCTestCase {
    @MainActor
    override func setUp() async throws {
        continueAfterFailure = false
        
        let app = XCUIApplication()
        app.launchArguments = ["--skipOnboarding"]
        app.deleteAndLaunch(withSpringboardAppName: "NeutroFeverGuard")
    }
    

    @MainActor
    func testScheduler() throws {
        let app = XCUIApplication()

        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))

        XCTAssertTrue(app.tabBars["Tab Bar"].buttons["Schedule"].waitForExistence(timeout: 2))
        app.tabBars["Tab Bar"].buttons["Schedule"].tap()

        let startButton = app.buttons.matching(identifier: "Start Questionnaire").element(boundBy: 0)
        XCTAssertTrue(startButton.waitForExistence(timeout: 2))
        startButton.tap()
        
        XCTAssertTrue(app.staticTexts["Social Support"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.navigationBars.buttons["Cancel"].exists)

        XCTAssertTrue(app.staticTexts["None of the time"].waitForExistence(timeout: 2))
        let noButton = app.staticTexts["None of the time"]

        let nextButton = app.buttons["Next"]

        for _ in 1...4 {
            XCTAssertFalse(nextButton.isEnabled)
            noButton.tap()
            XCTAssertTrue(nextButton.isEnabled)
            nextButton.tap()
            usleep(500_000)
        }

        XCTAssert(app.staticTexts["What is your age?"].waitForExistence(timeout: 0.5))
        XCTAssert(app.textFields["Tap to answer"].waitForExistence(timeout: 2))
        try app.textFields["Tap to answer"].enter(value: "25")
        app.buttons["Done"].tap()

        XCTAssert(nextButton.isEnabled)
        nextButton.tap()

        XCTAssert(app.staticTexts["What is your preferred contact method?"].waitForExistence(timeout: 0.5))
        XCTAssert(app.staticTexts["E-mail"].waitForExistence(timeout: 2))
        app.staticTexts["E-mail"].tap()

        XCTAssert(nextButton.isEnabled)
        nextButton.tap()
        XCTAssert(app.textFields["Tap to answer"].waitForExistence(timeout: 2))
        try app.textFields["Tap to answer"].enter(value: "leland@stanford.edu")

        XCTAssert(nextButton.isEnabled)
        nextButton.tap()

        XCTAssert(app.staticTexts["Thank you for taking the survey!"].waitForExistence(timeout: 0.5))
        XCTAssert(app.buttons["Done"].waitForExistence(timeout: 2))
        app.buttons["Done"].tap()

        XCTAssert(app.staticTexts["Completed"].waitForExistence(timeout: 0.5))
    }
}
