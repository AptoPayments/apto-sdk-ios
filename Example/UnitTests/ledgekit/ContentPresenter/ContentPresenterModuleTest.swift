//
//  ContentPresenterModuleTest.swift
//  ShiftSDK
//
//  Created by Takeichi Kanzaki on 17/09/2018.
//
//

import XCTest
@testable import ShiftSDK

class ContentPresenterModuleTest: XCTestCase {
  private var sut: ContentPresenterModule! // swiftlint:disable:this implicitly_unwrapped_optional

  private let serviceLocator = ServiceLocatorFake()
  private lazy var presenter = serviceLocator.presenterLocatorFake.contentPresenterPresenterSpy
  private let content = Content.plainText("Content")
  private let title = "Title"

  override func setUp() {
    super.setUp()

    sut = ContentPresenterModule(serviceLocator: serviceLocator, content: content, title: title)
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
}
