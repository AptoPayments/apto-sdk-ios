//
//  WebBrowserPresenter.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 25/08/16.
//
//

import Foundation

class WebBrowserPresenter: WebBrowserPresenterProtocol {
  // swiftlint:disable implicitly_unwrapped_optional
  weak var router: WebBrowserRouterProtocol!
  var view: WebBrowserViewProtocol!
  var interactor: WebBrowserInteractorProtocol!
  // swiftlint:enable implicitly_unwrapped_optional

  func viewLoaded() {
    interactor.provideUrl()
  }

  func load(url: URL, headers: [String: String]?) {
    view.load(url: url, headers: headers)
  }

  func closeTapped() {
    router.close()
  }
}
