//
//  PhysicalCardActivationSucceedPresenterTest.swift
//  ShiftSDK
//
// Created by Takeichi Kanzaki on 22/10/2018.
//
//

import XCTest
@testable import ShiftSDK

class PhysicalCardActivationSucceedPresenterTest: XCTestCase {
  var sut: PhysicalCardActivationSucceedPresenter! // swiftlint:disable:this implicitly_unwrapped_optional

  // Collaborators
  private let serviceLocator = ServiceLocatorFake()
  private lazy var router = serviceLocator.moduleLocatorFake.physicalCardActivationSucceedModuleFake
  private lazy var interactor = serviceLocator.interactorLocatorFake.physicalCardActivationSucceedInteractorFake

  override func setUp() {
    super.setUp()

    sut = PhysicalCardActivationSucceedPresenter()
    sut.router = router
    sut.interactor = interactor
  }

  func testViewLoadedCallProvideCard() {
    // When
    sut.viewLoaded()

    // Then
    XCTAssertTrue(interactor.provideCardCalled)
  }

  func testCardProvidedWithIVRShowGetPinIsTrue() {
    // When
    sut.viewLoaded()

    // Then
    XCTAssertTrue(sut.viewModel.showGetPinButton.value)
  }

  func testCardProvidedWithoutIVRShowGetPinIsFalse() {
    // Given
    interactor.card = ModelDataProvider.provider.card

    // When
    sut.viewLoaded()

    // Then
    XCTAssertFalse(sut.viewModel.showGetPinButton.value)
  }

  func testGetPinTappedShowExternalURL() {
    // Given
    sut.viewModel.phoneNumber.next(PhoneNumber(countryCode: 1, phoneNumber: "2342303796"))

    // When
    sut.getPinTapped()

    // Then
    XCTAssertTrue(router.callURLCalled)
  }

  func testExternalURLShownCompletionCalledCallGetPinFinished() {
    // When
    sut.getPinTapped()

    // Then
    XCTAssertTrue(router.getPinFinishedCalled)
  }

  func testGetPinTappedWithoutIVRDoNotOpenURLCallFinished() {
    // Given
    interactor.card = ModelDataProvider.provider.card
    sut.viewLoaded()

    // When
    sut.getPinTapped()

    // Then
    XCTAssertFalse(router.callURLCalled)
    XCTAssertTrue(router.getPinFinishedCalled)
  }

  func testCloseTappedCallClose() {
    // Given
    sut.viewLoaded()

    // When
    sut.closeTapped()

    // Then
    XCTAssertTrue(router.closeCalled)
  }

  func testCardWithoutIVRCloseTappedCallGetPinFinished() {
    // Given
    interactor.card = ModelDataProvider.provider.card
    sut.viewLoaded()

    // When
    sut.closeTapped()

    // Then
    XCTAssertTrue(router.getPinFinishedCalled)
  }
}
