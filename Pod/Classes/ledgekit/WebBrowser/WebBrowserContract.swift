//
// WebBrowserContract.swift
// ShiftSDK
//
// Created by Takeichi Kanzaki on 19/11/2018.
//

protocol WebBrowserRouterProtocol: class {
  func close()
}

protocol WebBrowserViewProtocol {
  func load(url: URL, headers: [String: String]?)
}

typealias WebBrowserViewControllerProtocol = ShiftViewController & WebBrowserViewProtocol

protocol WebBrowserInteractorProtocol {
  func provideUrl()
}

protocol WebBrowserDataReceiverProtocol: class {
  func load(url: URL, headers: [String: String]?)
}

protocol WebBrowserEventHandlerProtocol: class {
  func viewLoaded()
  func closeTapped()
}

protocol WebBrowserPresenterProtocol: WebBrowserEventHandlerProtocol, WebBrowserDataReceiverProtocol {
  // swiftlint:disable implicitly_unwrapped_optional
  var router: WebBrowserRouterProtocol! { get set }
  var view: WebBrowserViewProtocol! { get set }
  var interactor: WebBrowserInteractorProtocol! { get set }
  // swiftlint:enable implicitly_unwrapped_optional
}
