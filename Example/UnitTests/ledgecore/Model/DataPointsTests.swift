//
//  DataPointsTests.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 12/05/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import XCTest
@testable import ShiftSDK

class DataPointsTests: LinkTestCase {
  func testDataPointInitialization() {
    // Given
    let type = DataPointType.creditScore
    let verified = true

    // When
    let sut = DataPoint(type: type, verified: verified)

    // Then
    XCTAssertEqual(sut.type, type)
    XCTAssertEqual(sut.verified, verified)
  }

  func testInvalidateDatapoint() {
    // Given
    let sut = DataPoint(type: .address, verified: true)
    sut.verification = Verification(verificationId: "VERIFICATION_ID",
                                    verificationType: .phoneNumber,
                                    status: VerificationStatus.passed,
                                    secret: "VERIFICATION_SECRET")

    // When
    sut.invalidateVerification()

    // Then
    XCTAssertFalse(sut.verified!) // swiftlint:disable:this force_unwrapping
    XCTAssertNil(sut.verification)
  }

  func testCopyDataPoint() {
    // Given
    let verification = Verification(verificationId: "VERIFICATION_ID",
                                    verificationType: .phoneNumber,
                                    status: VerificationStatus.passed,
                                    secret: "VERIFICATION_SECRET")
    var mockVerification = MockVerification(verificationId: "VERIFICATION_ID",
                                            verificationType: .phoneNumber,
                                            status: VerificationStatus.passed,
                                            secret: "VERIFICATION_SECRET")
    mockVerification.registerReturnValue(methodName: "copyWithZone", returnValue: verification)

    // When
    let sut = DataPoint(type: .address, verified: true)
    sut.verification = mockVerification
    let copiedDataPoint = sut.copy() as? DataPoint

    // Then
    XCTAssertEqual(copiedDataPoint?.type, sut.type)
    XCTAssertEqual(copiedDataPoint?.verified, sut.verified)
    XCTAssertEqual(copiedDataPoint?.verification!, verification) // swiftlint:disable:this force_unwrapping
  }

  func testEqualDataPointDifferentTypeFalse() {
    // Given
    let dataPoint1 = DataPoint (type: .address, verified: false)
    let dataPoint2 = DataPoint (type: .personalName, verified: false)

    // When
    let equal = dataPoint1 == dataPoint2

    // Then
    XCTAssertFalse(equal)
  }

  func testEqualDataPointDifferentVerifiedFalse() {
    // Given
    let dataPoint1 = DataPoint (type: .address, verified: false)
    let dataPoint2 = DataPoint (type: .address, verified: true)

    // When
    let equal = dataPoint1 == dataPoint2

    // Then
    XCTAssertFalse(equal)
  }

  func testEqualDataPointDifferentVerificationFalse() {
    // Given
    let dataPoint1 = DataPoint (type: .address, verified: true)
    dataPoint1.verification = Verification(verificationId: "VERIFICATION_ID",
                                           verificationType: .phoneNumber,
                                           status: .passed)
    let dataPoint2 = DataPoint (type: .address, verified: true)

    // When
    let equal = dataPoint1 == dataPoint2

    // Then
    XCTAssertFalse(equal)
  }

  func testEqualDataPointDifferentVerificationsFalse() {
    // Given
    let dataPoint1 = DataPoint (type: .address, verified: true)
    dataPoint1.verification = Verification(verificationId: "VERIFICATION_ID_1",
                                           verificationType: .phoneNumber,
                                           status: .passed)
    let dataPoint2 = DataPoint (type: .address, verified: true)
    dataPoint2.verification = Verification(verificationId: "VERIFICATION_ID_2",
                                           verificationType: .phoneNumber,
                                           status: .passed)

    // When
    let equal = dataPoint1 == dataPoint2

    // Then
    XCTAssertFalse(equal)
  }

