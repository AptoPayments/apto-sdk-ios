//
//  BackendErrorTests.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 20/03/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import XCTest
import SwiftyJSON
@testable import ShiftSDK

class BackendErrorTest: XCTestCase {
  func testInitWithCoderThrowsException() {
    // Given
    let aCoder = NSCoder()

    // Then
    expectFatalError("Not implemented") {
      let _ = BackendError(coder: aCoder)
    }
  }

  func testErrorDomain () {
    // Given
    let errorCode = BackendError.ErrorCodes.serviceUnavailable

    // When
    let serviceError = BackendError(code: errorCode)

    // Then
    XCTAssertTrue(serviceError.domain == kBackendErrorDomain)
  }

  func testInitWithErrorCode() {
    // Given
    let errorCode = BackendError.ErrorCodes.serviceUnavailable

    // When
    let serviceError = BackendError(code: errorCode)

    // Then
    XCTAssertTrue(serviceError.code == errorCode.rawValue)
  }

  func testInitWithReason() {
    // Given
    let errorCode = BackendError.ErrorCodes.incorrectParameters
    let reason = "My Error Reason"

    // When
    let serviceError = BackendError(code: errorCode, reason: reason)

    // Then
    XCTAssertTrue(serviceError.userInfo[NSLocalizedFailureReasonErrorKey]! as! String == reason)
  }

  func testInitWithReasonSetsLocalizedDescription() {
    // Given
    let errorCode = BackendError.ErrorCodes.undefinedError
    let description = "Something went wrong."

    // When
    let serviceError = BackendError(code: errorCode)

    // Then
    XCTAssertTrue(serviceError.userInfo[NSLocalizedDescriptionKey]! as! String == description)
  }

  func testInitWithReasonSetsLocalizedDescription1() {
    // Given
    let errorCode = BackendError.ErrorCodes.serviceUnavailable
    let description = "Something went wrong."

    // When
    let serviceError = BackendError(code: errorCode)

    // Then
    XCTAssertTrue(serviceError.userInfo[NSLocalizedDescriptionKey]! as! String == description)
  }

  func testInitWithReasonSetsLocalizedDescription2() {
    // Given
    let errorCode = BackendError.ErrorCodes.incorrectParameters
    let description = "Something went wrong."

    // When
    let serviceError = BackendError(code: errorCode)

    // Then
    XCTAssertTrue(serviceError.userInfo[NSLocalizedDescriptionKey]! as! String == description)
  }

  func testInitWithReasonSetsLocalizedDescription3() {
    // Given
    let errorCode = BackendError.ErrorCodes.invalidSession
    let description = "For your security, your session has timed out due to inactivity."

    // When
    let serviceError = BackendError(code: errorCode)

    // Then
    XCTAssertTrue(serviceError.userInfo[NSLocalizedDescriptionKey]! as! String == description)
  }

  func testInitWithReasonSetsLocalizedDescription4() {
    // Given
    let errorCode = BackendError.ErrorCodes.other
    let description = "Something went wrong."

    // When
    let serviceError = BackendError(code: errorCode)
    // Then
    XCTAssertTrue(serviceError.userInfo[NSLocalizedDescriptionKey]! as! String == description)
  }

  func testInvalidSessionError() {
    // Given
    let errorCode = BackendError.ErrorCodes.invalidSession
    let serviceError = BackendError(code: errorCode)

    // When
    let isInvalidSessionError = serviceError.invalidSessionError()

    // Then
    XCTAssertTrue(isInvalidSessionError)
  }

  func testInvalidSessionErrorFalse1() {
    // Given
    let errorCode = BackendError.ErrorCodes.undefinedError
    let serviceError = BackendError(code: errorCode)

    // When
    let isInvalidSessionError = serviceError.invalidSessionError()

    // Then
    XCTAssertFalse(isInvalidSessionError)
  }

  func testInvalidSessionErrorFalse2() {
    // Given
    let errorCode = BackendError.ErrorCodes.serviceUnavailable
    let serviceError = BackendError(code: errorCode)

    // When
    let isInvalidSessionError = serviceError.invalidSessionError()

    // Then
    XCTAssertFalse(isInvalidSessionError)
  }

  func testInvalidSessionErrorFalse3() {
    // Given
    let errorCode = BackendError.ErrorCodes.incorrectParameters
    let serviceError = BackendError(code: errorCode)

    // When
    let isInvalidSessionError = serviceError.invalidSessionError()

    // Then
    XCTAssertFalse(isInvalidSessionError)
  }

  func testInvalidSessionErrorFalse4() {
    // Given
    let errorCode = BackendError.ErrorCodes.other
    let serviceError = BackendError(code: errorCode)

    // When
    let isInvalidSessionError = serviceError.invalidSessionError()

    // Then
    XCTAssertFalse(isInvalidSessionError)
  }

  func testJSONParsingNoErrorCodeReturnsNil() {
    // Given
    let json: JSON = ["message": "My Message"]
    // When
    let backendError = json.backendError
    // Then
    XCTAssertNil(backendError)
  }

  func testJSONParsingInvalidCodeReturnsUndefinedError() {
    // Given
    let json: JSON = ["code": 45, "message": "My Message"]

    // When
    let backendError = json.backendError

    // Then
    XCTAssertNotNil(backendError)
    XCTAssertEqual(backendError?.code, BackendError.ErrorCodes.undefinedError.rawValue)
    XCTAssertEqual(backendError?.rawCode, 45)
  }

  func testJSONParsingCorrectJSONReturnsBackendError() {
    // Given
    let json: JSON = ["code": 1, "message": "My Message"]

    // When
    let backendError = json.backendError

    // Then
    XCTAssertNotNil(backendError)
  }

  func testServerMaintenanceErrorServerMaintenanceReturnTrue() {
    // Given
    let error = BackendError(code: .serverMaintenance)

    // When
    let isServerMaintenance = error.serverMaintenance()

    // Then
    XCTAssertTrue(isServerMaintenance)
  }

  func testOtherErrorServerMaintenanceReturnFalse() {
    // Given
    let error = BackendError(code: .invalidSession)

    // When
    let isServerMaintenance = error.serverMaintenance()

    // Then
    XCTAssertFalse(isServerMaintenance)
  }

  func testNetworkNotAvailableNetworkNotAvailableReturnTrue() {
    // Given
    let error = BackendError(code: .networkNotAvailable)

    // When
    let isNetworkNotAvailable = error.networkNotAvailable()

    // Then
    XCTAssertTrue(isNetworkNotAvailable)
  }

  func testOtherErrorNetworkNotAvailableReturnFalse() {
    // Given
    let error = BackendError(code: .invalidSession)

    // When
    let isNetworkNotAvailable = error.networkNotAvailable()

    // Then
    XCTAssertFalse(isNetworkNotAvailable)
  }
}
