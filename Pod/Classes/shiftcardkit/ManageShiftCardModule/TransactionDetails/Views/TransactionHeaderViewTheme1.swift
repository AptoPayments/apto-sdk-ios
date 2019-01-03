//
//  TransactionHeaderView.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 30/12/2018.
//

import UIKit
import SnapKit

class TransactionHeaderViewTheme1: UIView {
  private let descriptionLabel: UILabel
  private let fiatAmountLabel: UILabel
  private let uiConfiguration: ShiftUIConfig
  private let contentView = UIView()

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  init(uiConfiguration: ShiftUIConfig) {
    self.uiConfiguration = uiConfiguration
    self.descriptionLabel = ComponentCatalog.mainItemRegularLabelWith(text: "", uiConfig: uiConfiguration)
    self.fiatAmountLabel = ComponentCatalog.mainItemRegularLabelWith(text: "", uiConfig: uiConfiguration)
    super.init(frame: .zero)

    setupUI()
  }

  func set(description: String?, fiatAmount: String?) {
    descriptionLabel.text = description
    fiatAmountLabel.text = fiatAmount
  }
}

private extension TransactionHeaderViewTheme1 {
  func setupUI() {
    backgroundColor = uiConfiguration.uiNavigationPrimaryColor
    setupContentView()
    setupDescriptionLabel()
    setupFiatAmountLabel()
  }

  func setupContentView() {
    addSubview(contentView)
    contentView.snp.makeConstraints { make in
      make.top.left.right.bottom.equalToSuperview().inset(16)
    }
  }

  func setupDescriptionLabel() {
    descriptionLabel.textColor = uiConfiguration.textTopBarColor
    contentView.addSubview(descriptionLabel)
    descriptionLabel.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.left.right.equalToSuperview()
    }
  }

  func setupFiatAmountLabel() {
    fiatAmountLabel.textColor = uiConfiguration.textTopBarColor
    contentView.addSubview(fiatAmountLabel)
    fiatAmountLabel.snp.makeConstraints { make in
      make.right.equalToSuperview()
      make.centerY.equalToSuperview()
    }
  }
}
