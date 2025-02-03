//
//  DataError.swift
//  NeutroFeverGuard
//
//  Created by dusixian on 2025/2/2.
//

enum DataError: Error, Equatable {
    case invalidDate
    case invalidPercentage
    case invalidBloodPressure
    
    var errorMessage: String {
        switch self {
        case .invalidDate:
            return "date can't be in future"
        case .invalidPercentage:
            return "percentage must be between 0 and 100"
        case .invalidBloodPressure:
            return "blood pressure must be greater than 0"
        }
    }
}
