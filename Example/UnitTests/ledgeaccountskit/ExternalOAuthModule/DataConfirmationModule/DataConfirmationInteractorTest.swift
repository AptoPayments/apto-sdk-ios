//
//  DataConfirmationInteractorTest.swift
//  ShiftSDK
//
//  Created by Takeichi Kanzaki on 25/09/2018.
//
//

import XCTest
@testable import ShiftSDK

class DataConfirmationInteractorTest: XCTestCase {
  var sut: DataConfirmationInteractor! // swiftlint:disable:this implicitly_unwrapped_optional

  // Collaborators
  private let userData = ModelDataProvider.provider.emailDataPointList

  override func setUp() {
    super.setUp()

    sut = DataConfirmationInteractor(userData: userData)
  }

  func testProvideDataCalledCallCompletionWithUserData() {
    // Given
    var returnedUserData: DataPointList?

    // When
    sut.provideUserData { userData in
      returnedUserData = userData
    }

    // Then
    XCTAssertNotNil(returnedUserData)
    XCTAssertEqual(userData, returnedUserData)
  }
}
