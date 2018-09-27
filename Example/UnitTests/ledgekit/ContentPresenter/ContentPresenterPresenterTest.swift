//
//  ContentPresenterPresenterTest.swift
//  ShiftSDK
//
//  Created by Takeichi Kanzaki on 17/09/2018.
//
//

import XCTest
@testable import ShiftSDK

class ContentPresenterPresenterTest: XCTestCase {
  private var sut: ContentPresenterPresenter! // swiftlint:disable:this implicitly_unwrapped_optional

  // Collaborators
  private let serviceLocator = ServiceLocatorFake()
  private lazy var router = ContentPresenterModuleSpy(serviceLocator: serviceLocator)
  private let interactor = ContentPresenterInteractorFake()
  private let content = Content.plainText("Content")

  override func setUp() {
    super.setUp()

    sut = ContentPresenterPresenter()
    sut.router = router
    sut.interactor = interactor
    interactor.nextContentToProvide = content
  }

  func testViewLoadedCallInteractorToProvideContent() {
    // When
    sut.viewLoaded()

    // Then
    XCTAssertTrue(interactor.provideContentCalled)
  }

  func testLinkTappedCallRouterToShowURL() {
    // Given
    let url = URL(string: "https://shiftpayments.com")! // swiftlint:disable:this force_unwrapping

    // When
    sut.linkTapped(url)

    // Then
    XCTAssertTrue(router.showURLCalled)
  }

  func testContentProvidedUpdateViewModel() {
    // Given
    XCTAssertNil(sut.viewModel.content.value)

    // When
    sut.viewLoaded()

    // Then
    XCTAssertNotNil(sut.viewModel.content.value)
  }
}
