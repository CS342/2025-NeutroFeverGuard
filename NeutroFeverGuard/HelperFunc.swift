//
// This source file is part of the NeutroFeverGuard based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation

func combineDateAndTime(_ date: Date, _ time: Date) -> Date {
    let calendar = Calendar.current
    let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
    let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: time)

    return calendar.date(from: DateComponents(
        year: dateComponents.year,
        month: dateComponents.month,
        day: dateComponents.day,
        hour: timeComponents.hour,
        minute: timeComponents.minute,
        second: timeComponents.second
    )) ?? Date()
}

func parseLocalizedNumber(_ input: String) -> Double? {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.locale = Locale.current
    
    if let number = formatter.number(from: input) {
        return number.doubleValue
    }
    return nil
}
