//
//  HelperFunc.swift
//  NeutroFeverGuard
//
//  Created by dusixian on 2025/2/3.
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
