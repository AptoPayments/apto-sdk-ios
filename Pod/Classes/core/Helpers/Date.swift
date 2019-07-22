//
//  NSDate.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 11/02/16.
//
//

import Foundation

extension Date {

  func differenceTo(date:Date, units:Calendar.Component) -> Int {
    let cal = Calendar.current
    let components = cal.dateComponents([units], from: self, to: date)
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
  }

  public func isGreaterThanDate(_ dateToCompare: Date) -> Bool {
    var isGreater = false
    if self.compare(dateToCompare) == ComparisonResult.orderedDescending {
      isGreater = true
    }
    return isGreater
  }

  public func isLessThanDate(_ dateToCompare: Date) -> Bool {
    var isLess = false
    if self.compare(dateToCompare) == ComparisonResult.orderedAscending {
      isLess = true
    }
    return isLess
  }

  func equalToDate(_ dateToCompare: Date) -> Bool {
    var isEqualTo = false
    if self.compare(dateToCompare) == ComparisonResult.orderedSame {
      isEqualTo = true
    }
    return isEqualTo
  }

  public func add(_ count: Int, units: Calendar.Component) -> Date? {
    var components: DateComponents = DateComponents()
    components.setValue(count, for: units);
    return Calendar.current.date(byAdding: components, to: self)
  }

  public var year: Int {
    return Calendar.current.component(.year, from: self)
  }

  public var month: Int {
    return Calendar.current.component(.month, from: self)
  }

  var day: Int {
    return Calendar.current.component(.day, from: self)
  }

  public var startOfMonth: Date? {
    let calendar = Calendar.current
    return calendar.date(from: calendar.dateComponents([.year, .month], from: calendar.startOfDay(for: self)))
  }

  public var endOfMonth: Date? {
    guard let startOfMonth = self.startOfMonth else { return nil }
    return Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth)
  }
}
