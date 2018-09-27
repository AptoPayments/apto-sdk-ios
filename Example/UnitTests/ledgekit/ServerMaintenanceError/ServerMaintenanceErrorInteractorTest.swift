//
//  ServerMaintenanceErrorInteractorTest.swift
//  ShiftSDK
//
//  Created by Takeichi Kanzaki on 18/07/2018.
//
//

import XCTest
@testable import ShiftSDK

class ServerMaintenanceErrorInteractorTest: XCTestCase {
  private var sut: ServerMaintenanceErrorInteractor! // swiftlint:disable:this implicitly_unwrapped_optional

  // Collaborators
  private let serviceLocator = ServiceLocatorFake()
  private lazy var networkManager = serviceLocator.networkLocatorFake.networkManagerSpy

  override func setUp() {
    super.setUp()

    sut = ServerMaintenanceErrorInteractor(networkManager: networkManager)
  }

  func testRunPendingRequestCallNetworkManager() {
    // When
    sut.runPendingRequests()

    // Then
    XCTAssertTrue(networkManager.runPendingRequestsCalled)
  }
}
