//
//  SectionHeaderView.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 31/12/2018.
//

import UIKit
import SnapKit

class SectionHeaderViewTheme2: UIView {
  private let uiConfig: ShiftUIConfig

  init(text: String, uiConfig: ShiftUIConfig) {
    self.uiConfig = uiConfig
    super.init(frame: .zero)
    setupUI(text: text)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setupUI(text: String) {
    backgroundColor = uiConfig.uiBackgroundSecondaryColor
    setUpLabel(text: text)
    setUpTopDivider()
    setUpBottomDivider()
  }

  private func setUpLabel(text: String) {
    let label = UILabel()
    label.textColor = uiConfig.textSecondaryColor
    label.font = uiConfig.fontProvider.sectionTitleFont
    label.text = text
    addSubview(label)
    label.snp.makeConstraints { make in
      make.left.right.equalToSuperview()
      make.centerY.equalToSuperview()
    }
  }

  private func setUpTopDivider() {
    let topDivider = UIView()
    topDivider.backgroundColor = uiConfig.uiTertiaryColor
    addSubview(topDivider)
    topDivider.snp.makeConstraints { make in
      make.left.right.equalToSuperview()
      make.top.equalToSuperview()
      make.height.equalTo(1)
    }
  }

  private func setUpBottomDivider() {
    let bottomDivider = UIView()
    bottomDivider.backgroundColor = uiConfig.uiTertiaryColor
    addSubview(bottomDivider)
    bottomDivider.snp.makeConstraints { make in
      make.left.right.equalToSuperview()
      make.bottom.equalToSuperview()
      make.height.equalTo(1)
    }
  }
}
