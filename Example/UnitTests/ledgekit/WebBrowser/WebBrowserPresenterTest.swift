//
// WebBrowserPresenterTest.swift
// ShiftSDK
//
// Created by Takeichi Kanzaki on 20/11/2018.
//

import XCTest
@testable import ShiftSDK

class WebBrowserPresenterTest: XCTestCase {
  var sut: WebBrowserPresenter! // swiftlint:disable:this implicitly_unwrapped_optional

  // Collaborators
  private let router = WebBrowserModuleSpy(serviceLocator: ServiceLocatorFake())
  private let view = WebBrowserViewSpy()
  private let interactor = WebBrowserInteractorSpy()

  override func setUp() {
    super.setUp()

    sut = WebBrowserPresenter()
    sut.router = router
    sut.view = view
    sut.interactor = interactor
  }

  func testViewLoadedCallInteractor() {
    // When
    sut.viewLoaded()

    // Then
    XCTAssertTrue(interactor.provideUrlCalled)
  }

  func testLoadUrlAskViewToLoadUrl() {
    // Given
    let url = ModelDataProvider.provider.url

    // When
    sut.load(url: url, headers: nil)

    // Then
    XCTAssertTrue(view.loadUrlCalled)
    XCTAssertEqual(url, view.lastUrlToLoad)
  }

  func testCloseTappedNotifyRouter() {
    // When
    sut.closeTapped()

    // Then
    XCTAssertTrue(router.closeCalled)
  }
}
