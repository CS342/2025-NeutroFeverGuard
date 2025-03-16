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
        app.launch()
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
    func testHealthDashboardOxygen() throws {
        let app = XCUIApplication()
        
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))
        
        XCTAssertTrue(app.tabBars["Tab Bar"].buttons["Dashboard"].waitForExistence(timeout: 2))
        app.tabBars["Tab Bar"].buttons["Dashboard"].tap()
        try app.handleHealthKitAuthorization()
        
        // Verify Plot Titles Exists
        XCTAssertTrue(app.staticTexts["Oxygen Saturation"].exists)
        XCTAssertTrue(app.staticTexts["Body Temperature"].exists)
        XCTAssertTrue(app.staticTexts["Heart Rate"].exists)
        
        // Wait for chart to appear
        let chartTitle = app.staticTexts["Oxygen Saturation"]
        XCTAssertTrue(chartTitle.waitForExistence(timeout: 5))
        
        // Get the frame of the chart title
        let frame = chartTitle.frame
        // Tap below the title where the chart should be
        let tapPoint = CGPoint(x: frame.maxX - 50, y: frame.maxY + 100)  // Tap near the right side where today's data point should be
        app.coordinate(withNormalizedOffset: .zero).withOffset(CGVector(dx: tapPoint.x, dy: tapPoint.y)).tap()
        
        // ✅ Check that summary date is correct
        let today = Date()
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        let dateStr = formatter.string(from: today)
        
        let summaryDate = app.staticTexts["Summary_Date"]
        XCTAssertTrue(summaryDate.exists)
        XCTAssertEqual(summaryDate.label, "Summary: \(dateStr)")

        // ✅ Check that average value is correct
        let summaryAverage = app.staticTexts["Summary_Average"]
        XCTAssertTrue(summaryAverage.exists)
        XCTAssertEqual(summaryAverage.label, "Average: 50.0")

        // ✅ Check that max value is correct
        let summaryMax = app.staticTexts["Summary_Max"]
        XCTAssertTrue(summaryMax.exists)
        XCTAssertEqual(summaryMax.label, "Max value: 100")

        // ✅ Check that min value is correct
        let summaryMin = app.staticTexts["Summary_Min"]
        XCTAssertTrue(summaryMin.exists)
        XCTAssertEqual(summaryMin.label, "Min value: 1")
    }
    
    @MainActor
    func testThreshold() throws {
        let app = XCUIApplication()
        
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))
        
        XCTAssertTrue(app.tabBars["Tab Bar"].buttons["Dashboard"].waitForExistence(timeout: 2))
        app.tabBars["Tab Bar"].buttons["Dashboard"].tap()
        try app.handleHealthKitAuthorization()
        
        // Check for Heart Rate Chart
        let heartRateChartTitle = app.staticTexts["Heart Rate"]
        XCTAssertTrue(heartRateChartTitle.waitForExistence(timeout: 5), "Heart Rate chart title should exist")
        
        let heartRateThreshold = app.otherElements["Threshold"]
        XCTAssertTrue(heartRateThreshold.waitForExistence(timeout: 2), "Heart Rate threshold line should be visible.")
    }
    
    @MainActor
    func testHealthDashboardTemperature() throws {
        let app = XCUIApplication()
        
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))
        
        XCTAssertTrue(app.tabBars["Tab Bar"].buttons["Dashboard"].waitForExistence(timeout: 2))
        app.tabBars["Tab Bar"].buttons["Dashboard"].tap()
        try app.handleHealthKitAuthorization()
        
        // Wait for chart to appear
        let chartTitle = app.staticTexts["Body Temperature"]
        XCTAssertTrue(chartTitle.waitForExistence(timeout: 5))
        
        // Get the frame of the chart title
        let frame = chartTitle.frame
        // Tap below the title where the chart should be
        let tapPoint = CGPoint(x: frame.maxX - 50, y: frame.maxY + 100)  // Tap near the right side where today's data point should be
        app.coordinate(withNormalizedOffset: .zero).withOffset(CGVector(dx: tapPoint.x, dy: tapPoint.y)).tap()
        
        // ✅ Check that summary date is correct
        let today = Date()
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        let dateStr = formatter.string(from: today)
        
        let summaryDate = app.staticTexts["Summary_Date"]
        XCTAssertTrue(summaryDate.exists)
        XCTAssertEqual(summaryDate.label, "Summary: \(dateStr)")

        // ✅ Check that average value is correct
        let summaryAverage = app.staticTexts["Summary_Average"]
        XCTAssertTrue(summaryAverage.exists)
        XCTAssertEqual(summaryAverage.label, "Average: 50.0")

        // ✅ Check that max value is correct
        let summaryMax = app.staticTexts["Summary_Max"]
        XCTAssertTrue(summaryMax.exists)
        XCTAssertEqual(summaryMax.label, "Max value: 100")

        // ✅ Check that min value is correct
        let summaryMin = app.staticTexts["Summary_Min"]
        XCTAssertTrue(summaryMin.exists)
        XCTAssertEqual(summaryMin.label, "Min value: 1")
    }
    
    @MainActor
    func testHealthDashboardHearRate() throws {
        let app = XCUIApplication()
        
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))
        
        XCTAssertTrue(app.tabBars["Tab Bar"].buttons["Dashboard"].waitForExistence(timeout: 2))
        app.tabBars["Tab Bar"].buttons["Dashboard"].tap()
        try app.handleHealthKitAuthorization()
        
        // Wait for chart to appear
        let chartTitle = app.staticTexts["Heart Rate"]
        XCTAssertTrue(chartTitle.waitForExistence(timeout: 5))
        
        // Get the frame of the chart title
        let frame = chartTitle.frame
        // Tap below the title where the chart should be
        let tapPoint = CGPoint(x: frame.maxX - 50, y: frame.maxY + 100)  // Tap near the right side where today's data point should be
        app.coordinate(withNormalizedOffset: .zero).withOffset(CGVector(dx: tapPoint.x, dy: tapPoint.y)).tap()
        
        // ✅ Check that summary date is correct
        let today = Date()
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        let dateStr = formatter.string(from: today)
        
        let summaryDate = app.staticTexts["Summary_Date"]
        XCTAssertTrue(summaryDate.exists)
        XCTAssertEqual(summaryDate.label, "Summary: \(dateStr)")

        // ✅ Check that average value is correct
        let summaryAverage = app.staticTexts["Summary_Average"]
        XCTAssertTrue(summaryAverage.exists)
        XCTAssertEqual(summaryAverage.label, "Average: 50.0")

        // ✅ Check that max value is correct
        let summaryMax = app.staticTexts["Summary_Max"]
        XCTAssertTrue(summaryMax.exists)
        XCTAssertEqual(summaryMax.label, "Max value: 100")

        // ✅ Check that min value is correct
        let summaryMin = app.staticTexts["Summary_Min"]
        XCTAssertTrue(summaryMin.exists)
        XCTAssertEqual(summaryMin.label, "Min value: 1")
    }
    
    @MainActor
    func testThresholdAndAverageForAllCharts() throws {
        let app = XCUIApplication()
        
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))
        
        XCTAssertTrue(app.tabBars["Tab Bar"].buttons["Dashboard"].waitForExistence(timeout: 2))
        app.tabBars["Tab Bar"].buttons["Dashboard"].tap()
        try app.handleHealthKitAuthorization()
        
        // Check for Heart Rate Chart
        let heartRateChartTitle = app.staticTexts["Heart Rate"]
        XCTAssertTrue(heartRateChartTitle.waitForExistence(timeout: 5), "Heart Rate chart title should exist")
        
        let heartRateThreshold = app.otherElements["Threshold"]
        XCTAssertTrue(heartRateThreshold.waitForExistence(timeout: 2), "Heart Rate threshold line should be visible.")
        
        // Check for Body Temperature Chart
        let bodyTempChartTitle = app.staticTexts["Body Temperature"]
        XCTAssertTrue(bodyTempChartTitle.waitForExistence(timeout: 5), "Body Temperature chart title should exist")
        
        let bodyTempThreshold = app.otherElements["Threshold"]
        XCTAssertTrue(bodyTempThreshold.waitForExistence(timeout: 2), "Body Temperature threshold line should be visible.")
        
        // Check for Oxygen Saturation Chart
        let oxygenSatChartTitle = app.staticTexts["Oxygen Saturation"]
        XCTAssertTrue(oxygenSatChartTitle.waitForExistence(timeout: 5), "Oxygen Saturation chart title should exist")
        
        let oxygenSatThreshold = app.otherElements["Threshold"]
        XCTAssertTrue(oxygenSatThreshold.waitForExistence(timeout: 2), "Oxygen Saturation threshold line should be visible.")
    }
    
    @MainActor
    func testHealthDashboardNeutrophils() throws {
        let app = XCUIApplication()
        
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))
        
        XCTAssertTrue(app.tabBars["Tab Bar"].buttons["Dashboard"].waitForExistence(timeout: 2))
        app.tabBars["Tab Bar"].buttons["Dashboard"].tap()
        
        let chartTitle = app.staticTexts["Absolute Neutrophil Count"]

        var maxScrollAttempts = 10
        while !chartTitle.exists && maxScrollAttempts > 0 {
            print("📍 Swiping up to find Neutrophil chart...")
            app.swipeUp()
            sleep(1) // Allow UI time to update
            maxScrollAttempts -= 1
        }
        
        XCTAssertTrue(chartTitle.waitForExistence(timeout: 5), "Neutrophil chart should be visible after scrolling.")
        
        // ✅ Tap on the chart to bring up the summary view
        let frame = chartTitle.frame
        let tapPoint = CGPoint(x: frame.midX, y: frame.midY) // Tap at the center
        print("📍 Tapping at: \(tapPoint)") // Debug print
        app.coordinate(withNormalizedOffset: .zero).withOffset(CGVector(dx: tapPoint.x, dy: tapPoint.y)).tap()
            
        // ✅ Verify summary date (should be today's date)
        let today = Date()
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        let dateStr = formatter.string(from: today)
        
        let summaryDate = app.staticTexts["Summary_Date"]
        XCTAssertTrue(summaryDate.exists)
        XCTAssertEqual(summaryDate.label, "Summary: \(dateStr)")

        // ✅ Check the summary ANC values
        let summaryAverage = app.staticTexts["Summary_Average"]
        XCTAssertTrue(summaryAverage.exists, "Average ANC value should exist")
        XCTAssertEqual(summaryAverage.label, "Average: 500.0")  // ✅ Adjusted to mock value

        let summaryMax = app.staticTexts["Summary_Max"]
        XCTAssertTrue(summaryMax.exists, "Max ANC value should exist")
        XCTAssertEqual(summaryMax.label, "Max value: 1000")  // ✅ Adjusted to mock value

        let summaryMin = app.staticTexts["Summary_Min"]
        XCTAssertTrue(summaryMin.exists, "Min ANC value should exist")
        XCTAssertEqual(summaryMin.label, "Min value: 1")  // ✅ Adjusted to mock value
    }
    
    @MainActor
    func testThresholdNeutrophils() throws {
        let app = XCUIApplication()
        
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))
        
        XCTAssertTrue(app.tabBars["Tab Bar"].buttons["Dashboard"].waitForExistence(timeout: 2))
        app.tabBars["Tab Bar"].buttons["Dashboard"].tap()
        try app.handleHealthKitAuthorization()
        
        // ✅ Check if "Neutrophil Count Over Past Week" chart exists
        let chartTitle = app.staticTexts["Absolute Neutrophil Count"]
        XCTAssertTrue(chartTitle.waitForExistence(timeout: 5), "Neutrophil chart title should exist")

        // ✅ Verify threshold line exists (should be around **500 ANC**)
        let neutrophilThreshold = app.otherElements["Threshold"]
        XCTAssertTrue(neutrophilThreshold.waitForExistence(timeout: 2), "Neutrophil threshold line should be visible.")
    }
}
