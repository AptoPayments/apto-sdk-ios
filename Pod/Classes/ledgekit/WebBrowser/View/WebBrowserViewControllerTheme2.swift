//
// WebBrowserViewControllerTheme2.swift
// ShiftSDK
//
// Created by Takeichi Kanzaki on 19/11/2018.
//

import UIKit
import SnapKit

class WebBrowserViewControllerTheme2: WebBrowserViewControllerProtocol {
  private let webView = UIWebView()
  private unowned let presenter: WebBrowserEventHandlerProtocol

  init(uiConfiguration: ShiftUIConfig, presenter: WebBrowserEventHandlerProtocol) {
    self.presenter = presenter
    super.init(uiConfiguration: uiConfiguration)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    setUpUI()
    presenter.viewLoaded()
  }

  func load(url: URL, headers: [String: String]?) {
    self.showLoadingSpinner(tintColor: uiConfiguration.uiPrimaryColor)
    let request = NSMutableURLRequest(url: url)
    if let headers = headers {
      request.allHTTPHeaderFields = headers
    }
    webView.loadRequest(request as URLRequest)
  }

  override func closeTapped() {
    presenter.closeTapped()
  }
}

extension WebBrowserViewControllerTheme2: UIWebViewDelegate {
  func webViewDidFinishLoad(_ aWebView: UIWebView) {
    self.hideLoadingSpinner()
    guard let title = aWebView.stringByEvaluatingJavaScript(from: "document.title") else {
      return
    }
    self.title = title
  }

  func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
    self.hideLoadingSpinner()
    self.show(error: error)
  }

  func webView(_ webView: UIWebView,
               shouldStartLoadWith request: URLRequest,
               navigationType: UIWebViewNavigationType) -> Bool {
    if let urlString = request.url?.absoluteString, urlString.hasPrefix("shift-sdk://oauth-finish") {
      defer { closeTapped() }
      return false
    }

    return true
  }
}

private extension WebBrowserViewControllerTheme2 {
  func setUpUI() {
    setUpNavigationBar()
    setUpWebView()
  }

  func setUpNavigationBar() {
    navigationController?.navigationBar.hideShadow()
    navigationController?.navigationBar.setUp(barTintColor: uiConfiguration.uiNavigationPrimaryColor,
                                              tintColor: uiConfiguration.uiSecondaryColor)
  }

  func setUpWebView() {
    view.addSubview(webView)
    webView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    webView.delegate = self
  }
}
