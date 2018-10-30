//
//  FullScreenDisclaimerModuleTest.swift
//  ShiftSDK
//
//  Created by Takeichi Kanzaki on 10/06/2018.
//
//

import XCTest
@testable import ShiftSDK

class FullScreenDisclaimerModuleTest: XCTestCase {
  var sut: FullScreenDisclaimerModule!

  // Collaborators
  let serviceLocator = ServiceLocatorFake()
  let disclaimer: Content = .plainText("Disclaimer")

  override func setUp() {
    super.setUp()

    sut = FullScreenDisclaimerModule(serviceLocator: serviceLocator, disclaimer: disclaimer)
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

  func testInitializeConfigurationSucceedConfigurePresenter() {
    // Given
    serviceLocator.setUpSessionForContextConfigurationSuccess()

    // When
    sut.initialize { _ in }

    // Then
    let presenter = serviceLocator.presenterLocatorFake.fullScreenDisclaimerPresenterSpy
    let interactor = serviceLocator.interactorLocatorFake.fullScreenDisclaimerInteractorSpy
    XCTAssertEqual(sut, presenter.router as? FullScreenDisclaimerModule)
    XCTAssertEqual(interactor, presenter.interactor as? FullScreenDisclaimerInteractorSpy)
  }

  func testDisclaimerAcceptedCallCompletionBlock() {
    // Given
    serviceLocator.setUpSessionForContextConfigurationSuccess()
    sut.initialize { _ in }
    var closureCalled = false
    sut.onDisclaimerAgreed = { _ in
      closureCalled = true
    }
    var onFinishCalled = false
    sut.onFinish = { _ in
      onFinishCalled = true
    }

    // When
    sut.agreeTapped()

    // Then
    XCTAssertTrue(closureCalled)
    XCTAssertTrue(onFinishCalled)
  }
}
