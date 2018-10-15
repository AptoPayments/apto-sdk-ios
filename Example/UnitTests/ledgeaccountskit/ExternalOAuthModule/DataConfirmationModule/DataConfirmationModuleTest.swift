//
//  DataConfirmationModuleTest.swift
//  ShiftSDK
//
//  Created by Takeichi Kanzaki on 25/09/2018.
//
//

import XCTest
@testable import ShiftSDK

class DataConfirmationModuleTest: XCTestCase {
  var sut: DataConfirmationModule! // swiftlint:disable:this implicitly_unwrapped_optional

  // Collaborators
  private let serviceLocator = ServiceLocatorFake()
  private lazy var presenter = serviceLocator.presenterLocatorFake.dataConfirmationPresenterSpy
  private let userData = ModelDataProvider.provider.emailDataPointList

  override func setUp() {
    super.setUp()

    sut = DataConfirmationModule(serviceLocator: serviceLocator, userData: userData)
  }

  func testInitializeConfigurationSucceedConfigurePresenter() {
    // Given
    serviceLocator.setUpSessionForContextConfigurationSuccess()

    // When
    sut.initialize { _ in }

    // Then
    XCTAssertNotNil(presenter.router)
    XCTAssertNotNil(presenter.interactor)
  }

  func testInitialiazeConfigurationSucceedCallSuccess() {
    // Given
    serviceLocator.setUpSessionForContextConfigurationSuccess()
    var returnedResult: Result<UIViewController, NSError>?

    // When
    sut.initialize { result in
      returnedResult = result
    }

    // Then
    XCTAssertTrue(returnedResult!.isSuccess) // swiftlint:disable:this force_unwrapping
  }

  func testInitialiazeConfigurationFailsCallFailure() {
    // Given
    serviceLocator.setUpSessionForContextConfigurationFailure()
    var returnedResult: Result<UIViewController, NSError>?

    // When
    sut.initialize { result in
      returnedResult = result
    }

    // Then
    XCTAssertTrue(returnedResult!.isFailure) // swiftlint:disable:this force_unwrapping
  }

  func testCloseCalledCallOnClose() {
    // Given
    var onCloseCalled = false
    sut.onClose = { _ in
      onCloseCalled = true
    }

    // When
    sut.close()

    // Then
    XCTAssertTrue(onCloseCalled)
  }

  func testCloseCalledDoNotCallOnFinish() {
    // Given
    var onFinishCalled = false
    sut.onFinish = { _ in
      onFinishCalled = true
    }

    // When
    sut.close()

    // Then
    XCTAssertFalse(onFinishCalled)
  }

  func testConfirmDataCalledCallOnFinish() {
    // Given
    var onFinishCalled = false
    sut.onFinish = { _ in
      onFinishCalled = true
    }

    // When
    sut.confirmData()

    // Then
    XCTAssertTrue(onFinishCalled)
  }

  func testConfirmDataCalledDoNotCallOnClose() {
    // Given
    var onCloseCalled = false
    sut.onClose = { _ in
      onCloseCalled = true
    }

    // When
    sut.confirmData()

    // Then
    XCTAssertFalse(onCloseCalled)
  }
}
