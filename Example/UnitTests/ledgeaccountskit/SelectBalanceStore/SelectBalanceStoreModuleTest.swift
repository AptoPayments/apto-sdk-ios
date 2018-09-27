//
//  SelectBalanceStoreModuleTest.swift
//  ShiftSDK
//
//  Created by Takeichi Kanzaki on 05/07/2018.
//
//

import XCTest
@testable import ShiftSDK

class SelectBalanceStoreModuleTest: XCTestCase {
  private var sut: SelectBalanceStoreModule! // swiftlint:disable:this implicitly_unwrapped_optional

  // Collaborators
  private let serviceLocator = ServiceLocatorFake()
  private lazy var shiftSession = serviceLocator.sessionFake
  private lazy var shiftCardSession: ShiftCardSessionFake = shiftSession.setUpShiftCardSession()
  private lazy var dataProvider = ModelDataProvider.provider
  private lazy var application = dataProvider.cardApplication

  override func setUp() {
    super.setUp()

    sut = SelectBalanceStoreModule(serviceLocator: serviceLocator, application: application)
  }

  func testInitializeLoadContextConfiguration() {
    // When
    sut.initialize { _ in }

    // Then
    XCTAssertTrue(shiftSession.contextConfigurationCalled)
  }

  func testLoadContextConfigurationFailsCallFailureCompletion() {
    // Given
    serviceLocator.setUpSessionForContextConfigurationFailure()
    var result: Result<UIViewController, NSError>?

    // When
    sut.initialize { returnResult in
      result = returnResult
    }

    // Then
    XCTAssertTrue(result!.isFailure) // swiftlint:disable:this force_unwrapping
    XCTAssertNotNil(result?.error)
  }

  func testContextConfigurationSucceedInitializeExternalOauthModule() {
    // Given
    serviceLocator.setUpSessionForContextConfigurationSuccess()
    let externalOauthModule = serviceLocator.moduleLocatorFake.externalOauthModuleFake

    // When
    sut.initialize { _ in }

    // Then
    XCTAssertTrue(externalOauthModule.initializeCalled)
  }

  func testExternalOauthSucceededCallSetBalanceStore() {
    // Given
    let externalOauthModule = givenExternalOauthModulePresented()

    // When
    externalOauthModule.oauthSucceeded(dataProvider.custodian)

    // Then
    XCTAssertTrue(shiftCardSession.setBalanceStoreCalled)
  }

  func testSetBalanceStoreSucceededCallOnFinish() {
    // Given
    shiftCardSession.nextSetBalanceStoreResult = .success(SelectBalanceStoreResult(result: .valid, errorCode: nil))
    let externalOauthModule = givenExternalOauthModulePresented()
    var onFinishCalled = false
    sut.onFinish = { _ in
      onFinishCalled = true
    }

    // When
    externalOauthModule.oauthSucceeded(dataProvider.custodian)

    // Then
    XCTAssertTrue(onFinishCalled)
  }

  func testSetBalanceStoreValidationFailDoNotCallOnFinish() {
    // Given
    shiftCardSession.nextSetBalanceStoreResult = .success(SelectBalanceStoreResult(result: .invalid, errorCode: nil))
    let externalOauthModule = givenExternalOauthModulePresented()
    var onFinishCalled = false
    sut.onFinish = { _ in
      onFinishCalled = true
    }

    // When
    externalOauthModule.oauthSucceeded(dataProvider.custodian)

    // Then
    XCTAssertFalse(onFinishCalled)
  }

  private func givenExternalOauthModulePresented() -> ExternalOAuthModuleFake {
    serviceLocator.setUpSessionForContextConfigurationSuccess()
    shiftSession.setUpShiftCardSession()
    let externalOauthModule = serviceLocator.moduleLocatorFake.externalOauthModuleFake
    sut.initialize { _ in }

    return externalOauthModule
  }
}
