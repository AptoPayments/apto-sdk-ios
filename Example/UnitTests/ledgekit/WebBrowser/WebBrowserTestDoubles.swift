//
// WebBrowserTestDoubles.swift
// ShiftSDK
//
// Created by Takeichi Kanzaki on 20/11/2018.
//

@testable import ShiftSDK

class WebBrowserInteractorSpy: WebBrowserInteractorProtocol {
  private(set) var provideUrlCalled = false
  func provideUrl() {
    provideUrlCalled = true
  }
}

class WebBrowserPresenterSpy: WebBrowserPresenterProtocol {
  // swiftlint:disable implicitly_unwrapped_optional
  var router: WebBrowserRouterProtocol!
  var view: WebBrowserViewProtocol!
  var interactor: WebBrowserInteractorProtocol!
  // swiftlint:enable implicitly_unwrapped_optional

  private(set) var viewLoadedCalled = false
  func viewLoaded() {
    viewLoadedCalled = true
  }

  private(set) var closeTappedCalled = false
  func closeTapped() {
    closeTappedCalled = true
  }

  private(set) var loadUrlCalled = false
  private(set) var lastUrlToLoad: URL?
  private(set) var lastHeaders: [String: String]?
  func load(url: URL, headers: [String: String]?) {
    loadUrlCalled = true
    lastUrlToLoad = url
    lastHeaders = headers
  }
}

class WebBrowserModuleSpy: UIModuleSpy, WebBrowserRouterProtocol {
}

class WebBrowserViewSpy: WebBrowserViewProtocol {
  private(set) var loadUrlCalled = false
  private(set) var lastUrlToLoad: URL?
  private(set) var lastHeaders: [String: String]?
  func load(url: URL, headers: [String: String]?) {
    loadUrlCalled = true
    lastUrlToLoad = url
    lastHeaders = headers
  }
}
