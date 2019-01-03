//
//  IssueCardModuleTest.swift
//  ShiftSDK
//
//  Created by Takeichi Kanzaki on 29/06/2018.
//
//

import XCTest
@testable import ShiftSDK

class IssueCardModuleTest: XCTestCase {
  var sut: IssueCardModule! // swiftlint:disable:this implicitly_unwrapped_optional

  // Collaborators
  private let serviceLocator = ServiceLocatorFake()
  private lazy var dataProvider: ModelDataProvider = ModelDataProvider.provider
  private lazy var application = dataProvider.cardApplication

  override func setUp() {
    super.setUp()

    sut = IssueCardModule(serviceLocator: serviceLocator, application: application)
  }

  func testInitializeConfigurationSucceedCallCompletionBlockWithSuccess() {
    // Given
    serviceLocator.setUpSessionForContextConfigurationSuccess()

    // When
    var returnedResult: Result<UIViewController, NSError>?
    sut.initialize { result in
      returnedResult = result
    }

    // Then
    XCTAssertTrue(returnedResult!.isSuccess) // swiftlint:disable:this implicitly_unwrapped_optional
    XCTAssertNotNil(returnedResult!.value) // swiftlint:disable:this implicitly_unwrapped_optional
  }

  func testCardIssueCallOnFinish() {
    // Given
    var onFinishCalled = false
    sut.onFinish = { _ in
      onFinishCalled = true
    }

    // When
    sut.cardIssued(dataProvider.card)

    // Then
    XCTAssertTrue(onFinishCalled)
  }

  func testBackTappedCallBack() {
    // Given
    var onBackCalled = false
    sut.onBack = { _ in
      onBackCalled = true
    }

    // When
    sut.backTapped()

    // Then
    XCTAssertTrue(onBackCalled)
  }
}
