//
// This source file is part of the NeutroFeverGuard based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

enum DataError: Error, Equatable {
    case invalidDate
    case invalidPercentage
    case invalidBloodPressure
    case invalidSeverity
    
    var errorMessage: String {
        switch self {
        case .invalidDate:
            return "date can't be in future"
        case .invalidPercentage:
            return "percentage must be between 0 and 100"
        case .invalidBloodPressure:
            return "blood pressure must be greater than 0"
        case .invalidSeverity:
            return "Severity must be between 1 and 10"
        }
    }
}
