//
// BalanceViewTheme2.swift
// ShiftSDK
//
// Created by Takeichi Kanzaki on 2018-12-11.
//

import UIKit
import SnapKit

class BalanceViewTheme2: BalanceViewProtocol {
  private let balanceLabel = UILabel()
  private let balanceExplanation: UILabel
  private let balanceBitCoins = UILabel()
  private var showBalance = false {
    didSet {
      let hideBalanceInfo = !showBalance
      balanceExplanation.isHidden = hideBalanceInfo
      balanceLabel.isHidden = hideBalanceInfo
    }
  }
  private var showNativeBalance = false {
    didSet {
      balanceBitCoins.isHidden = !showNativeBalance
    }
  }

  private let uiConfiguration: ShiftUIConfig
  private var fundingSource: FundingSource?

  init(uiConfiguration: ShiftUIConfig) {
    let label = "manage.shift.card.current-balance".podLocalized()
    self.balanceExplanation = ComponentCatalog.starredSectionTitleLabelWith(text: label, uiConfig: uiConfiguration)
    self.uiConfiguration = uiConfiguration
    super.init(frame: .zero)
    setUpUI()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func set(fundingSource: FundingSource) {
    self.fundingSource = fundingSource
    guard fundingSource.state == .valid else {
      showInvalidBalance()
      return
    }
    showBalanceIfPresent(in: fundingSource)
  }

  func set(spendableToday: Amount?, nativeSpendableToday: Amount?) {
  }
}

// MARK: - Update labels
private extension BalanceViewTheme2 {
  func showBalanceIfPresent(in fundingSource: FundingSource) {
    if let balance = fundingSource.balance {
      balanceLabel.text = balance.text
      showBalance = true
    }
    else {
      showBalance = false
    }
    if let custodianWallet = fundingSource as? CustodianWallet,
       let balance = fundingSource.balance,
       !balance.sameCurrencyThan(amount: custodianWallet.nativeBalance) {
      balanceBitCoins.text = " ≈ " + custodianWallet.nativeBalance.longText
      showNativeBalance = true
    }
    else {
      showNativeBalance = false
    }
  }

  func showInvalidBalance() {
    let emptyBalance = "manage.shift.card.empty-balance".podLocalized()
    balanceLabel.text = emptyBalance
    showBalance = true
    showNativeBalance = false
  }
}

// MARK: - Setup UI
private extension BalanceViewTheme2 {
  func setUpUI() {
    backgroundColor = uiConfiguration.uiNavigationSecondaryColor
    setUpBalanceExplanation()
    setUpBalanceLabel()
    setUpBalanceBitCoins()
  }

  func setUpBalanceExplanation() {
    addSubview(balanceExplanation)
    balanceExplanation.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.left.equalToSuperview().offset(8)
    }
  }

  func setUpBalanceLabel() {
    balanceLabel.font = uiConfiguration.fontProvider.amountBigFont
    balanceLabel.textColor = uiConfiguration.textTopBarColor
    balanceLabel.textAlignment = .left
    addSubview(balanceLabel)
    balanceLabel.snp.makeConstraints { make in
      make.left.equalTo(balanceExplanation)
      make.top.equalTo(balanceExplanation.snp.bottom).offset(6)
      make.bottom.equalToSuperview().inset(8)
    }
  }

  func setUpBalanceBitCoins() {
    balanceBitCoins.font = uiConfiguration.fontProvider.subCurrencyFont
    balanceBitCoins.textColor = uiConfiguration.textTopBarColor.withAlphaComponent(0.7)
    balanceBitCoins.textAlignment = .left
    addSubview(balanceBitCoins)
    balanceBitCoins.snp.makeConstraints { make in
      make.left.equalTo(balanceLabel.snp.right)
      make.bottom.equalTo(balanceLabel)
    }
  }
}
