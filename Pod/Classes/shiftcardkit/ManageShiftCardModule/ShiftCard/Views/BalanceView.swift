//
//  BalanceView.swift
//  Pods
//
//  Created by Takeichi Kanzaki on 09/08/2018.
//
//

import UIKit
import SnapKit

class BalanceView: UIView {
  private let balanceLabel = UILabel()
  private let balanceExplanation = UILabel()
  private let balanceBitCoins = UILabel()
  private let spendableLabel = UILabel()
  private let spendableExplanation = UILabel()
  private let spendableBitCoins = UILabel()
  private var showBalance = false {
    didSet {
      let showBalanceInfo = !showBalance
      balanceExplanation.isHidden = showBalanceInfo
      balanceLabel.isHidden = showBalanceInfo
    }
  }
  private var isCustodianWallet = false {
    didSet {
      let showCustodianInfo = !isCustodianWallet
      spendableExplanation.isHidden = showCustodianInfo
      spendableLabel.isHidden = showCustodianInfo
      balanceBitCoins.isHidden = showCustodianInfo
      spendableBitCoins.isHidden = showCustodianInfo
    }
  }
  private let uiConfiguration: ShiftUIConfig

  init(uiConfiguration: ShiftUIConfig) {
    self.uiConfiguration = uiConfiguration
    super.init(frame: .zero)
    setUpUI()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func set(fundingSource: FundingSource) {
    if let balance = fundingSource.balance {
      balanceLabel.text = balance.text
      showBalance = true
    }
    else {
      showBalance = false
    }
    if let fundingSource = fundingSource as? CustodianWallet, let spendable = fundingSource.amountSpendable {
      spendableLabel.text = spendable.text
      balanceBitCoins.text = fundingSource.nativeBalance.longText
      let nativeSpendable = nativeSpendableAmount(fundingSource: fundingSource)
      spendableBitCoins.text = nativeSpendable.longText
      isCustodianWallet = true
    }
    else {
      isCustodianWallet = false
    }
  }

  private func nativeSpendableAmount(fundingSource: CustodianWallet) -> Amount {
    let balanceAmount: Double = fundingSource.balance?.amount.value ?? 0
    let spendableAmount: Double = fundingSource.amountSpendable?.amount.value ?? 0
    let nativeAmount: Double = fundingSource.nativeBalance.amount.value ?? 0
    let nativeSpendableAmount: Double
    if balanceAmount == 0 {
      nativeSpendableAmount = 0
    }
    else {
      nativeSpendableAmount = (nativeAmount * spendableAmount) / balanceAmount
    }

    return Amount(value: nativeSpendableAmount, currency: fundingSource.nativeBalance.currency.value)
  }
}

// MARK: - Setup UI
private extension BalanceView {
  func setUpUI() {
    backgroundColor = uiConfiguration.backgroundColor
    setUpBalanceExplanation()
    setUpBalanceLabel()
    setUpSpendableExplanation()
    setUpSpendableLabel()
    setUpBalanceBitCoins()
    setUpSpendableBitCoins()
  }

  func setUpBalanceExplanation() {
    balanceExplanation.text = "manage.shift.card.current-balance".podLocalized()
    balanceExplanation.textColor = uiConfiguration.textSecondaryColor
    balanceExplanation.font = uiConfiguration.sectionTitleFont
    balanceExplanation.textAlignment = .left
    addSubview(balanceExplanation)
    balanceExplanation.snp.makeConstraints { make in
      make.left.top.equalToSuperview()
    }
  }

  func setUpBalanceLabel() {
    balanceLabel.font = uiConfiguration.amountBigFont
    balanceLabel.textColor = uiConfiguration.textPrimaryColor
    balanceLabel.textAlignment = .left
    addSubview(balanceLabel)
    balanceLabel.snp.makeConstraints { make in
      make.left.equalToSuperview()
      make.top.equalTo(balanceExplanation.snp.bottom).offset(4)
    }
  }

  func setUpSpendableExplanation() {
    spendableExplanation.text = "manage.shift.card.spendable-today".podLocalized()
    spendableExplanation.textColor = uiConfiguration.textSecondaryColor
    spendableExplanation.font = uiConfiguration.sectionTitleFont
    spendableExplanation.textAlignment = .right
    addSubview(spendableExplanation)
    spendableExplanation.snp.makeConstraints { make in
      make.right.top.equalToSuperview()
    }
  }

  func setUpSpendableLabel() {
    spendableLabel.font = uiConfiguration.amountBigFont
    spendableLabel.textColor = uiConfiguration.textPrimaryColor
    spendableLabel.textAlignment = .right
    addSubview(spendableLabel)
    spendableLabel.snp.makeConstraints { make in
      make.right.equalToSuperview()
      make.top.equalTo(spendableExplanation.snp.bottom).offset(4)
    }
  }

  func setUpBalanceBitCoins() {
    balanceBitCoins.font = uiConfiguration.subCurrencyFont
    balanceBitCoins.textColor = uiConfiguration.textTertiaryColor
    balanceBitCoins.textAlignment = .left
    addSubview(balanceBitCoins)
    balanceBitCoins.snp.makeConstraints { make in
      make.left.equalToSuperview()
      make.top.equalTo(balanceLabel.snp.bottom).offset(2)
      make.bottom.equalToSuperview()
    }
  }

  func setUpSpendableBitCoins() {
    spendableBitCoins.font = uiConfiguration.subCurrencyFont
    spendableBitCoins.textColor = uiConfiguration.textTertiaryColor
    spendableBitCoins.textAlignment = .right
    addSubview(spendableBitCoins)
    spendableBitCoins.snp.makeConstraints { make in
      make.right.equalToSuperview()
      make.top.equalTo(spendableLabel.snp.bottom).offset(2)
      make.bottom.equalToSuperview()
    }
  }
}
