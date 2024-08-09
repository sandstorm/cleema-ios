//
//  Created by Kumpels and Friends on 04.10.22.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Foundation

public extension Date {
    static func beginningOf(day: Int, month: Int, year: Int) -> Date? {
        let gregorian = Calendar(identifier: .gregorian)
        guard let date = gregorian.date(from: DateComponents(year: year, month: month, day: day)) else {
            return nil
        }
        return gregorian.startOfDay(for: date)
    }

    static func endOf(day: Int, month: Int, year: Int) -> Date? {
        Calendar(identifier: .gregorian)
            .date(from: DateComponents(year: year, month: month, day: day, hour: 23, minute: 59, second: 59))
    }

    static func momentOn(day: Int, month: Int, year: Int) -> Date {
        Calendar(identifier: .gregorian)
            .date(
                byAdding: .second,
                value: Int.random(in: 1 ..< (60 * 60 * 24)),
                to: beginningOf(day: day, month: month, year: year)!
            )!
    }

    func days(from startDate: Date) -> Int? {
        let calendar = Calendar(identifier: .gregorian)
        // Replace the hour (time) of both dates with noon. (Noon is less likely to be affected by DST changes,
        // timezones, etc.
        // than midnight.)
        guard
            let date1 = calendar.date(
                bySettingHour: 12,
                minute: 00,
                second: 00,
                of: calendar.startOfDay(for: startDate)
            ),
            let date2 = atNoon()
        else { return nil }

        return calendar.dateComponents([.day], from: date1, to: date2).day
    }

    func atNoon() -> Self? {
        let calendar = Calendar.current
        return calendar.date(bySettingHour: 12, minute: 00, second: 00, of: calendar.startOfDay(for: self))
    }

    func add(days: Int) -> Date {
        Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }

    func add(weeks: Int) -> Date {
        Calendar(identifier: .gregorian).date(byAdding: .day, value: weeks * 7, to: self)!
    }

    func add(months: Int) -> Date {
        let calendar = Calendar(identifier: .gregorian)
        return calendar.date(byAdding: .month, value: months, to: calendar.startOfDay(for: self))!
    }

    func add(years: Int) -> Date {
        let calendar = Calendar(identifier: .gregorian)
        return calendar.date(byAdding: .year, value: years, to: calendar.startOfDay(for: self))!
    }

    var startOfDay: Self {
        Calendar.current.startOfDay(for: self)
    }

    var endOfDay: Self {
        Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: self, direction: .forward)!
    }
}

public extension Date {
    func numberOfDays(to date: Date) -> Int {
        Calendar.current.dateComponents([.day], from: self, to: date).day ?? 0
    }

    func numberOfWeeks(to date: Date) -> Int {
        Calendar.current.dateComponents([.weekOfYear], from: self, to: date).weekOfYear ?? 0
    }
}
