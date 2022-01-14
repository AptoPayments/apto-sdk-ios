//
//  NSDate.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 11/02/16.
//
//

import Foundation

public extension Date {
    internal func differenceTo(date: Date, units: Calendar.Component) -> Int {
        let cal = Calendar.current
        let components = cal.dateComponents([units], from: self, to: date)
        // swiftlint:disable force_unwrapping
        switch units {
        case Calendar.Component.year:
            return components.year!
        case Calendar.Component.month:
            return components.month!
        case Calendar.Component.day:
            return components.day!
        case Calendar.Component.hour:
            return components.hour!
        case Calendar.Component.minute:
            return components.minute!
        case Calendar.Component.second:
            return components.second!
        default:
            return 0
        }
        // swiftlint:enable force_unwrapping
    }

    func isGreaterThanDate(_ dateToCompare: Date) -> Bool {
        var isGreater = false
        if compare(dateToCompare) == ComparisonResult.orderedDescending {
            isGreater = true
        }
        return isGreater
    }

    func isLessThanDate(_ dateToCompare: Date) -> Bool {
        var isLess = false
        if compare(dateToCompare) == ComparisonResult.orderedAscending {
            isLess = true
        }
        return isLess
    }

    internal func equalToDate(_ dateToCompare: Date) -> Bool {
        var isEqualTo = false
        if compare(dateToCompare) == ComparisonResult.orderedSame {
            isEqualTo = true
        }
        return isEqualTo
    }

    func add(_ count: Int, units: Calendar.Component) -> Date? {
        var components = DateComponents()
        components.setValue(count, for: units)
        return Calendar.current.date(byAdding: components, to: self)
    }

    var year: Int {
        return Calendar.current.component(.year, from: self)
    }

    var month: Int {
        return Calendar.current.component(.month, from: self)
    }

    internal var day: Int {
        return Calendar.current.component(.day, from: self)
    }

    var startOfMonth: Date? {
        let calendar = Calendar.current
        return calendar.date(from: calendar.dateComponents([.year, .month], from: calendar.startOfDay(for: self)))
    }

    var endOfMonth: Date? {
        guard let startOfMonth = startOfMonth else { return nil }
        return Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth)
    }

    internal func nextDay(in calendar: Calendar) -> Date? {
        return calendar.date(byAdding: .day, value: 1, to: self)
    }

    func dateBySubstractingDays(days: Int) -> Date? {
        return Calendar.current.date(byAdding: .day, value: -1 * days, to: self)
    }

    func weekdaysBetween(endDate: Date) -> Int {
        var calendar = Calendar(identifier: .gregorian)
        if let utcTimeZone = TimeZone(abbreviation: "UTC") {
            calendar.timeZone = utcTimeZone
        }
        var weekDays = 0
        var date = self
        if calendar.isDate(date, inSameDayAs: endDate) {
            return 0
        }
        date = calendar.startOfDay(for: date)
        while date < endDate {
            if !calendar.isDateInWeekend(date) {
                weekDays += 1
            }

            guard let nextDay = date.nextDay(in: calendar) else {
                fatalError("Failed to instantiate a next day")
            }

            date = nextDay
        }

        return weekDays - 1
    }

    func addBusinessDays(days: Int) -> Date {
        let calendar = Calendar.current
        var dayPos = 0
        var currentDate = self
        while dayPos < days {
            guard let nextDate = currentDate.nextDay(in: calendar) else {
                fatalError("Failed to instantiate a next day")
            }
            if !calendar.isDateInWeekend(nextDate) {
                dayPos += 1
            }
            currentDate = nextDate
        }
        return currentDate
    }

    static func currentDate() -> Date {
        return Date()
    }
}
