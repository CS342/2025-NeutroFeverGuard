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
        app.launchArguments = ["--skipOnboarding", "--mockVizData"]
        app.deleteAndLaunch(withSpringboardAppName: "NeutroFeverGuard")
    }
    
    @MainActor
    func testHealthKitView() throws {
        let app = XCUIApplication()
        
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))
        
        XCTAssertTrue(app.tabBars["Tab Bar"].buttons["Dashboard"].waitForExistence(timeout: 2))
        app.tabBars["Tab Bar"].buttons["Dashboard"].tap()
        try app.handleHealthKitAuthorization()
    }
    
    @MainActor
    func testHealthDashboard() throws {
        let app = XCUIApplication()
        
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))
        
        XCTAssertTrue(app.tabBars["Tab Bar"].buttons["Dashboard"].waitForExistence(timeout: 2))
        app.tabBars["Tab Bar"].buttons["Dashboard"].tap()
        try app.handleHealthKitAuthorization()
        
        // Verify Plot Titles Exists
        XCTAssertTrue(app.staticTexts["Oxygen Saturation Over Time"].exists)
        XCTAssertTrue(app.staticTexts["Body Temperature Over Time"].exists)
        XCTAssertTrue(app.staticTexts["Heart Rate Over Time"].exists)
        
        // Wait for chart to appear
        let chartTitle = app.staticTexts["Oxygen Saturation Over Time"]
        XCTAssertTrue(chartTitle.waitForExistence(timeout: 5))
        
        // Get the frame of the chart title
        let frame = chartTitle.frame
        // Tap below the title where the chart should be
        let tapPoint = CGPoint(x: frame.maxX - 50, y: frame.maxY + 100)  // Tap near the right side where today's data point should be
        app.coordinate(withNormalizedOffset: .zero).withOffset(CGVector(dx: tapPoint.x, dy: tapPoint.y)).tap()
        
        // Verify that some interaction happened by checking for a date
        let today = Date()
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        let dateStr = formatter.string(from: today)
        
        let dateExists = app.staticTexts[dateStr].waitForExistence(timeout: 2)
        XCTAssertTrue(dateExists, "Today's date (\(dateStr)) should appear after tapping")
    }
    
    @MainActor
    func testSummaries() throws {
        let app = XCUIApplication()
        
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))
        XCTAssertTrue(app.tabBars["Tab Bar"].buttons["Dashboard"].waitForExistence(timeout: 2))
        app.tabBars["Tab Bar"].buttons["Dashboard"].tap()
        try app.handleHealthKitAuthorization()
        
        // Wait for chart to appear
        let chartTitle = app.staticTexts["Oxygen Saturation Over Time"]
        XCTAssertTrue(chartTitle.waitForExistence(timeout: 5))
        
        // Get the frame of the chart title
        let frame = chartTitle.frame
        // Tap below the title where the chart should be
        let tapPoint = CGPoint(x: frame.maxX - 50, y: frame.maxY + 100)  // Tap near the right side where today's data point should be
        app.coordinate(withNormalizedOffset: .zero).withOffset(CGVector(dx: tapPoint.x, dy: tapPoint.y)).tap()
        
        // Verify that some interaction happened by checking for a date
        let today = Date()
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        let dateStr = formatter.string(from: today)
        
        let dateExists = app.staticTexts[dateStr].waitForExistence(timeout: 2)
        XCTAssertTrue(dateExists, "Today's date (\(dateStr)) should appear after tapping")
        
        let minValue = app.staticTexts["Min value:"]
        let maxValue = app.staticTexts["Max value:"]
        
        XCTAssertTrue(minValue.waitForExistence(timeout: 2), "Min value should appear after tapping a point.")
        XCTAssertTrue(maxValue.waitForExistence(timeout: 2), "Max value should appear after tapping a point.")
    }
    
    @MainActor
    func testThresholdAndAverageForAllCharts() throws {
        let app = XCUIApplication()
        
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))
        
        XCTAssertTrue(app.tabBars["Tab Bar"].buttons["Dashboard"].waitForExistence(timeout: 2))
        app.tabBars["Tab Bar"].buttons["Dashboard"].tap()
        try app.handleHealthKitAuthorization()
        
        // Check for Heart Rate Chart
        let heartRateChartTitle = app.staticTexts["Heart Rate Over Time"]
        XCTAssertTrue(heartRateChartTitle.waitForExistence(timeout: 5), "Heart Rate chart title should exist")
        
        let heartRateThreshold = app.otherElements["Threshold"]
        XCTAssertTrue(heartRateThreshold.waitForExistence(timeout: 2), "Heart Rate threshold line should be visible.")
        
        let heartRateAvgLine = app.otherElements["Average_Line"]
        XCTAssertTrue(heartRateAvgLine.waitForExistence(timeout: 2), "Heart Rate average line should be visible.")
        
        // Check for Body Temperature Chart
        let bodyTempChartTitle = app.staticTexts["Body Temperature Over Time"]
        XCTAssertTrue(bodyTempChartTitle.waitForExistence(timeout: 5), "Body Temperature chart title should exist")
        
        let bodyTempThreshold = app.otherElements["Threshold"]
        XCTAssertTrue(bodyTempThreshold.waitForExistence(timeout: 2), "Body Temperature threshold line should be visible.")
        
        let bodyTempAvgLine = app.otherElements["Average_Line"]
        XCTAssertTrue(bodyTempAvgLine.waitForExistence(timeout: 2), "Body Temperature average line should be visible.")
        
        // Check for Oxygen Saturation Chart
        let oxygenSatChartTitle = app.staticTexts["Oxygen Saturation Over Time"]
        XCTAssertTrue(oxygenSatChartTitle.waitForExistence(timeout: 5), "Oxygen Saturation chart title should exist")
        
        let oxygenSatThreshold = app.otherElements["Threshold"]
        XCTAssertTrue(oxygenSatThreshold.waitForExistence(timeout: 2), "Oxygen Saturation threshold line should be visible.")
        
        let oxygenSatAvgLine = app.otherElements["Average_Line"]
        XCTAssertTrue(oxygenSatAvgLine.waitForExistence(timeout: 2), "Oxygen Saturation average line should be visible.")
    }
}
