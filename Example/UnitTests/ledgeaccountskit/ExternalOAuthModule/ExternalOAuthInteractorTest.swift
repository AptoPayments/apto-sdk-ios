//
//  ExternalOAuthInteractorTest.swift
//  ShiftSDK
//
//  Created by Takeichi Kanzaki on 04/07/2018.
//
//

import XCTest
@testable import ShiftSDK

class ExternalOAuthInteractorTest: XCTestCase {
  var sut: ExternalOAuthInteractor! // swiftlint:disable:this implicitly_unwrapped_optional

  // Collaborators
  private let serviceLocator = ServiceLocatorFake()
  private lazy var dataProvider: ModelDataProvider = ModelDataProvider.provider
  private lazy var shiftSession: ShiftSessionFake = serviceLocator.sessionFake
  private lazy var balanceType: AllowedBalanceType = dataProvider.coinbaseBalanceType
  private lazy var oauthAttempt = dataProvider.oauthAttempt
  private lazy var presenter = serviceLocator.presenterLocatorFake.externalOauthPresenterSpy

  override func setUp() {
    super.setUp()

    sut = ExternalOAuthInteractor(shiftSession: shiftSession)
    sut.presenter = presenter
  }

  func testCustodianSelectedStartOauthAuthentication() {
    // When
    sut.balanceTypeSelected(balanceType)

    // Then
    XCTAssertTrue(shiftSession.startOauthAuthenticationCalled)
  }

  func testStartOauthAuthenticationFailShowError() {
    // Given
    shiftSession.nextStartOauthAuthenticationResult = .failure(BackendError(code: .other))

    // When
    sut.balanceTypeSelected(balanceType)

    // Then
    XCTAssertTrue(presenter.showErrorCalled)
    XCTAssertNotNil(presenter.lastErrorShown)
  }

  func testStartOauthAuthenticationSucceedShowUrl() {
    // Given
    shiftSession.nextStartOauthAuthenticationResult = .success(oauthAttempt)

    // When
    sut.balanceTypeSelected(balanceType)

    // Then
    XCTAssertTrue(presenter.showUrlCalled)
    XCTAssertNotNil(presenter.lastUrlShown)
  }

  func testStartOauthAuthenticationSucceedCustodianUrlOpenedCallVerifyOauthAttemptStatus() {
    // Given
    givenStartOauthAuthenticationSucceed()

    // When
    sut.custodianAuthenticationSucceed()

    // Then
    XCTAssertTrue(shiftSession.verifyOauthAttemptStatusCalled)
  }

  func testVerifyOauthAttemptFailShowError() {
    // Given
    givenStartOauthAuthenticationSucceed()
    shiftSession.nextVerifyOauthAttemptStatusResult = .failure(BackendError(code: .other))

    // When
    sut.custodianAuthenticationSucceed()

    // Then
    XCTAssertTrue(presenter.showErrorCalled)
    XCTAssertNotNil(presenter.lastErrorShown)
  }

  func testVerifyOauthAttemptSucceedCallCustodianSelected() {
    // Given
    givenStartOauthAuthenticationSucceed()
    shiftSession.nextVerifyOauthAttemptStatusResult = .success(dataProvider.custodian)

    // When
    sut.custodianAuthenticationSucceed()

    // Then
    XCTAssertTrue(presenter.custodianSelectedCalled)
    XCTAssertNotNil(presenter.lastCustodianSelected)
  }

  private func givenStartOauthAuthenticationSucceed() {
    shiftSession.nextStartOauthAuthenticationResult = .success(oauthAttempt)
    sut.balanceTypeSelected(balanceType)
  }
}
