//
//  VerificationTests.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 13/05/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import XCTest
@testable import ShiftSDK

class VerificationTests: LinkTestCase {
  
  func testVerificationInitialization() {
    
    // Given
    let verificationId = "VERIFICATION_ID"
    let verificationType = DataPointType.phoneNumber
    let status = VerificationStatus.passed
    let secret = "SECRET"
    let secondaryCredential = Verification(verificationId: "verification_ID_2", verificationType: .email, status: .pending, secret:"SECRET_2")
    
    // When
    let sut = Verification(verificationId: verificationId,
                           verificationType: verificationType,
                           status: status,
                           secret: secret,
                           secondaryCredential: secondaryCredential)
    
    // Then
    XCTAssertEqual(sut.verificationId, verificationId)
    XCTAssertEqual(sut.verificationType, verificationType)
    XCTAssertEqual(sut.status, status)
    XCTAssertEqual(sut.secret, secret)
    XCTAssertEqual(sut.secondaryCredential!, secondaryCredential)
    
  }
  
  func testCopyVerification() {
    
    // Given
    let verificationId = "VERIFICATION_ID"
    let verificationType = DataPointType.email
    let status = VerificationStatus.passed
    let secret = "SECRET"
    let secondaryCredential = Verification(verificationId: "verification_ID_2", verificationType: .phoneNumber, status: .pending, secret:"SECRET_2")
    
    // When
    let sut = Verification(verificationId: verificationId,
                           verificationType: verificationType,
                           status: status,
                           secret: secret,
                           secondaryCredential: secondaryCredential)
    let copiedVerification = sut.copy() as! Verification
    
    // Then
    XCTAssertEqual(copiedVerification.verificationId, sut.verificationId)
    XCTAssertEqual(copiedVerification.verificationType, sut.verificationType)
    XCTAssertEqual(copiedVerification.status, sut.status)
    XCTAssertEqual(copiedVerification.secret!, sut.secret)
    XCTAssertTrue(copiedVerification.secondaryCredential! == sut.secondaryCredential!)
    
  }
  
  func testEqualVerificationsDifferentVerificationIdFalse() {
    
    // Given
    let verification1 = Verification (verificationId: "VERIFICATION_ID_1", verificationType: .phoneNumber, status: .passed, secret: "SECRET_1", secondaryCredential: nil)
    let verification2 = Verification (verificationId: "VERIFICATION_ID_2", verificationType: .phoneNumber, status: .passed, secret: "SECRET_1", secondaryCredential: nil)
    
    // When
    let equal = verification1 == verification2
    
    // Then
    XCTAssertFalse(equal)
    
  }
  
  func testEqualVerificationsDifferentVerificationTypeFalse() {
    
    // Given
    let verification1 = Verification (verificationId: "VERIFICATION_ID_1", verificationType: .email, status: .passed, secret: "SECRET_1", secondaryCredential: nil)
    let verification2 = Verification (verificationId: "VERIFICATION_ID_1", verificationType: .phoneNumber, status: .passed, secret: "SECRET_1", secondaryCredential: nil)
    
    // When
    let equal = verification1 == verification2
    
    // Then
    XCTAssertFalse(equal)
    
  }

  func testEqualVerificationsDifferentStatusFalse() {
    
    // Given
    let verification1 = Verification (verificationId: "VERIFICATION_ID_1", verificationType: .phoneNumber, status: .passed, secret: "SECRET_1", secondaryCredential: nil)
    let verification2 = Verification (verificationId: "VERIFICATION_ID_1", verificationType: .phoneNumber, status: .pending, secret: "SECRET_1", secondaryCredential: nil)
    
    // When
    let equal = verification1 == verification2
    
    // Then
    XCTAssertFalse(equal)
    
  }

  func testEqualVerificationsDifferentSecretFalse() {
    
    // Given
    let verification1 = Verification (verificationId: "VERIFICATION_ID_1", verificationType: .phoneNumber, status: .passed, secret: "SECRET_1", secondaryCredential: nil)
    let verification2 = Verification (verificationId: "VERIFICATION_ID_1", verificationType: .phoneNumber, status: .passed, secret: "SECRET_2", secondaryCredential: nil)
    
    // When
    let equal = verification1 == verification2
    
    // Then
    XCTAssertFalse(equal)
    
  }

  func testEqualVerificationsDifferentSecondaryCredentialFalse() {
    
    // Given
    let secondaryVerification = Verification (verificationId: "VERIFICATION_ID_1", verificationType: .phoneNumber, status: .passed, secret: "SECRET_2", secondaryCredential: nil)
    let verification1 = Verification (verificationId: "VERIFICATION_ID_1", verificationType: .phoneNumber, status: .passed, secret: "SECRET_1", secondaryCredential: nil)
    let verification2 = Verification (verificationId: "VERIFICATION_ID_1", verificationType: .phoneNumber, status: .passed, secret: "SECRET_1", secondaryCredential: secondaryVerification)
    
    // When
    let equal = verification1 == verification2
    
    // Then
    XCTAssertFalse(equal)
    
  }

  func testEqualVerificationsTrue() {
    
    // Given
    let verification1 = Verification (verificationId: "VERIFICATION_ID_1", verificationType: .phoneNumber, status: .passed, secret: "SECRET_1", secondaryCredential: nil)
    let verification2 = Verification (verificationId: "VERIFICATION_ID_1", verificationType: .phoneNumber, status: .passed, secret: "SECRET_1", secondaryCredential: nil)
    
    // When
    let equal = verification1 == verification2
    
    // Then
    XCTAssertTrue(equal)
    
  }

  func testEqualVerificationsNoSecretTrue() {
    
    // Given
    let verification1 = Verification (verificationId: "VERIFICATION_ID_1", verificationType: .phoneNumber, status: .passed, secret: nil, secondaryCredential: nil)
    let verification2 = Verification (verificationId: "VERIFICATION_ID_1", verificationType: .phoneNumber, status: .passed, secret: nil, secondaryCredential: nil)
    
    // When
    let equal = verification1 == verification2
    
    // Then
    XCTAssertTrue(equal)
    
  }

  func testEqualVerificationsNoAlternateCredentialsTrue() {
    
    // Given
    let verification1 = Verification (verificationId: "VERIFICATION_ID_1", verificationType: .phoneNumber, status: .passed, secret: "SECRET_1", secondaryCredential: nil)
    let verification2 = Verification (verificationId: "VERIFICATION_ID_1", verificationType: .phoneNumber, status: .passed, secret: "SECRET_1", secondaryCredential: nil)
    
    // When
    let equal = verification1 == verification2
    
    // Then
    XCTAssertTrue(equal)
    
  }

}
