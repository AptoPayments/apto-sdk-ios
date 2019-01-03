//
// ServerMaintenanceErrorViewControllerTheme2.swift
// ShiftSDK
//
// Created by Takeichi Kanzaki on 21/12/2018.
//

import SnapKit

class ServerMaintenanceErrorViewControllerTheme2: UIViewController {
  private let config: ShiftUIConfig?
  private let imageView = UIImageView()
  // swiftlint:disable implicitly_unwrapped_optional
  private var messageLabel: UILabel!
  // swiftlint:enable implicitly_unwrapped_optional
  private let eventHandler: ServerMaintenanceErrorEventHandler

  open override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
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
    setUpUI()
  }

  @objc private func retry() {
    eventHandler.retryTapped()
  }
}

// MARK: - setup UI
private extension ServerMaintenanceErrorViewControllerTheme2 {
  func setUpUI() {
    view.backgroundColor = backgroundColor
    setUpImageView()
    setUpMessageLabel()
    setUpRetryButton()
  }

  func setUpImageView() {
    // swiftlint:disable:next force_unwrapping
    imageView.image = UIImage.imageFromPodBundle("error_maintenance", uiTheme: .theme2)?.asTemplate()
    imageView.tintColor = tintColor
    view.addSubview(imageView)
    imageView.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.bottom.equalTo(view.snp.centerY).offset(-24)
    }
  }

  func setUpMessageLabel() {
    messageLabel = UILabel()
    messageLabel.font = messageFont
    messageLabel.textColor = tintColor
    messageLabel.textAlignment = .center
    messageLabel.numberOfLines = 0
    messageLabel.text = "maintenance.description".podLocalized()
    view.addSubview(messageLabel)
    messageLabel.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(26)
      make.top.equalTo(imageView.snp.bottom).offset(86)
    }
  }

  func setUpRetryButton() {
    let button = UIButton(type: .custom)
    button.setTitle("maintenance.retry.title".podLocalized(), for: .normal)
    button.setTitleColor(backgroundColor, for: .normal)
    button.backgroundColor = tintColor
    button.layer.cornerRadius = buttonCornerRadius
    button.titleLabel?.font = buttonFont
    view.addSubview(button)
    button.snp.makeConstraints { make in
      make.left.bottom.right.equalToSuperview().inset(44)
      make.height.equalTo(56)
    }
    button.addTarget(self, action: #selector(self.retry), for: .touchUpInside)
  }

  var backgroundColor: UIColor {
    return config?.uiBackgroundPrimaryColor ?? UIColor.colorFromHex(0x202A36)
  }

  var tintColor: UIColor {
    return config?.textPrimaryColor ?? .white
  }

  var titleFont: UIFont {
    return config?.fontProvider.errorMessageFont ?? .systemFont(ofSize: 14, weight: .medium)
  }

  var messageFont: UIFont {
    return config?.fontProvider.errorTitleFont ?? .systemFont(ofSize: 16, weight: .medium)
  }

  var buttonFont: UIFont {
    return config?.fontProvider.primaryCallToActionFont ?? .boldSystemFont(ofSize: 17)
  }

  var buttonCornerRadius: CGFloat {
    return config?.buttonCornerRadius ?? 12
  }
}
