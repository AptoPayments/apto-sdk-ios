//
//  NSDateTests.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 20/03/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import XCTest
@testable import ShiftSDK

class NSDateTest: XCTestCase {
  
  func testDifferenceToYears() {
    
    // Given
    let fromDate = dateWith(year: 2015, month: 1, day: 1)
    let toDate = dateWith(year: 2016, month: 1, day: 1)
    
    // Then
    XCTAssertEqual(fromDate.differenceTo(date: toDate, units: .year), 1)
    
  }
  
  func testDifferenceToMonths() {
    
    // Given
    let fromDate = dateWith(year: 2015, month: 1, day: 1)
    let toDate = dateWith(year: 2016, month: 2, day: 1)
    
    // Then
    XCTAssertEqual(fromDate.differenceTo(date: toDate, units: .month), 13)
    
  }

  func testDifferenceToDays() {
    
    // Given
    let fromDate = dateWith(year: 2015, month: 1, day: 31)
    let toDate = dateWith(year: 2015, month: 2, day: 12)
    
    // Then
    XCTAssertEqual(fromDate.differenceTo(date: toDate, units: .day), 12)
    
  }
  
  func testDifferenceToHours() {
    
    // Given
    let fromDate = dateWith(year: 2015, month: 1, day: 1, hour: 23, minute: 0, second: 0)
    let toDate = dateWith(year: 2015, month: 1, day: 2, hour: 6, minute: 0, second: 0)
    
    // Then
    XCTAssertEqual(fromDate.differenceTo(date: toDate, units: .hour), 7)
    
  }

  func testDifferenceToMinutes() {
    
    // Given
    let fromDate = dateWith(year: 2015, month: 1, day: 1, hour: 13, minute: 0, second: 0)
    let toDate = dateWith(year: 2015, month: 1, day: 1, hour: 14, minute: 10, second: 0)
    
    // Then
    XCTAssertEqual(fromDate.differenceTo(date: toDate, units: .minute), 70)
    
  }

  func testDifferenceToSeconds() {
    
    // Given
    let fromDate = dateWith(year: 2015, month: 1, day: 1, hour: 12, minute: 0, second: 0)
    let toDate = dateWith(year: 2015, month: 1, day: 1, hour: 12, minute: 5, second: 10)
    
    // Then
    XCTAssertEqual(fromDate.differenceTo(date: toDate, units: .second), 310)
    
  }
  
  func testDifferenceToInvalidUnits() {
    
    // Given
    let fromDate = dateWith(year: 2015, month: 1, day: 1, hour: 12, minute: 0, second: 0)
    let toDate = dateWith(year: 2015, month: 1, day: 1, hour: 12, minute: 5, second: 10)
    
    // Then
    XCTAssertEqual(fromDate.differenceTo(date: toDate, units: .weekday), 0)
    
  }
  
  func testIsGreaterThanFalse() {
    
    // Given
    let fromDate = dateWith(year: 2015, month: 1, day: 1, hour: 12, minute: 0, second: 0)
    let toDate = dateWith(year: 2016, month: 1, day: 1, hour: 12, minute: 5, second: 10)
    
    // Then
    XCTAssertFalse(fromDate.isGreaterThanDate(toDate))
    
  }

  func testIsGreaterThanTrue() {
    
    // Given
    let fromDate = dateWith(year: 2015, month: 1, day: 1, hour: 12, minute: 0, second: 0)
    let toDate = dateWith(year: 2016, month: 1, day: 1, hour: 12, minute: 5, second: 10)
    
    // Then
    XCTAssertTrue(toDate.isGreaterThanDate(fromDate))
    
  }
  
  func testIsLessThanFalse() {
    
    // Given
    let fromDate = dateWith(year: 2015, month: 1, day: 1, hour: 12, minute: 0, second: 0)
    let toDate = dateWith(year: 2016, month: 1, day: 1, hour: 12, minute: 5, second: 10)
    
    // Then
    XCTAssertFalse(toDate.isLessThanDate(fromDate))
    
  }
  
  func testIsLessThanTrue() {
    
    // Given
    let fromDate = dateWith(year: 2015, month: 1, day: 1, hour: 12, minute: 0, second: 0)
    let toDate = dateWith(year: 2016, month: 1, day: 1, hour: 12, minute: 5, second: 10)
    
    // Then
    XCTAssertTrue(fromDate.isLessThanDate(toDate))
    
  }
  
  func testEqualToDateFalse() {
    
    // Given
    let fromDate = dateWith(year: 2015, month: 1, day: 1, hour: 12, minute: 0, second: 0)
    let toDate = dateWith(year: 2016, month: 1, day: 1, hour: 12, minute: 5, second: 10)
    
    // Then
    XCTAssertFalse(toDate.equalToDate(fromDate))
    
  }
  
  func testIsEqualToDateTrue() {
    
    // Given
    let fromDate = dateWith(year: 2015, month: 1, day: 1, hour: 12, minute: 0, second: 0)
    let toDate = dateWith(year: 2015, month: 1, day: 1, hour: 12, minute: 0, second: 0)
    
    // Then
    XCTAssertTrue(fromDate.equalToDate(toDate))
    
  }
  
  func testAddYear() {
    
    // Given
    let fromDate = dateWith(year: 2015, month: 1, day: 1, hour: 12, minute: 0, second: 0)
    let expectedDate = dateWith(year: 2016, month: 1, day: 1, hour: 12, minute: 0, second: 0)
    
    // When
    let toDate = fromDate.add(1, units: .year)!
    
    // Then
    XCTAssertTrue(toDate.equalToDate(expectedDate))
    
  }
  
  func testAddMonth() {
    
    // Given
    let fromDate = dateWith(year: 2015, month: 1, day: 1, hour: 12, minute: 0, second: 0)
    let expectedDate = dateWith(year: 2015, month: 5, day: 1, hour: 12, minute: 0, second: 0)
    
    // When
    let toDate = fromDate.add(4, units: .month)!
    
    // Then
    XCTAssertTrue(toDate.equalToDate(expectedDate))
    
  }
  
  func testAddDay() {
    
    // Given
    let fromDate = dateWith(year: 2015, month: 1, day: 1, hour: 12, minute: 0, second: 0)
    let expectedDate = dateWith(year: 2015, month: 1, day: 15, hour: 12, minute: 0, second: 0)
    
    // When
    let toDate = fromDate.add(14, units: .day)!
    
    // Then
    XCTAssertTrue(toDate.equalToDate(expectedDate))
    
  }

  func dateWith(year:Int, month:Int, day:Int) -> Date {
    return dateWith(year: year, month: month, day: day, hour: 0, minute: 0, second: 0)
  }
  
  func dateWith(year:Int, month:Int, day:Int, hour:Int, minute:Int, second:Int) -> Date {
    var components = DateComponents()
    components.year = year
    components.month = month
    components.day = day
    components.hour = hour
    components.minute = minute
    components.second = second
    return Calendar.current.date(from: components)!
  }
  
}
