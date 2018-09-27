//
//  ServerMaintenanceErrorViewController.swift
//  Pods
//
//  Created by Takeichi Kanzaki on 17/07/2018.
//
//

import UIKit
import SnapKit

class ServerMaintenanceErrorViewController: UIViewController {
  private let config: ShiftUIConfig?
  // swiftlint:disable implicitly_unwrapped_optional
  private var titleLabel: UILabel!
  private var messageLabel: UILabel!
  // swiftlint:enable implicitly_unwrapped_optional
  private let eventHandler: ServerMaintenanceErrorEventHandler

  open override var preferredStatusBarStyle: UIStatusBarStyle {
    return .default
  }

  init(uiConfig: ShiftUIConfig?, eventHandler: ServerMaintenanceErrorEventHandler) {
    self.config = uiConfig
    self.eventHandler = eventHandler

    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) not implemented")
  }

  override public func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = backgroundColor
    setUpMessageLabel()
    setUpTitleLabel()
    setUpRetryButton()
    setUpImageView()
  }

  @objc private func retry() {
    eventHandler.retryTapped()
  }
}

// MARK: - setup UI
private extension ServerMaintenanceErrorViewController {
  private func setUpMessageLabel() {
    messageLabel = UILabel()
    messageLabel.font = messageFont
    messageLabel.textColor = tintColor
    messageLabel.textAlignment = .center
    messageLabel.numberOfLines = 0
    messageLabel.text = "server-maintenance.error.message".podLocalized()
    view.addSubview(messageLabel)
    messageLabel.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(16)
      make.right.equalToSuperview().offset(-16)
      make.center.equalToSuperview()
    }
  }

  private func setUpTitleLabel() {
    titleLabel = UILabel()
    titleLabel.font = titleFont
    titleLabel.textColor = tintColor
    titleLabel.textAlignment = .center
    titleLabel.text = "server-maintenance.error.title".podLocalized()
    view.addSubview(titleLabel)
    titleLabel.snp.makeConstraints { make in
      make.width.equalToSuperview()
      make.bottom.equalTo(messageLabel.snp.top).offset(-16)
    }
  }

  private func setUpRetryButton() {
    let button = UIButton(type: .custom)
    button.setTitle("server-maintenance.action.retry".podLocalized(), for: .normal)
    button.setTitleColor(backgroundColor, for: .normal)
    button.backgroundColor = tintColor
    button.layer.shadowOffset = CGSize(width: 0, height: 16)
    button.layer.shadowColor = UIColor(red:0, green:0, blue:0, alpha:0.16).cgColor
    button.layer.cornerRadius = 8
    button.layer.shadowOpacity = 1
    button.layer.shadowRadius = 16
    view.addSubview(button)
    button.snp.makeConstraints { make in
      make.top.equalTo(messageLabel.snp.bottom).offset(24)
      make.leading.equalToSuperview().offset(44)
      make.trailing.equalToSuperview().offset(-44)
      make.height.equalTo(50)
    }
    button.addTarget(self, action: #selector(self.retry), for: .touchUpInside)
  }

  private func setUpImageView() {
    // swiftlint:disable:next force_unwrapping
    let image = UIImage.imageFromPodBundle("error_backend.png")
    let imageView = UIImageView(image: image?.asTemplate())
    view.addSubview(imageView)
    imageView.tintColor = tintColor
    imageView.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.bottom.equalTo(titleLabel.snp.top).offset(-50)
    }
  }

  private var backgroundColor: UIColor {
    guard let config = self.config else {
      return .white
    }

    return config.backgroundColor
  }

  private var tintColor: UIColor {
    guard let config = self.config else {
      return .gray
    }

    return config.textPrimaryColor
  }

  private var titleFont: UIFont {
    guard let config = self.config else {
      return .systemFont(ofSize: 24)
    }

    return config.shiftTitleFont
  }

  private var messageFont: UIFont {
    guard let config = self.config else {
      return .systemFont(ofSize: 16)
    }

    return config.shiftFont
  }
}
