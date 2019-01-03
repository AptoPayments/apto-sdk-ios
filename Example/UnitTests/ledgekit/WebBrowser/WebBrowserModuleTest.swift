//
// WebBrowserModuleTest.swift
// ShiftSDK
//
// Created by Takeichi Kanzaki on 20/11/2018.
//

import XCTest
@testable import ShiftSDK

class WebBrowserModuleTest: XCTestCase {
  var sut: WebBrowserModule! // swiftlint:disable:this implicitly_unwrapped_optional

  // Collaborators
  private let serviceLocator = ServiceLocatorFake()
  private let url = ModelDataProvider.provider.url
  private lazy var presenter = serviceLocator.presenterLocatorFake.webBrowserPresenterSpy

  override func setUp() {
    super.setUp()

    sut = WebBrowserModule(serviceLocator: serviceLocator, url: url)
  }

  func testInitializeSetUpPresenter() {
    // When
    sut.initialize { _ in }

    // Then
    XCTAssertNotNil(presenter.view)
    XCTAssertNotNil(presenter.router)
    XCTAssertNotNil(presenter.interactor)
  }
}
