//
//  ExternalOAuthPresenterTest.swift
//  ShiftSDK
//
//  Created by Takeichi Kanzaki on 04/07/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import XCTest
@testable import ShiftSDK

class ExternalOAuthPresenterTest: XCTestCase {
  private var sut: ExternalOAuthPresenter! // swiftlint:disable:this implicitly_unwrapped_optional

  // Collaborators
  private lazy var dataProvider: ModelDataProvider = ModelDataProvider.provider
  private lazy var balanceType: AllowedBalanceType = dataProvider.coinbaseBalanceType
  private let url = URL(string: "https://shitfpayments.com")! // swiftlint:disable:this force_unwrapping
  private let interactor = ExternalOAuthInteractorSpy()
  private let router = ExternalOAuthModuleFake(serviceLocator: ServiceLocatorFake())

  override func setUp() {
    super.setUp()

    sut = ExternalOAuthPresenter(config: dataProvider.externalOauthModuleConfig)
    sut.router = router
    sut.interactor = interactor
  }

  func testCustodianTappedCallInteractor() {
    // When
    sut.balanceTypeTapped(balanceType)

    // Then
    XCTAssertTrue(interactor.balanceTypeSelectedCalled)
  }

  func testBackTappedCallRouter() {
    // When
    sut.backTapped()

    // Then
    XCTAssertTrue(router.backInExternalOAuthCalled)
  }

  func testCustodianSelectedCallRouter() {
    // When
    sut.custodianSelected(dataProvider.custodian)

    // Then
    XCTAssertTrue(router.oauthSucceededCalled)
    XCTAssertNotNil(router.lastOauthCustodian)
  }

  func testShowUrlCallRouter() {
    // When
    sut.show(url: url)

    // Then
    XCTAssertTrue(router.showUrlCalled)
    XCTAssertNotNil(router.lastUrlShown)
  }

  func testShowUrlRouterCallbackCalledShowSpinnerAndCallInteractor() {
    // When
    sut.show(url: url)

    // Then
    XCTAssertTrue(router.showLoadingSpinnerCalled)
    XCTAssertTrue(interactor.custodianAuthenticationSucceedCalled)
  }
}
