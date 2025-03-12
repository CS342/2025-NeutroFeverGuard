import XCTest
@testable import NeutroFeverGuard
import SwiftUI
import ViewInspector
import Charts

final class HKVisualizationTest: XCTestCase {
    
    func testHKVisualizationItemWithMockData() throws {
        let mockData = [
            HKData(date: Date(), sumValue: 98.6, avgValue: 98.6, minValue: 98.0, maxValue: 99.2),
            HKData(date: Date().addingTimeInterval(-86400), sumValue: 98.4, avgValue: 98.4, minValue: 98.0, maxValue: 99.0)
        ]
        
        let mockScatterData = [
            HKData(date: Date(), sumValue: 98.6, avgValue: 98.6, minValue: 98.0, maxValue: 99.2)
        ]
        
        let view = HKVisualizationItem(
            data: mockData,
            xName: "Time",
            yName: "Temperature (°F)",
            title: "Body Temperature",
            threshold: 99.0,
            scatterData: mockScatterData
        )
        
        let inspection = view.inspection
        
        XCTAssertNoThrow(try inspection.inspect { content in
            // Verify title is present
            let title = try content.find(viewWithId: "visualization-title").text().string()
            XCTAssertEqual(title, "Body Temperature")
            
            // Verify chart is present
            XCTAssertNoThrow(try content.find(Chart<Any, Any>.self))
            
            // Verify axis labels
            let xLabel = try content.find(viewWithId: "x-axis-label").text().string()
            let yLabel = try content.find(viewWithId: "y-axis-label").text().string()
            XCTAssertEqual(xLabel, "Time")
            XCTAssertEqual(yLabel, "Temperature (°F)")
        })
    }
    
    func testHKVisualizationWithMockData() throws {
        let view = HKVisualization(presentingAccount: .constant(false))
        
        let inspection = view.inspection
        
        XCTAssertNoThrow(try inspection.inspect { content in
            // Verify navigation title
            let navigationView = try content.navigationStack()
            XCTAssertEqual(try navigationView.navigationTitle(), "HKVIZ_NAVIGATION_TITLE")
            
            // Find the List containing all sections
            let list = try navigationView.list()
            
            // Verify sections for each vital sign are present
            let sections = try list.findAll(ViewType.Section.self)
            XCTAssertEqual(sections.count, 4) // Heart Rate, Body Temperature, Oxygen Saturation, and ANC
            
            // Test with mock data loaded
            let mockDataView = view
            mockDataView.loadMockData()
            
            XCTAssertFalse(mockDataView.heartRateData.isEmpty)
            XCTAssertFalse(mockDataView.bodyTemperatureData.isEmpty)
            XCTAssertFalse(mockDataView.oxygenSaturationData.isEmpty)
            XCTAssertFalse(mockDataView.neutrophilCountData.isEmpty)
        })
    }
    
    func testEmptyDataState() throws {
        let view = HKVisualization(presentingAccount: .constant(false))
        
        let inspection = view.inspection
        
        XCTAssertNoThrow(try inspection.inspect { content in
            let list = try content.navigationStack().list()
            
            // Verify empty state messages are shown when no data is available
            let emptyMessages = try list.findAll(text: "No heart rate data available.")
            XCTAssertFalse(emptyMessages.isEmpty)
        })
    }
    
    func testThresholdVisualization() throws {
        let mockData = [
            HKData(date: Date(), sumValue: 101.0, avgValue: 101.0, minValue: 101.0, maxValue: 101.0)
        ]
        
        let view = HKVisualizationItem(
            data: mockData,
            xName: "Time",
            yName: "Temperature (°F)",
            title: "Body Temperature",
            threshold: 99.0,
            scatterData: mockData
        )
        
        let inspection = view.inspection
        
        XCTAssertNoThrow(try inspection.inspect { content in
            // Verify threshold line is present in the chart
            XCTAssertNoThrow(try content.find(RuleMark<Any, Any>.self))
        })
    }
}

// Extension to make HKVisualization and HKVisualizationItem inspectable
extension HKVisualization: Inspectable {}
extension HKVisualizationItem: Inspectable {} 