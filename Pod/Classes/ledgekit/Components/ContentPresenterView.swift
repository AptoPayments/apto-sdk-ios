//
// ContentPresenterView.swift
// ShiftSDK
//
// Created by Takeichi Kanzaki on 2018-11-29.
//

import UIKit
import SnapKit
import TTTAttributedLabel

protocol ContentPresenterViewDelegate {
  func linkTapped(url: URL)
  func showMessage(_ message: String)
  func show(error: Error)
  func showLoadingSpinner()
  func hideLoadingSpinner()
}

class ContentPresenterView: UIView {
  private let uiConfig: ShiftUIConfig
  private let webView = UIWebView()
  private let textView = TTTAttributedLabel(frame: CGRect.zero)

  var delegate: ContentPresenterViewDelegate?

  /// Text alignment for plainText and markdown. For html content this value is ignored.
  var textAlignment: NSTextAlignment {
    get {
      return textView.textAlignment
    }
    set {
      textView.textAlignment = newValue
    }
  }

  /// Only applies for plainText and markdown. For html content this value is ignored.
  var lineSpacing: CGFloat = 0

  /// Only applies for plainText and markdown. For html content this value is ignored.
  var font: UIFont

  init(uiConfig: ShiftUIConfig) {
    self.uiConfig = uiConfig
    self.font = uiConfig.fontProvider.instructionsFont
    super.init(frame: .zero)

    setUpUI()
  }

  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func set(content: Content) {
    switch content {
    case .plainText, .markdown:
      guard let attributedString = content.attributedString(font: font,
                                                            color: uiConfig.textPrimaryColor,
                                                            linkColor: uiConfig.uiPrimaryColor,
                                                            lineSpacing: lineSpacing) else {
        showEmptyDisclaimer()
        return
      }
      show(attributedString)
    case .externalURL(let url):
      show(url)
    }
  }
}

private extension ContentPresenterView {
  func setUpUI() {
    backgroundColor = uiConfig.uiBackgroundPrimaryColor

    // Support for external url disclaimers
    setUpWebView()
    // Support for plain text or markdown disclaimers
    setUpTextView()
  }

  func setUpTextView() {
    addSubview(textView)
    textView.linkAttributes = [NSAttributedStringKey.foregroundColor: uiConfig.uiPrimaryColor,
                               kCTUnderlineStyleAttributeName as AnyHashable: false]
    textView.enabledTextCheckingTypes = NSTextCheckingAllTypes
    textView.delegate = self
    textView.numberOfLines = 0
    textView.verticalAlignment = .top
    textView.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(uiConfig.formRowPadding.left)
      make.top.equalToSuperview().offset(26)
      make.bottom.equalToSuperview()
    }
    textView.isHidden = true
  }

  func setUpWebView() {
    webView.isHidden = true
    addSubview(webView)
    webView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    webView.delegate = self
  }

  func show(_ attributedString: NSAttributedString) {
    textView.setText(attributedString)
    webView.isHidden = true
    textView.isHidden = false
  }

  func show(_ url: URL) {
    delegate?.showLoadingSpinner()
    let request = NSMutableURLRequest(url: url)
    webView.loadRequest(request as URLRequest)
    webView.isHidden = false
    textView.isHidden = true
  }

  func showEmptyDisclaimer() {
    delegate?.showMessage("Sorry, the content can't be shown at this moment. Please try again later.")
  }
}

extension ContentPresenterView: TTTAttributedLabelDelegate {
  //swiftlint:disable:next implicitly_unwrapped_optional
  func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
    delegate?.linkTapped(url: url)
  }
}

extension ContentPresenterView: UIWebViewDelegate {
  func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
    delegate?.hideLoadingSpinner()
    delegate?.show(error: error)
  }

  func webViewDidFinishLoad(_ webView: UIWebView) {
    delegate?.hideLoadingSpinner()
  }
}
