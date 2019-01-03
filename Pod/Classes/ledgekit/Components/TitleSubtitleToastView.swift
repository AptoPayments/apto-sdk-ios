//
// TitleSubtitleToastView.swift
// ShiftSDK
//
// Created by Takeichi Kanzaki on 2018-12-17.
//

import Foundation
import SwiftToast
import SnapKit

class TitleSubtitleToast: SwiftToastProtocol {
  var title: String
  var message: String
  var backgroundColor: UIColor
  var duration: Double?
  var minimumHeight: CGFloat? = 100
  var aboveStatusBar: Bool = false
  var statusBarStyle: UIStatusBarStyle = .default
  var isUserInteractionEnabled: Bool = true
  var target: SwiftToastDelegate?
  var style: SwiftToastStyle = .bottomToTop

  init(title: String,
       message: String,
       backgroundColor: UIColor,
       duration: Double?,
       delegate: SwiftToastDelegate?) {
    self.title = title
    self.message = message
    self.backgroundColor = backgroundColor
    self.target = delegate
    self.duration = duration
  }
}

class TitleSubtitleToastView: UIView, SwiftToastViewProtocol {
  private let titleLabel: UILabel
  private let messageLabel: UILabel
  private let uiConfig: ShiftUIConfig
  private let closeButton: UIButton

  var tapHandler: (() -> Void)?

  init(uiConfig: ShiftUIConfig) {
    self.uiConfig = uiConfig
    self.titleLabel = ComponentCatalog.sectionTitleLabelWith(text: "", uiConfig: uiConfig)
    self.messageLabel = ComponentCatalog.mainItemRegularLabelWith(text: "", multiline: true, uiConfig: uiConfig)
    self.closeButton = UIButton(type: .custom)
    super.init(frame: .zero)
  }

  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func nib() -> SwiftToastViewProtocol? {
    setUpUI()
    return self
  }

  func configure(with toast: SwiftToastProtocol) {
    guard let toastConfig = toast as? TitleSubtitleToast else { return }
    backgroundColor = toastConfig.backgroundColor
    closeButton.tintColor = toastConfig.backgroundColor
    closeButton.isHidden = (toastConfig.duration != nil)
    titleLabel.text = toastConfig.title
    messageLabel.text = toastConfig.message
  }

  // MARK: - Private methods
  private func setUpUI() {
    setUpMessageLabel()
    setUpCloseButton()
    setUpTitleLabel()
  }

  private func setUpMessageLabel() {
    addSubview(messageLabel)
    messageLabel.textColor = uiConfig.textMessageColor
    messageLabel.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(24)
      make.bottom.equalToSuperview().inset(52)
    }
  }

  private func setUpCloseButton() {
    addSubview(closeButton)
    let image = UIImage.imageFromPodBundle("top_close_default@2x")?.asTemplate()
    closeButton.setImage(image, for: .normal)
    closeButton.contentMode = .center
    closeButton.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    closeButton.backgroundColor = uiConfig.textMessageColor.withAlphaComponent(0.5)
    closeButton.layer.cornerRadius = 10
    closeButton.snp.makeConstraints { make in
      make.height.width.equalTo(20)
      make.top.equalToSuperview().offset(26)
      make.right.equalToSuperview().inset(26)
    }
    closeButton.addTapGestureRecognizer {
      UIApplication.topViewController()?.dismissSwiftToast(true)
    }
  }

  private func setUpTitleLabel() {
    addSubview(titleLabel)
    titleLabel.textColor = uiConfig.textMessageColor
    titleLabel.snp.makeConstraints { make in
      make.left.equalTo(messageLabel)
      make.right.equalTo(closeButton.snp.left).offset(-16)
      make.bottom.equalTo(messageLabel.snp.top).offset(-8)
      make.top.equalToSuperview().offset(26)
    }
  }
}

extension TitleSubtitleToastView: SwiftToastDelegate {
  public func swiftToastDidTouchUpInside(_ swiftToast: SwiftToastProtocol) {
    tapHandler?()
  }
}
