//
// This source file is part of the NeutroFeverGuard based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//
import XCTest
import XCTestExtensions


class HKVisualizationTests: XCTestCase {
    @MainActor
    override func setUp() async throws {
        continueAfterFailure = false
        
        let app = XCUIApplication()
        app.launchArguments = ["--skipOnboarding", "--mockLabData"]
        app.deleteAndLaunch(withSpringboardAppName: "NeutroFeverGuard")
    }
    
    @MainActor
    func testHealthKitView() throws {
        let app = XCUIApplication()
        
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))
        
        XCTAssertTrue(app.tabBars["Tab Bar"].buttons["Dashboard"].waitForExistence(timeout: 2))
        app.tabBars["Tab Bar"].buttons["Dashboard"].tap()
    }
    
    @MainActor
    func testHealthKitViewRendersCorrectly() throws {
        let app = XCUIApplication()
            
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))
            
        XCTAssertTrue(app.tabBars["Tab Bar"].buttons["Dashboard"].waitForExistence(timeout: 2))
        app.tabBars["Tab Bar"].buttons["Dashboard"].tap()
            
        // Verify Title Exists
        XCTAssertTrue(app.staticTexts["Blood Oxygen Saturation"].exists)
            
        // Verify X and Y axis labels exist
        XCTAssertTrue(app.staticTexts["Date"].exists)
        XCTAssertTrue(app.staticTexts["Oxygen Saturation (%)"].exists)
            
        // Verify threshold is displayed
        let threshold = app.otherElements["Threshold"]
        XCTAssertTrue(threshold.exists, "Threshold line should be visible.")
    }
        
    // MARK: - Test Bar and Point Rendering
        
    @MainActor
    func testChartBarsAreDisplayed() throws {
        let app = XCUIApplication()
            
        XCTAssertTrue(app.tabBars["Tab Bar"].buttons["Dashboard"].waitForExistence(timeout: 2))
        app.tabBars["Tab Bar"].buttons["Dashboard"].tap()
            
        // Check if bars are present
        let bar1 = app.otherElements["Bar_1"]
        let bar2 = app.otherElements["Bar_2"]
            
        XCTAssertTrue(bar1.exists, "Bar 1 should be displayed on the chart.")
        XCTAssertTrue(bar2.exists, "Bar 2 should be displayed on the chart.")
    }
        
    // MARK: - Test Tap Gesture for Lollipop
        
    @MainActor
    func testTapGestureLollipopAppears() throws {
        let app = XCUIApplication()
            
        XCTAssertTrue(app.tabBars["Tab Bar"].buttons["Dashboard"].waitForExistence(timeout: 2))
        app.tabBars["Tab Bar"].buttons["Dashboard"].tap()
            
        // Tap on the first bar
        let bar1 = app.otherElements["Bar_1"]
        XCTAssertTrue(bar1.exists, "First bar should be present.")
        bar1.tap()
            
        // Check if lollipop appears with correct value
        let lollipop = app.staticTexts["100"]
        XCTAssertTrue(lollipop.exists, "Lollipop should display value after tapping bar.")
    }
        
    // MARK: - Test Drag Gesture
        
    @MainActor
    func testDragGestureUpdatesSelection() throws {
        let app = XCUIApplication()
            
        XCTAssertTrue(app.tabBars["Tab Bar"].buttons["Dashboard"].waitForExistence(timeout: 2))
        app.tabBars["Tab Bar"].buttons["Dashboard"].tap()
            
        let chart = app.otherElements["Chart_View"]
        XCTAssertTrue(chart.exists, "Chart should be present.")
            
        let start = chart.coordinate(withNormalizedOffset: CGVector(dx: 0.2, dy: 0.5))
        let end = chart.coordinate(withNormalizedOffset: CGVector(dx: 0.8, dy: 0.5))
            
        start.press(forDuration: 0.2, thenDragTo: end)
            
        // Verify lollipop updates with correct value after drag
        let lollipop = app.staticTexts["90"]
        XCTAssertTrue(lollipop.exists, "Lollipop value should update during drag.")
    }
        
    // MARK: - Test Threshold Rendering
        
    @MainActor
    func testThresholdRendering() throws {
        let app = XCUIApplication()
            
        XCTAssertTrue(app.tabBars["Tab Bar"].buttons["Dashboard"].waitForExistence(timeout: 2))
        app.tabBars["Tab Bar"].buttons["Dashboard"].tap()
            
        let threshold = app.staticTexts["Threshold"]
        XCTAssertTrue(threshold.exists, "Threshold line should be visible.")
    }
        
    // MARK: - Test Accessibility Labels
        
    @MainActor
    func testAccessibilityLabelsAreCorrect() throws {
        let app = XCUIApplication()
            
        XCTAssertTrue(app.tabBars["Tab Bar"].buttons["Dashboard"].waitForExistence(timeout: 2))
        app.tabBars["Tab Bar"].buttons["Dashboard"].tap()
            
        let bar = app.otherElements["Bar_1"]
        XCTAssertTrue(bar.exists, "First bar should be present.")
            
        // Ensure the accessibility label is correctly set
        XCTAssertEqual(bar.label, "Heart Rate: 75", "Accessibility label should match value.")
    }
        
    // MARK: - Test Average Line Appears
        
    @MainActor
    func testAverageLineAppears() throws {
        let app = XCUIApplication()
            
        XCTAssertTrue(app.tabBars["Tab Bar"].buttons["Dashboard"].waitForExistence(timeout: 2))
        app.tabBars["Tab Bar"].buttons["Dashboard"].tap()
            
        let avgLine = app.otherElements["Average_Line"]
        XCTAssertTrue(avgLine.exists, "Average line should appear if plotAvg is true.")
    }
        
    // MARK: - Test State Handling
        
    @MainActor
    func testStateClearsOnDeselect() throws {
        let app = XCUIApplication()
            
        XCTAssertTrue(app.tabBars["Tab Bar"].buttons["Dashboard"].waitForExistence(timeout: 2))
        app.tabBars["Tab Bar"].buttons["Dashboard"].tap()
            
        let bar = app.otherElements["Bar_1"]
        XCTAssertTrue(bar.exists, "First bar should be present.")
            
        bar.tap()
        bar.tap() // Tap again to deselect
            
        let lollipop = app.staticTexts["100"]
        XCTAssertFalse(lollipop.exists, "Lollipop should disappear after second tap.")
    }
}
