//
//  NSDateFormatter.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 01/02/16.
//
//

import Foundation

extension DateFormatter {
  public static func dateOnlyFormatter() -> DateFormatter {
    let formatter = DateFormatter()
    formatter.dateStyle = .long
    formatter.timeStyle = .none
    return formatter
  }

  public static func timeOnlyFormatter() -> DateFormatter {
    let formatter = DateFormatter()
    formatter.dateStyle = .none
    formatter.timeStyle = .long
    return formatter
  }

  public static func dateTimeFormatter() -> DateFormatter {
    let formatter = DateFormatter()
    formatter.dateStyle = .long
    formatter.timeStyle = .long
    return formatter
  }

  public static func customDateFormatter(dateFormat: String) -> DateFormatter {
    let formatter = DateFormatter()
    formatter.dateFormat = dateFormat
    return formatter
  }

  public static func customLocalizedDateFormatter(dateFormat: String) -> DateFormatter {
    let formatter = DateFormatter()
    formatter.setLocalizedDateFormatFromTemplate(dateFormat)
    return formatter
  }
}

extension Date {
  public func format(dateFormat: String) -> String {
    let formatter = DateFormatter.customDateFormatter(dateFormat: dateFormat)
    let retVal = formatter.string(from: self)
    return retVal
  }

  public func formatDateOnly() -> String {
    let formatter = DateFormatter.dateOnlyFormatter()
    let retVal = formatter.string(from: self)
    return retVal
  }

  public func formatDateAndTime() -> String {
    let formatter = DateFormatter.dateTimeFormatter()
    let retVal = formatter.string(from: self)
    return retVal
  }

  static func parse(dateFormat: String, dateValue: String, timeZone: TimeZone? = TimeZone.current) -> Date? {
    let formatter = DateFormatter.customDateFormatter(dateFormat: dateFormat)
    formatter.timeZone = timeZone
    let retVal = formatter.date(from: dateValue)
    return retVal
  }

  public func formatForJSONAPI() -> String {
    return self.format(dateFormat: "yyyy-MM-dd")
  }

  public static func dateFromJSONAPIFormat(_ date: String?) -> Date? {
    guard let date = date else {
      return nil
    }
    return Date.parse(dateFormat: "yyyy-MM-dd", dateValue: date)
  }

  public static func timeFromISO8601(_ time: String?) -> Date? {
    guard let time = time else {
      return nil
    }
    return Date.parse(dateFormat: "yyyy-MM-dd'T'HH:mm:ssZZZZZ", dateValue: time)
  }

  public static func dateFromISO8601(string: String) -> Date? {
    let date: Date?
    if #available(iOS 11, *) {
      date = parseISO8601DateiOS11(string: string)
    }
    else {
      date = parseISO8601DateiOS10(string: string)
    }
    return date
  }

  @available(iOS 11, *)
  private static func parseISO8601DateiOS11(string: String) -> Date? {
    let dateFormatter = ISO8601DateFormatter()
    dateFormatter.formatOptions = [
      .withInternetDateTime, .withDashSeparatorInDate, .withFractionalSeconds, .withColonSeparatorInTime, .withTimeZone
    ]
    return dateFormatter.date(from: string)
  }

  @available(iOS 10, *)
  private static func parseISO8601DateiOS10(string: String) -> Date? {
    let dateFormatter = ISO8601DateFormatter()
    dateFormatter.formatOptions = [
      .withInternetDateTime, .withDashSeparatorInDate, .withColonSeparatorInTime, .withTimeZone
    ]
    return dateFormatter.date(from: string.replacingOccurrences(of: "\\.\\d+", with: "", options: .regularExpression))
  }

  public static func timeFromJSONAPIFormat(_ time: Double?) -> Date? {
    guard let time = time else {
      return nil
    }
    return Date(timeIntervalSince1970: time)
  }

  func cardExpirationFormatForJSONAPI() -> String {
    return self.format(dateFormat: "yyyy-M")
  }

  public static func cardExpirationDateFromJSONAPIFormat(_ date: String?) -> Date? {
    guard let date = date else {
      return nil
    }
    if let retVal = Date.parse(dateFormat: "yyyy-M", dateValue: date) {
      return retVal
    }
    else {
      return Date.parse(dateFormat: "MM/yy", dateValue: date)
    }
  }
}