  func testEqualDataPoint() {
    // Given
    let dataPoint1 = DataPoint (type: .address, verified: true)
    dataPoint1.verification = Verification(verificationId: "VERIFICATION_ID_1",
                                           verificationType: .phoneNumber,
                                           status: .passed)
    let dataPoint2 = DataPoint (type: .address, verified: true)
    dataPoint2.verification = Verification(verificationId: "VERIFICATION_ID_1",
                                           verificationType: .phoneNumber,
                                           status: .passed)

    // When
    let equal = dataPoint1 == dataPoint2

    // Then
    XCTAssertTrue(equal)
  }
}

class DataPointListTests: LinkTestCase {
  func testDataPointListAddSingleDataPoint() {
    // Given
    let sut = DataPointList()
    let dataPoint = DataPoint(type: .address, verified: true)

    // When
    sut.add(dataPoint: dataPoint)

    // Then
    XCTAssertEqual(sut.dataPoints[.address]!, [dataPoint]) // swiftlint:disable:this force_unwrapping
  }

  func testDataPointListAddMultipleDataPoints() {
    // Given
    let sut = DataPointList()
    let dataPoint1 = DataPoint(type: .address, verified: true)
    let dataPoint2 = DataPoint(type: .address, verified: false)

    // When
    sut.add(dataPoint: dataPoint1)
    sut.add(dataPoint: dataPoint2)

    // Then
    XCTAssertEqual(sut.dataPoints[.address]!, [dataPoint1, dataPoint2]) // swiftlint:disable:this force_unwrapping
  }

  func testDataPointListRemoveDataPoint() {
    // Given
    let sut = DataPointList()
    let dataPoint1 = DataPoint(type: .address, verified: true)
    let dataPoint2 = DataPoint(type: .address, verified: false)

    // When
    sut.add(dataPoint: dataPoint1)
    sut.add(dataPoint: dataPoint2)
    sut.removeDataPointsOf(type: .address)

    // Then
    XCTAssertNil(sut.dataPoints[.address])
  }

  func testGetForcingDataPointOfReturnsDefaultDataPoint() {
    // Given
    let sut = DataPointList()
    let dataPoint = DataPoint(type: .birthDate, verified: true)

    // When
    let returnedDataPoint = sut.getForcingDataPointOf(type: .birthDate, defaultValue: dataPoint)

    // Then
    XCTAssertEqual(returnedDataPoint, dataPoint)
  }

  func testGetForcingDataPointOfReturnsExistingDataPoint() {
    // Given
    let sut = DataPointList()
    let dataPoint1 = PersonalName(firstName: "FIRST_NAME_1", lastName: "LAST_NAME_1")
    sut.add(dataPoint: dataPoint1)

    // When
    let dataPoint2 = PersonalName(firstName: "FIRST_NAME_2", lastName: "LAST_NAME_2")
    let returnedDataPoint = sut.getForcingDataPointOf(type: .personalName, defaultValue: dataPoint2)

    // Then
    XCTAssertEqual(returnedDataPoint, dataPoint1)
  }

  // swiftlint:disable force_cast
  // swiftlint:disable force_unwrapping
  func testCopyDataPointList() {
    // Given
    let dataPoint1 = PersonalName(firstName: "FIRST_NAME_1", lastName: "LAST_NAME_1")
    let dataPoint2 = CreditScore(creditRange: 1)

    // When
    let sut = DataPointList()
    sut.add(dataPoint: dataPoint1)
    sut.add(dataPoint: dataPoint2)
    let copiedDataPointList = sut.copy() as! DataPointList

    // Then
    XCTAssertEqual(copiedDataPointList.dataPoints.count, 2)
    let dp1 = copiedDataPointList.getDataPointsOf(type: .personalName)!.first as! PersonalName
    let dp2 = copiedDataPointList.getDataPointsOf(type: .creditScore)!.first as! CreditScore
    XCTAssertTrue(dp1 == dataPoint1)
    XCTAssertTrue(dp2 == dataPoint2)
  }
  // swiftlint:enable force_unwrapping
  // swiftlint:enable force_cast

