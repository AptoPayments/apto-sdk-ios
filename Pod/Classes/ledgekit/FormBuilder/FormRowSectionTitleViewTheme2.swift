//
// FormRowSectionTitleViewTheme2.swift
// ShiftSDK
//
// Created by Takeichi Kanzaki on 20/12/2018.
//

import Foundation
import SnapKit

class FormRowSectionTitleViewTheme2: FormRowView {
  private let label: UILabel
  private let uiConfig: ShiftUIConfig

  init(title: String, uiConfig: ShiftUIConfig) {
    self.label = ComponentCatalog.sectionTitleLabelWith(text: title, uiConfig: uiConfig)
    self.uiConfig = uiConfig
    super.init(showSplitter: true, padding: uiConfig.formRowPadding, height: 36, maxHeight: 36)
    setUpUI()
  }

  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setUpUI() {
    setUpTopSeparatorView()
    setUpLabel()
  }

  private func setUpTopSeparatorView() {
    let topView = UIView()
    topView.backgroundColor = uiConfig.uiTertiaryColor
    contentView.addSubview(topView)
    topView.snp.makeConstraints { make in
      make.left.top.right.equalToSuperview()
      make.height.equalTo(1)
    }
  }

  private func setUpLabel() {
    contentView.addSubview(label)
    label.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(6)
      make.centerY.equalToSuperview()
    }
  }
}
