//
// This source file is part of the NeutroFeverGuard based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import XCTest

final class HKVisualizationUITests: XCTestCase {

    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchEnvironment["IS_UITEST"] = "1"  // Enables mock data
        app.launch()
    }

    func testMockDataLoadsSuccessfully() {
        // Verify the navigation title exists
        XCTAssertTrue(app.navigationBars["Vitals Dashboard"].exists)
        
        // Verify the Heart Rate section exists
        let heartRateSection = app.staticTexts["Heart Rate Over Time"]
        XCTAssertTrue(heartRateSection.exists, "Heart Rate section should be visible.")
        
        // Verify a chart element is present for heart rate data
        let heartRateChart = app.otherElements["HeartRateChart"]
        XCTAssertTrue(heartRateChart.exists, "Heart Rate chart should be visible.")
    }
    
    func testVitalsDashboardExists() {
        // Ensure the "Vitals Dashboard" title is present
        XCTAssertTrue(app.navigationBars["Vitals Dashboard"].exists, "Vitals Dashboard title should be visible.")
    }

    func testHeartRateSectionExists() {
        // Scroll to the Heart Rate section and verify it exists
        let heartRateSection = app.staticTexts["Heart Rate Over Time"]
        XCTAssertTrue(heartRateSection.exists, "Heart Rate Over Time section should be visible.")
    }

    func testBasalBodyTemperatureSectionExists() {
        // Scroll to the Basal Body Temperature section
        let bodyTemperatureSection = app.staticTexts["Basal Body Temperature Over Time"]
        XCTAssertTrue(bodyTemperatureSection.exists, "Basal Body Temperature Over Time section should be visible.")
    }

    func testOxygenSaturationSectionExists() {
        // Scroll to the Oxygen Saturation section
        let oxygenSaturationSection = app.staticTexts["Oxygen Saturation Over Time"]
        XCTAssertTrue(oxygenSaturationSection.exists, "Oxygen Saturation Over Time section should be visible.")
    }

    func testEmptyDataPlaceholder() {
        // Ensure the "No data available" placeholder is visible when no data is loaded
        let placeholderText = app.staticTexts["No data available."]
        XCTAssertTrue(placeholderText.exists, "The placeholder message should be visible when there is no data.")
    }

    func testChartsRender() {
        // Check if a Chart element is rendered
        let chartElement = app.otherElements.matching(identifier: "ChartView").firstMatch
        XCTAssertTrue(chartElement.exists, "A chart should be visible in the section.")
    }
}
