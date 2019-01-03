//
//  TransactionHeaderView.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 30/12/2018.
//

import UIKit
import SnapKit

class TransactionHeaderViewTheme2: UIView {
  private let contentView = UIView()
  private let descriptionLabel: UILabel
  private let fiatAmountLabel = UILabel()
  private let nativeAmountLabel = UILabel()
  private let uiConfiguration: ShiftUIConfig

  init(uiConfiguration: ShiftUIConfig) {
    // Note: we need at least one character (so space character) to be able to retrieve later the label's
    // attributed text attributes.
    self.descriptionLabel = ComponentCatalog.starredSectionTitleLabelWith(text: " ", uiConfig: uiConfiguration)
    self.uiConfiguration = uiConfiguration
    super.init(frame: .zero)
    setUpUI()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func set(description: String?, fiatAmount: String?, nativeAmount: String?) {
    descriptionLabel.updateAttributedText(description?.uppercased())
    fiatAmountLabel.text = fiatAmount
    if let nativeAmount = nativeAmount {
      nativeAmountLabel.text = " ≈ " + nativeAmount
    }
    else {
      nativeAmountLabel.text = nil
    }
  }
}

// MARK: - Setup UI
private extension TransactionHeaderViewTheme2 {
  func setUpUI() {
    backgroundColor = uiConfiguration.uiNavigationSecondaryColor
    setupContentView()
    setUpDescriptionLabel()
    setUpFiatAmountLabel()
    setUpNativeAmountLabel()
  }

  func setupContentView() {
    addSubview(contentView)
    contentView.snp.makeConstraints { make in
      make.top.bottom.left.right.equalToSuperview().inset(20)
    }
  }

  func setUpDescriptionLabel() {
    contentView.addSubview(descriptionLabel)
    descriptionLabel.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.left.equalToSuperview()
    }
  }

  func setUpFiatAmountLabel() {
    fiatAmountLabel.font = uiConfiguration.fontProvider.amountBigFont
    fiatAmountLabel.textColor = uiConfiguration.textTopBarColor
    fiatAmountLabel.textAlignment = .left
    contentView.addSubview(fiatAmountLabel)
    fiatAmountLabel.snp.makeConstraints { make in
      make.left.equalTo(descriptionLabel)
      make.top.equalTo(descriptionLabel.snp.bottom).offset(6)
      make.bottom.equalToSuperview()
    }
  }

  func setUpNativeAmountLabel() {
    nativeAmountLabel.font = uiConfiguration.fontProvider.subCurrencyFont
    nativeAmountLabel.textColor = uiConfiguration.textTopBarColor.withAlphaComponent(0.7)
    nativeAmountLabel.textAlignment = .left
    contentView.addSubview(nativeAmountLabel)
    nativeAmountLabel.snp.makeConstraints { make in
      make.left.equalTo(fiatAmountLabel.snp.right)
      make.bottom.equalTo(fiatAmountLabel).offset(-4)
    }
  }
}
