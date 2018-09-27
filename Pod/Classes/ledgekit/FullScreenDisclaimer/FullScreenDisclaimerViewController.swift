//
//  FullScreenDisclaimerViewController.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 17/02/16.
//
//

import UIKit
import TTTAttributedLabel
import Bond
import ReactiveKit
import SnapKit

final class FullScreenDisclaimerViewController: ShiftViewController {
  fileprivate unowned let eventHandler: FullScreenDisclaimerEventHandler
  fileprivate let webView = UIWebView()
  fileprivate let textView = TTTAttributedLabel(frame: CGRect.zero)
  fileprivate let navigationView = UIView()
  fileprivate var agreeButton: UIButton! // swiftlint:disable:this implicitly_unwrapped_optional

  init(uiConfiguration: ShiftUIConfig, eventHandler: FullScreenDisclaimerEventHandler) {
    self.eventHandler = eventHandler
    super.init(uiConfiguration: uiConfiguration)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = uiConfiguration.backgroundColor
    setUpNavigationBar()

    // Bottom Bar Buttons
    setUpNavigationView()
    setUpAgreeButton()
    // Support for external url disclaimers
    setUpWebView()
    // Support for plain text or markdown disclaimers
    setUpTextView()

    edgesForExtendedLayout = UIRectEdge()
    extendedLayoutIncludesOpaqueBars = true

    // Subscribe to viewModel changes
    setupViewModelSubscriptions()

    eventHandler.viewLoaded()
  }

  // Setup subviews
  private func setUpNavigationBar() {
    navigationController?.navigationBar.setUpWith(uiConfig: uiConfiguration)
    showNavCancelButton(uiConfiguration.iconTertiaryColor)
  }

  private func setUpTextView() {
    view.addSubview(textView)
    textView.linkAttributes = [NSAttributedStringKey.foregroundColor: uiConfiguration.textPrimaryColor,
                               kCTUnderlineStyleAttributeName as AnyHashable: false]
    textView.enabledTextCheckingTypes = NSTextCheckingAllTypes
    textView.delegate = self
    textView.numberOfLines = 0
    textView.verticalAlignment = .top
    textView.snp.makeConstraints { make in
      make.top.left.right.equalTo(self.view).inset(10)
      make.bottom.equalTo(navigationView.snp.top).offset(-10)
    }
    textView.isHidden = true
  }

  private func setUpWebView() {
    webView.isHidden = true
    view.addSubview(webView)
    webView.snp.makeConstraints { make in
      make.top.left.right.equalTo(self.view)
      make.bottom.equalTo(navigationView.snp.top)
    }
    webView.delegate = self
  }

  private func setUpAgreeButton() {
    agreeButton = ComponentCatalog.buttonWith(title: "agree.button.title".podLocalized(),
                                              uiConfig: uiConfiguration) { [unowned self] in
      self.agreeTapped()
    }
    navigationView.addSubview(agreeButton)
    agreeButton.snp.makeConstraints { make in
      make.top.equalTo(navigationView).inset(5)
      make.left.right.bottom.equalTo(navigationView).inset(44)
      make.height.equalTo(50)
    }
  }

  private func setUpNavigationView() {
    view.addSubview(navigationView)
    navigationView.snp.makeConstraints { make in
      make.left.right.bottom.equalTo(self.view)
    }
  }

  // Setup viewModel subscriptions
  private func setupViewModelSubscriptions() {
    let viewModel = eventHandler.viewModel

    _ = viewModel.disclaimer.ignoreNil().observeNext { disclaimer in
      self.set(disclaimer: disclaimer)
    }
  }

  final private func set(disclaimer: Content) {
    switch disclaimer {
    case .plainText, .markdown:
      guard let attributedString = disclaimer.attributedString(font: uiConfiguration.instructionsFont,
                                                               color: uiConfiguration.textPrimaryColor,
                                                               linkColor: uiConfiguration.uiPrimaryColor) else {
        showEmptyDisclaimer()
        return
      }
      show(attributedString)
    case .externalURL(let url):
      show(url)
    }
  }

  final fileprivate func show(_ attributedString: NSAttributedString) {
    textView.attributedText = attributedString
    webView.isHidden = true
    textView.isHidden = false
  }

  final fileprivate func show(_ url: URL) {
    showLoadingSpinner(tintColor: uiConfiguration.uiPrimaryColor)
    let request = NSMutableURLRequest(url: url)
    webView.loadRequest(request as URLRequest)
    webView.isHidden = false
    textView.isHidden = true
  }

  final fileprivate func showEmptyDisclaimer() {
    showMessage("Sorry, the disclaimer can't be shown at this moment. Please try again later.")
  }

  override func closeTapped() {
    eventHandler.closeTapped()
  }

  func agreeTapped() {
    eventHandler.agreeTapped()
  }
}

extension FullScreenDisclaimerViewController: TTTAttributedLabelDelegate {
  //swiftlint:disable:next implicitly_unwrapped_optional
  func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
    eventHandler.linkTapped(url)
  }
}

extension FullScreenDisclaimerViewController: UIWebViewDelegate {
  func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
    hideLoadingSpinner()
    show(error: error)
  }

  func webViewDidFinishLoad(_ webView: UIWebView) {
    hideLoadingSpinner()
  }
}
