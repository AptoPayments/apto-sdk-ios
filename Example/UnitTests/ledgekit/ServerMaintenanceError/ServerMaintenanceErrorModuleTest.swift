//
//  ServerMaintenanceErrorModuleTest.swift
//  ShiftSDK
//
//  Created by Takeichi Kanzaki on 18/07/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import XCTest
@testable import ShiftSDK

class ServerMaintenanceErrorModuleTest: XCTestCase {
  private var sut: ServerMaintenanceErrorModule! // swiftlint:disable:this implicitly_unwrapped_optional

  // Collaborators
  private let serviceLocator = ServiceLocatorFake()
  private lazy var dataProvider = ModelDataProvider.provider
  private lazy var uiConfig = dataProvider.uiConfig

  override func setUp() {
    super.setUp()

    sut = ServerMaintenanceErrorModule(serviceLocator: serviceLocator)
  }

  func testInitializeReturnViewController() {
    // Given
    var returnedResult: Result<UIViewController, NSError>?

    // When
    sut.initialize { result in
      returnedResult = result
    }

    // Then
    XCTAssertTrue(returnedResult!.isSuccess) // swiftlint:disable:this force_unwrapping
    XCTAssertNotNil(returnedResult?.value)
  }

  func testInitializeConfigurePresenter() {
    // Given
    let presenter = serviceLocator.presenterLocatorFake.serverMaintenanceErrorPresenterSpy

    // When
    sut.initialize { _ in }

    // Then
    XCTAssertNotNil(presenter.router)
    XCTAssertNotNil(presenter.interactor)
  }

  func testPendingRequestsExecutedCallClose() {
    // Given
    var closeCalled = false
    sut.onClose = { _ in
      closeCalled = true
    }

    // When
    sut.pendingRequestsExecuted()

    // Then
    XCTAssertTrue(closeCalled)
  }
}
