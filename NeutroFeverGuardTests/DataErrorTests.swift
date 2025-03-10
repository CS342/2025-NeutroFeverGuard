//
// This source file is part of the NeutroFeverGuard based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

@testable import NeutroFeverGuard
import Testing

@MainActor
struct DataErrorTests {
    @Test
    func testInvalidDateError() {
        let error = DataError.invalidDate
        #expect(error.errorMessage == "date can't be in future")
    }

    @Test
    func testInvalidPercentageError() {
        let error = DataError.invalidPercentage
        #expect(error.errorMessage == "percentage must be between 0 and 100")
    }

    @Test
    func testInvalidBloodPressureError() {
        let error = DataError.invalidBloodPressure
        #expect(error.errorMessage == "blood pressure must be greater than 0")
    }
}
