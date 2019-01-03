//
//  NSDateFormatter.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 01/02/16.
//
//

import Foundation

extension DateFormatter {
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

extension Date {
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

  static func parse(dateFormat: String, dateValue: String) -> Date? {
    let formatter = DateFormatter.customDateFormatter(dateFormat: dateFormat)
    let retVal = formatter.date(from: dateValue)
    return retVal
  }

  func formatForJSONAPI() -> String {
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
