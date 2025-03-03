//
// This source file is part of the NeutroFeverGuard based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
@testable import NeutroFeverGuard
import Testing

@MainActor
final class DateAndNumberUtilsTests {
    // Test for combineDateAndTime function
    @Test
    func testCombineDateAndTime() {
        let calendar = Calendar.current
        
        // Prepare date and time
        let dateComponents = DateComponents(year: 2025, month: 2, day: 28)
        let timeComponents = DateComponents(hour: 15, minute: 45, second: 30)
        
        let date = calendar.date(from: dateComponents) ?? Date()
        let time = calendar.date(from: timeComponents) ?? Date()
        
        // Combine date and time
        let combinedDate = combineDateAndTime(date, time)
        let combinedComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: combinedDate)
        
        // Assertions
        #expect(combinedComponents.year == 2025)
        #expect(combinedComponents.month == 2)
        #expect(combinedComponents.day == 28)
        #expect(combinedComponents.hour == 15)
        #expect(combinedComponents.minute == 45)
        #expect(combinedComponents.second == 30)
    }
    
    // Test for parseLocalizedNumber function
    @Test
    func testParseLocalizedNumber() {
        // Test with valid numbers
        #expect(parseLocalizedNumber("1234.56") == 1234.56)
        #expect(parseLocalizedNumber("0.99") == 0.99)
        #expect(parseLocalizedNumber("-42.42") == -42.42)
        
        // Test with invalid input
        #expect(parseLocalizedNumber("abc") == nil)
        #expect(parseLocalizedNumber("1234,56abc") == nil)
    }
}
