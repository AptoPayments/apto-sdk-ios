//
//  TopBarButtonItem.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 31/12/2018.
//

import UIKit

class TopBarButtonItem: UIBarButtonItem {

  private let uiConfig: ShiftUIConfig
  private let containerView = UIView()
  private let labelBackground = UIView()
  private let text: String
  private let icon: UIImage?
  private let tapHandler: () -> ()
  private var iconView: UIImageView!

  init(uiConfig: ShiftUIConfig, text: String, icon: UIImage?, tapHandler: @escaping () -> ()) {
    self.uiConfig = uiConfig
    self.text = text
    self.icon = icon
    self.tapHandler = tapHandler
    super.init()
    setupUI()
    setupTapHandlers()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) not implemented")
  }

}

private extension TopBarButtonItem {
  func setupUI() {
    setupLabel()
    setupIcon()
    self.customView = containerView
    style = .plain
  }

  func setupLabel() {
    labelBackground.backgroundColor = labelBackgroundColor
    labelBackground.layer.cornerRadius = 10
    labelBackground.clipsToBounds = true
    let label = UILabel()
    label.font = labelFont
    label.textColor = labelFontColor
    label.text = text
    labelBackground.addSubview(label)
    label.snp.makeConstraints { make in
      make.left.right.equalTo(labelBackground).inset(12)
      make.top.bottom.equalTo(labelBackground).inset(4)
    }
    containerView.addSubview(labelBackground)
    labelBackground.snp.makeConstraints { make in
      make.left.bottom.equalToSuperview()
      make.top.equalToSuperview().offset(1)
    }
  }

  func setupIcon() {
    iconView = UIImageView(image: icon)
    containerView.addSubview(iconView)
    iconView.snp.makeConstraints { make in
      make.right.bottom.equalToSuperview()
      make.top.equalToSuperview().offset(1)
      make.left.equalTo(labelBackground.snp.right).offset(6)
    }
  }

  var labelFontColor: UIColor {
    return uiConfig.iconTertiaryColor
  }

  var labelBackgroundColor: UIColor {
    return uiConfig.uiPrimaryColor.withAlphaComponent(0.12)
  }

  var labelFont: UIFont {
    return uiConfig.fontProvider.topBarItemFont
  }
}

private extension TopBarButtonItem {
  func setupTapHandlers() {
    labelBackground.addTapGestureRecognizer { [weak self] in
      self?.tapHandler()
    }
    iconView.addTapGestureRecognizer { [weak self] in
      self?.tapHandler()
    }
  }
}
