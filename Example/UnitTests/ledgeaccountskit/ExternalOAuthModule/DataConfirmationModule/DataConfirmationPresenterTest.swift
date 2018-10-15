//
//  DataConfirmationPresenterTest.swift
//  ShiftSDK
//
//  Created by Takeichi Kanzaki on 25/09/2018.
//
//

import XCTest
@testable import ShiftSDK

class DataConfirmationPresenterTest: XCTestCase {
  var sut: DataConfirmationPresenter! // swiftlint:disable:this implicitly_unwrapped_optional

  // Collaborators
  private let router = DataConfirmationModuleSpy(serviceLocator: ServiceLocatorFake())
  private let interactor = DataConfirmationInteractorFake()
  private let userData = ModelDataProvider.provider.emailDataPointList

  override func setUp() {
    super.setUp()

    sut = DataConfirmationPresenter()
    sut.router = router
    sut.interactor = interactor
  }

  func testViewLoadedCallInteractorToProvideData() {
    // When
    sut.viewLoaded()

    // Then
    XCTAssertTrue(interactor.provideUserDataCalled)
  }

  func testInteractorProvideDataUpdateViewModel() {
    // Given
    interactor.nextUserData = userData

    // When
    sut.viewLoaded()

    // Then
    XCTAssertEqual(userData, sut.viewModel.userData.value)
  }

  func testConfirmDataTappedNotifyRouter() {
    // When
    sut.confirmDataTapped()

    // Then
    XCTAssertTrue(router.confirmDataCalled)
  }

  func testCloseTappedNotifyRouter() {
    // When
    sut.closeTapped()

    // Then
    XCTAssertTrue(router.closeCalled)
  }
}
