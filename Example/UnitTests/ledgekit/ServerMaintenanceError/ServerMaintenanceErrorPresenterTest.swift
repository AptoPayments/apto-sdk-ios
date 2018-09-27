//
//  ServerMaintenanceErrorPresenterTest.swift
//  ShiftSDK
//
//  Created by Takeichi Kanzaki on 18/07/2018.
//
//

import XCTest
@testable import ShiftSDK

class ServerMaintenanceErrorPresenterTest: XCTestCase {
  private var sut: ServerMaintenanceErrorPresenter! // swiftlint:disable:this implicitly_unwrapped_optional

  // Collaborators
  private let serviceLocator = ServiceLocatorFake()
  private lazy var router = serviceLocator.moduleLocatorFake.serverMaintenanceErrorModuleSpy
  private lazy var interactor = serviceLocator.interactorLocatorFake.serverMaintenanceErrorInteractorSpy

  override func setUp() {
    super.setUp()

    sut = ServerMaintenanceErrorPresenter()
    sut.router = router
    sut.interactor = interactor
  }

  func testRetryTappedNotifyRouterAndInteractor() {
    // When
    sut.retryTapped()

    // Then
    XCTAssertTrue(router.pendingRequestsExecutedCalled)
    XCTAssertTrue(interactor.runPendingRequestsCalled)
  }
}
