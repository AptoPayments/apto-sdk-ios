//
//  PhysicalCardActivationSucceedModuleTest.swift
//  ShiftSDK
//
// Created by Takeichi Kanzaki on 22/10/2018.
//
//

import XCTest
@testable import ShiftSDK

class PhysicalCardActivationSucceedModuleTest: XCTestCase {
  var sut: PhysicalCardActivationSucceedModule! // swiftlint:disable:this implicitly_unwrapped_optional

  // Collaborators
  private let serviceLocator = ServiceLocatorFake()
  private lazy var shiftSession = serviceLocator.sessionFake
  private let card = ModelDataProvider.provider.card
  private lazy var presenter = serviceLocator.presenterLocatorFake.physicalCardActivationSucceedPresenterSpy
  private let phoenCaller = PhoneCallerSpy()

  override func setUp() {
    super.setUp()

    sut = PhysicalCardActivationSucceedModule(serviceLocator: serviceLocator,
                                              card: card,
                                              phoneCaller: phoenCaller)
  }

  func testContextConfigurationSucceedConfigurePresenter() {
    // Given
    serviceLocator.setUpSessionForContextConfigurationSuccess()

    // When
    sut.initialize { _ in }

    // Then
    XCTAssertNotNil(presenter.router)
    XCTAssertNotNil(presenter.interactor)
  }

  func testShowExternalURLCallCompletion() {
    // Given
    var completionCalled = false

    // When
    sut.call(url: URL(string: "https://shiftpayments.com")!) { // swiftlint:disable:this force_unwrapping
      completionCalled = true
    }

    // Then
    XCTAssertTrue(phoenCaller.callCalled)
    XCTAssertTrue(completionCalled)
  }

  func testGetPinFinishedCalledCallOnFinish() {
    // Given
    var onFinishCalled = false
    sut.onFinish = { _ in
      onFinishCalled = true
    }

    // When
    sut.getPinFinished()

    // Then
    XCTAssertTrue(onFinishCalled)
  }
}
