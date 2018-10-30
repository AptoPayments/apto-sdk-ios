//
//  ManageShiftCardTopMessageView.swift
//  ShiftSDK
//
// Created by Takeichi Kanzaki on 15/10/2018.
//

import SnapKit

struct ManageShiftCardTopMessageViewConfig {
  let title: String
  let message: String
  let actionTitle: String
  let closeHandler: () -> ()
  let actionHandler: () -> ()
}

class ManageShiftCardTopMessageView: UIView {
  private let config: ManageShiftCardTopMessageViewConfig
  private let uiConfig: ShiftUIConfig
  private let titleLabel: UILabel
  private let messageLabel: UILabel

  init(config: ManageShiftCardTopMessageViewConfig, uiConfig: ShiftUIConfig) {
    self.config = config
    self.uiConfig = uiConfig
    self.titleLabel = ComponentCatalog.sectionTitleLabelWith(text: config.title,
                                                             uiConfig: uiConfig)
    self.messageLabel = ComponentCatalog.boldMessageLabelWith(text: config.message,
                                                              uiConfig: uiConfig)
    super.init(frame: .zero)
    setUpUI()
  }

  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: - Set up UI
private extension ManageShiftCardTopMessageView {
  func setUpUI() {
    backgroundColor = uiConfig.uiToastMessagesColor
    layoutTitleLabel()
    layoutMessageLabel()
    createCloseButton()
    createAddFundingSourceButton()
    createShadowView()
  }

  func layoutTitleLabel() {
    addSubview(titleLabel)
    titleLabel.snp.makeConstraints { make in
      make.top.equalToSuperview().offset(20)
      make.left.equalToSuperview().offset(16)
    }
  }

  func layoutMessageLabel() {
    addSubview(messageLabel)
    messageLabel.snp.makeConstraints { make in
      make.top.equalTo(titleLabel.snp.bottom).offset(4)
      make.left.equalToSuperview().offset(16)
      make.right.equalToSuperview().inset(40)
    }
  }

  func createCloseButton() {
    let image = UIImage.imageFromPodBundle("top_close_default")?.asTemplate()
    let button = UIButton(type: .custom)
    button.tintColor = uiConfig.iconSecondaryColor
    button.setImage(image, for: .normal)
    button.addTapGestureRecognizer { [unowned self] in
      self.config.closeHandler()
    }
    addSubview(button)
    button.snp.makeConstraints { make in
      make.top.equalToSuperview().offset(20)
      make.right.equalToSuperview().inset(18)
    }
  }

  func createAddFundingSourceButton() {
    let button = ComponentCatalog.smallButtonWith(title: config.actionTitle,
                                                  uiConfig: uiConfig) { [unowned self] in
      self.config.actionHandler()
    }
    addSubview(button)
    button.snp.makeConstraints { make in
      make.top.equalTo(messageLabel.snp.bottom).offset(10)
      make.left.equalToSuperview().offset(16)
      make.width.equalTo(160)
      make.bottom.equalToSuperview().inset(24)
    }
  }

  func createShadowView() {
    let view = UIView()
    view.alpha = 0.7
    addSubview(view)
    view.snp.makeConstraints { make in
      make.left.right.bottom.equalToSuperview()
      make.height.equalTo(8)
    }
    let gradient = CAGradientLayer()
    gradient.colors = [UIColor.clear.cgColor, uiConfig.uiToastMessagesColor.cgColor]
    gradient.locations = [0, 1]
    gradient.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 8)
    view.layer.addSublayer(gradient)
  }
}
