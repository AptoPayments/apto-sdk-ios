//
//  ResultTest.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 20/03/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import XCTest
@testable import ShiftSDK

class ResultTest: XCTestCase {

  func testInitWithCoderThrowsException() {
    
    // Given
    let aCoder = NSCoder()
    
    // Then
    expectFatalError("Not implemented") {
      let _ = ServiceError(coder: aCoder)
    }
    
  }
  
  func testErrorDomain () {
    
    // Given
    let errorCode = ServiceError.ErrorCodes.incompleteApplicationData
    
    // When
    let serviceError = ServiceError(code: errorCode)
    
    // Then
    XCTAssertTrue(serviceError.domain == kServiceErrorDomain)
    
  }
  
  func testInitWithErrorCode() {
    
    // Given
    let errorCode = ServiceError.ErrorCodes.incompleteApplicationData
    
    // When
    let serviceError = ServiceError(code: errorCode)
    
    // Then
    XCTAssertTrue(serviceError.code == errorCode.rawValue)
    
  }
  
  func testInitWithReason() {
    
    // Given
    let errorCode = ServiceError.ErrorCodes.incompleteApplicationData
    let reason = "My Error Reason"
    
    // When
    let serviceError = ServiceError(code: errorCode, reason: reason)
    
    // Then
    XCTAssertTrue(serviceError.userInfo[NSLocalizedFailureReasonErrorKey]! as! String == reason)

  }
  
  func testInitWithReasonSetsLocalizedDescription() {
    
    // Given
    let errorCode = ServiceError.ErrorCodes.internalIncosistencyError
    let description = "error.service.internalIncosistency"
    
    // When
    let serviceError = ServiceError(code: errorCode)
    
    // Then
    XCTAssertTrue(serviceError.userInfo[NSLocalizedDescriptionKey]! as! String == description)
    
  }
  
  func testInitWithReasonSetsLocalizedDescription1() {
    
    // Given
    let errorCode = ServiceError.ErrorCodes.jsonError
    let description = "error.service.jsonError"
    
    // When
    let serviceError = ServiceError(code: errorCode)
    
    // Then
    XCTAssertTrue(serviceError.userInfo[NSLocalizedDescriptionKey]! as! String == description)
    
  }
  
  func testInitWithReasonSetsLocalizedDescription2() {
    
    // Given
    let errorCode = ServiceError.ErrorCodes.notInitialized
    let description = "error.service.notInitialized"
    
    // When
    let serviceError = ServiceError(code: errorCode)
    
    // Then
    XCTAssertTrue(serviceError.userInfo[NSLocalizedDescriptionKey]! as! String == description)
    
  }
  
  func testInitWithReasonSetsLocalizedDescription3() {
    
    // Given
    let errorCode = ServiceError.ErrorCodes.wrongSessionState
    let description = "error.service.wrongSessionState"
    
    // When
    let serviceError = ServiceError(code: errorCode)
    
    // Then
    XCTAssertTrue(serviceError.userInfo[NSLocalizedDescriptionKey]! as! String == description)
    
  }
  
  func testInitWithReasonSetsLocalizedDescription4() {
    
    // Given
    let errorCode = ServiceError.ErrorCodes.invalidAddress
    let description = "error.service.invalidAddress"
    
    // When
    let serviceError = ServiceError(code: errorCode)
    
    // Then
    XCTAssertTrue(serviceError.userInfo[NSLocalizedDescriptionKey]! as! String == description)
    
  }
  
  func testInitWithReasonSetsLocalizedDescription5() {
    
    // Given
    let errorCode = ServiceError.ErrorCodes.incompleteApplicationData
    let description = "error.service.incompleteApplicationData"
    
    // When
    let serviceError = ServiceError(code: errorCode)
    
    // Then
    XCTAssertTrue(serviceError.userInfo[NSLocalizedDescriptionKey]! as! String == description)
    
  }
  
}
