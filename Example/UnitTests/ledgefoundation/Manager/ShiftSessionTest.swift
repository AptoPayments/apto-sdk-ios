//
//  ShiftSessionTest.swift
//  ShiftSDK
//
//  Created by Takeichi Kanzaki on 20/08/2018.
//
//

import XCTest
@testable import ShiftSDK

class ShiftSessionTest: XCTestCase {
  var sut: ShiftSession! // swiftlint:disable:this implicitly_unwrapped_optional

  // Collaborators
  private let shiftPlatform = ShiftPlatformFake()

  override func setUp() {
    super.setUp()

    sut = ShiftSession(shiftPlatform: shiftPlatform)
  }

  // MARK: - Current user
  func testCurrentUserCallPlatform() {
    // When
    sut.currentUser { _ in }

    // Then
    XCTAssertTrue(shiftPlatform.currentUserInfoCalled)
  }

  func testGivenCurrentUserForceRefreshFalseDoNotReload() {
    // Given
    givenCurrentUser()

    // When
    sut.currentUser(false, filterInvalidTokenResult: true) { _ in }

    // Then
    XCTAssertFalse(shiftPlatform.currentUserInfoCalled)
  }

  func testGivenCurrentUserForceRefreshReload() {
    // Given
    givenCurrentUser()

    // When
    sut.currentUser(true, filterInvalidTokenResult: true) { _ in }

    // Then
    XCTAssertTrue(shiftPlatform.currentUserInfoCalled)
  }

  func testGivenNotAccessTokenCurrentUserFails() {
    // Given
    givenNotAccessToken()
    var currentUserResult: Result<ShiftUser, NSError>?

    // When
    sut.currentUser { result in
      currentUserResult = result
    }

    // Then
    guard let result = currentUserResult else {
      XCTFail("Current user result not set")
      return
    }
    XCTAssertTrue(result.isFailure)
  }

  // MARK: - Logout
  func testLogoutClearUserToken() {
    // When
    sut.logout()

    // Then
    XCTAssertTrue(shiftPlatform.clearUserTokenCalled)
  }

  func testLogoutClearInternalUserData() {
    // Given
    let dontForceRefresh = false
    givenCurrentUser()
    sut.logout()

    // When
    sut.currentUser(dontForceRefresh) { _ in }

    // Then
    XCTAssertTrue(shiftPlatform.currentUserInfoCalled)
  }
}

private extension ShiftSessionTest {
  func givenCurrentUser() {
    shiftPlatform.currentUserInfoNextResult = .success(ModelDataProvider.provider.user)
    sut.currentUser { _ in }
    shiftPlatform.resetSpies()
  }

  func givenNotAccessToken() {
    shiftPlatform.nextAccessToken = nil
  }
}