  func testNonModifiedDataPointsWithoutVerification() {
    // Given
    let sut = DataPointList()
    sut.add(dataPoint: DataPoint(type: .address, verified: false))
    sut.add(dataPoint: DataPoint(type: .phoneNumber, verified: false))

    let otherDataPointList = DataPointList()
    otherDataPointList.add(dataPoint: DataPoint(type: .address, verified: false))
    otherDataPointList.add(dataPoint: DataPoint(type: .phoneNumber, verified: false))

    // When
    let modifiedDataPoints = sut.modifiedDataPoints(compareWith: otherDataPointList)

    // Then
    XCTAssertTrue(modifiedDataPoints.dataPoints.isEmpty)
  }

  func testNonModifiedDataPointsWithVerification() {
    // Given
    let sut = DataPointList()
    sut.add(dataPoint: DataPoint(type: .address, verified: true))
    sut.add(dataPoint: DataPoint(type: .phoneNumber, verified: true))

    let otherDataPointList = DataPointList()
    otherDataPointList.add(dataPoint: DataPoint(type: .address, verified: true))
    otherDataPointList.add(dataPoint: DataPoint(type: .phoneNumber, verified: true))

    // When
    let modifiedDataPoints = sut.modifiedDataPoints(compareWith: otherDataPointList)

    // Then
    XCTAssertTrue(modifiedDataPoints.dataPoints.isEmpty)
  }

  func testNonModifiedDataPointsWithVerificationData() {
    // Given
    let sut = DataPointList()
    let dp1 = DataPoint(type: .address, verified: true)
    dp1.verification = Verification(verificationId: "VERIFICATION_ID", verificationType: .phoneNumber, status: .passed)
    let dp2 = DataPoint(type: .phoneNumber, verified: true)
    dp2.verification = Verification(verificationId: "VERIFICATION_ID", verificationType: .phoneNumber, status: .passed)
    sut.add(dataPoint: dp1)
    sut.add(dataPoint: dp2)

    let otherDataPointList = DataPointList()
    let odp1 = DataPoint(type: .address, verified: true)
    odp1.verification = Verification(verificationId: "VERIFICATION_ID", verificationType: .phoneNumber, status: .passed)
    let odp2 = DataPoint(type: .phoneNumber, verified: true)
    odp2.verification = Verification(verificationId: "VERIFICATION_ID", verificationType: .phoneNumber, status: .passed)
    otherDataPointList.add(dataPoint: odp1)
    otherDataPointList.add(dataPoint: odp2)

    // When
    let modifiedDataPoints = sut.modifiedDataPoints(compareWith: otherDataPointList)

    // Then
    XCTAssertTrue(modifiedDataPoints.dataPoints.isEmpty)
  }

  func testModifiedDataPointsWithoutVerificationData() {
    // Given
    let sut = DataPointList()
    let dp1 = DataPoint(type: .address, verified: true)
    let dp2 = DataPoint(type: .phoneNumber, verified: true)
    sut.add(dataPoint: dp1)
    sut.add(dataPoint: dp2)

    let otherDataPointList = DataPointList()
    let odp1 = DataPoint(type: .creditScore, verified: true)
    otherDataPointList.add(dataPoint: odp1)

    // When
    let modifiedDataPoints = sut.modifiedDataPoints(compareWith: otherDataPointList)

    // Then
    XCTAssertTrue(modifiedDataPoints.getDataPointsOf(type: .creditScore)?.count == 1)
  }

  func testModifiedDataPointsWithVerificationData() {
    // Given
    let sut = DataPointList()
    let dp1 = DataPoint(type: .address, verified: true)
    let dp2 = DataPoint(type: .phoneNumber, verified: false)
    sut.add(dataPoint: dp1)
    sut.add(dataPoint: dp2)

    let otherDataPointList = DataPointList()
    let odp1 = DataPoint(type: .phoneNumber, verified: false)
    odp1.verification = Verification(verificationId: "VERIFICATION_ID", verificationType: .phoneNumber, status: .passed)
    otherDataPointList.add(dataPoint: odp1)

    // When
    let modifiedDataPoints = sut.modifiedDataPoints(compareWith: otherDataPointList)

    // Then
    XCTAssertTrue(modifiedDataPoints.getDataPointsOf(type: .phoneNumber)?.count == 1)
  }
}
