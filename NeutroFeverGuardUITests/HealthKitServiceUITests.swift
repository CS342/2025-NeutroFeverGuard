import HealthKit
import Testing
import XCTest
import XCTHealthKit

@MainActor
struct HealthKitServiceUITests {
    @Test
    func testAddTemperature() async throws {
        let app = XCUIApplication()
        app.launchArguments = ["--skipOnboarding"]
        app.launch()
        
        app.buttons["Add Data"].tap()
        app.buttons["Temperature"].tap()
        
        let datePicker = app.datePickers.firstMatch
        datePicker.tap()
        
        app.textFields["Temperature"].tap()
        app.textFields["Temperature"].typeText("98.6")
        
        app.buttons["Add"].tap()
        
        #expect(app.buttons["Add Data"].exists)
        #expect(!app.alerts.element.exists)
    }
    
    @Test
    func testAddHeartRate() async throws {
        let app = XCUIApplication()
        app.launchArguments = ["--skipOnboarding"]
        app.launch()
        
        app.buttons["Add Data"].tap()
        app.buttons["Heart Rate"].tap()
        
        app.textFields["Heart Rate (BPM)"].tap()
        app.textFields["Heart Rate (BPM)"].typeText("75")
        
        app.buttons["Add"].tap()
        
        #expect(app.buttons["Add Data"].exists)
        #expect(!app.alerts.element.exists)
    }
    
    @Test
    func testAddOxygenSaturation() async throws {
        let app = XCUIApplication()
        app.launchArguments = ["--skipOnboarding"]
        app.launch()
        
        app.buttons["Add Data"].tap()
        app.buttons["Oxygen Saturation"].tap()
        
        app.textFields["Oxygen Saturation (%)"].tap()
        app.textFields["Oxygen Saturation (%)"].typeText("98")
        
        app.buttons["Add"].tap()
        
        #expect(app.buttons["Add Data"].exists)
        #expect(!app.alerts.element.exists)
    }
    
    @Test
    func testAddBloodPressure() async throws {
        let app = XCUIApplication()
        app.launchArguments = ["--skipOnboarding"]
        app.launch()
        
        app.buttons["Add Data"].tap()
        app.buttons["Blood Pressure"].tap()
        
        app.textFields["Systolic"].tap()
        app.textFields["Systolic"].typeText("120")
        
        app.textFields["Diastolic"].tap()
        app.textFields["Diastolic"].typeText("80")
        
        app.buttons["Add"].tap()
        
        let healthStore = HKHealthStore()
        let systolicType = HKQuantityType(.bloodPressureSystolic)
        let diastolicType = HKQuantityType(.bloodPressureDiastolic)
        
        #expect(app.buttons["Add Data"].exists)
        #expect(!app.alerts.element.exists)
    }
}
