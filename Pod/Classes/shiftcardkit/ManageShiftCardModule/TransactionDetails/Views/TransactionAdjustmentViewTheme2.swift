//
//  TransactionAdjustmentViewTheme2.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 31/12/2018.
//

import UIKit
import SnapKit

class TransactionAdjustmentViewTheme2: UIView {
  private let titleLabel: UILabel
  private let idLabel: UILabel
  private let exchangeRateLabel: UILabel
  private let amountLabel: UILabel
  private let leftView = UIView()
  private let uiConfiguration: ShiftUIConfig

  init(uiConfiguration: ShiftUIConfig) {
    self.uiConfiguration = uiConfiguration
    self.titleLabel = ComponentCatalog.mainItemRegularLabelWith(text: "", uiConfig: uiConfiguration)
    self.idLabel = ComponentCatalog.instructionsLabelWith(text: "",
                                                          textAlignment: .left,
                                                          uiConfig: uiConfiguration)
    self.exchangeRateLabel = ComponentCatalog.instructionsLabelWith(text: "",
                                                                    textAlignment: .left,
                                                                    uiConfig: uiConfiguration)
    self.amountLabel = ComponentCatalog.subcurrencyLabelWith(text: "",
                                                             textAlignment: .right,
                                                             uiConfig: uiConfiguration)

    super.init(frame: .zero)
    setUpUI()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func set(title: String?,
           id: String?,
           exchangeRate: String?,
           amount: Amount?,
           adjustmentType: TransactionAdjustmentType) {
    titleLabel.text = title
    idLabel.text = id
    exchangeRateLabel.text = exchangeRate
    amountLabel.text = amount?.text
  }
}

// MARK: - Set up UI
private extension TransactionAdjustmentViewTheme2 {
  func setUpUI() {
    setUpLeftView()
    setUpTitleLabel()
    setUpIdLabel()
    setUpExchangeRateLabel()
    setUpAmountLabel()
  }

  func setUpLeftView() {
    leftView.backgroundColor = .clear
    addSubview(leftView)
    leftView.snp.makeConstraints { make in
      make.left.top.bottom.equalToSuperview()
    }
  }

  func setUpTitleLabel() {
    leftView.addSubview(titleLabel)
    titleLabel.snp.makeConstraints { make in
      make.left.top.right.equalToSuperview()
    }
  }

  func setUpIdLabel() {
    leftView.addSubview(idLabel)
    idLabel.textColor = uiConfiguration.textTertiaryColor
    idLabel.snp.makeConstraints { make in
      make.left.right.equalToSuperview()
      make.top.equalTo(titleLabel.snp.bottom).offset(6)
    }
  }

  func setUpExchangeRateLabel() {
    leftView.addSubview(exchangeRateLabel)
    exchangeRateLabel.textColor = uiConfiguration.textTertiaryColor
    exchangeRateLabel.snp.makeConstraints { make in
      make.left.right.equalToSuperview()
      make.top.equalTo(idLabel.snp.bottom).offset(6)
      make.bottom.equalToSuperview()
    }
  }

  func setUpAmountLabel() {
    addSubview(amountLabel)
    amountLabel.textColor = uiConfiguration.textTertiaryColor
    amountLabel.snp.makeConstraints { make in
      make.top.right.equalToSuperview()
      make.left.equalTo(leftView.snp.right)
    }
  }
}
