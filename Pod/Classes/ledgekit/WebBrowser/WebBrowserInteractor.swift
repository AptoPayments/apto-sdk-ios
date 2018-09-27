//
//  WebBrowserInteractor.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 25/08/16.
//
//

import Foundation

protocol WebBrowserDataReceiverProtocol: class {
  func load(url: URL, headers: [String: String]?)
}

class WebBrowserInteractor: WebBrowserInteractorProtocol {
  private let url: URL
  private let headers: [String: String]?
  private unowned let dataReceiver: WebBrowserDataReceiverProtocol

  init(url: URL, headers: [String: String]? = nil, dataReceiver: WebBrowserDataReceiverProtocol) {
    self.url = url
    self.headers = headers
    self.dataReceiver = dataReceiver
  }

  func provideUrl() {
    dataReceiver.load(url: url, headers: headers)
  }
}
