//
//  NSDateFormatter.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 01/02/16.
//
//

import Foundation

public extension DateFormatter {
    static func dateOnlyFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }

    static func timeOnlyFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .long
        return formatter
    }

    static func dateTimeFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .long
        return formatter
    }

    static func customDateFormatter(dateFormat: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        return formatter
    }

    static func customLocalizedDateFormatter(dateFormat: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate(dateFormat)
        return formatter
    }
}

public extension Date {
    func format(dateFormat: String) -> String {
        let formatter = DateFormatter.customDateFormatter(dateFormat: dateFormat)
        let retVal = formatter.string(from: self)
        return retVal
    }

    func formatDateOnly() -> String {
        let formatter = DateFormatter.dateOnlyFormatter()
        let retVal = formatter.string(from: self)
        return retVal
    }

    func formatDateAndTime() -> String {
        let formatter = DateFormatter.dateTimeFormatter()
        let retVal = formatter.string(from: self)
        return retVal
    }

    internal static func parse(dateFormat: String, dateValue: String, timeZone: TimeZone? = TimeZone.current) -> Date? {
        let formatter = DateFormatter.customDateFormatter(dateFormat: dateFormat)
        formatter.timeZone = timeZone
        let retVal = formatter.date(from: dateValue)
        return retVal
    }

    func formatForJSONAPI() -> String {
        return format(dateFormat: "yyyy-MM-dd")
    }

    static func dateFromJSONAPIFormat(_ date: String?) -> Date? {
        guard let date = date else {
            return nil
        }
        return Date.parse(dateFormat: "yyyy-MM-dd", dateValue: date)
    }

    static func timeFromISO8601(_ time: String?) -> Date? {
        guard let time = time else {
            return nil
        }
        return Date.parse(dateFormat: "yyyy-MM-dd'T'HH:mm:ssZZZZZ", dateValue: time)
    }

    static func dateFromISO8601(string: String) -> Date? {
        let date: Date?
        if #available(iOS 11, *) {
            date = parseISO8601DateiOS11(string: string)
        } else {
            date = parseISO8601DateiOS10(string: string)
        }
        return date
    }

    @available(iOS 11, *)
    private static func parseISO8601DateiOS11(string: String) -> Date? {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [
            .withInternetDateTime, .withDashSeparatorInDate, .withFractionalSeconds, .withColonSeparatorInTime, .withTimeZone,
        ]
        return dateFormatter.date(from: string)
    }

    @available(iOS 10, *)
    private static func parseISO8601DateiOS10(string: String) -> Date? {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [
            .withInternetDateTime, .withDashSeparatorInDate, .withColonSeparatorInTime, .withTimeZone,
        ]
        return dateFormatter.date(from: string.replacingOccurrences(of: "\\.\\d+", with: "", options: .regularExpression))
    }

    static func timeFromJSONAPIFormat(_ time: Double?) -> Date? {
        guard let time = time else {
            return nil
        }
        return Date(timeIntervalSince1970: time)
    }

    internal func cardExpirationFormatForJSONAPI() -> String {
        return format(dateFormat: "yyyy-M")
    }

    static func cardExpirationDateFromJSONAPIFormat(_ date: String?) -> Date? {
        guard let date = date else {
            return nil
        }
        if let retVal = Date.parse(dateFormat: "yyyy-M", dateValue: date) {
            return retVal
        } else {
            return Date.parse(dateFormat: "MM/yy", dateValue: date)
        }
    }
}
