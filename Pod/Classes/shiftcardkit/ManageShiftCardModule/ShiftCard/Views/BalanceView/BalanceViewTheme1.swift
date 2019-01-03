//
//  BalanceViewTheme1.swift
//  ShiftSDK
//
//  Created by Takeichi Kanzaki on 09/08/2018.
//
//

import UIKit
import SnapKit

class BalanceViewTheme1: BalanceViewProtocol {
  private let balanceLabel = UILabel()
  private let balanceExplanation = UILabel()
  private let balanceBitCoins = UILabel()
  private let spendableLabel = UILabel()
  private let spendableExplanation = UILabel()
  private let spendableBitCoins = UILabel()
  private var showBalance = false {
    didSet {
      let hideBalanceInfo = !showBalance
      balanceExplanation.isHidden = hideBalanceInfo
      balanceLabel.isHidden = hideBalanceInfo
    }
  }
  private var showSpendable = false {
    didSet {
      let hideSpendableInfo = !showSpendable
      spendableExplanation.isHidden = hideSpendableInfo
      spendableLabel.isHidden = hideSpendableInfo
    }
  }
  private var showNativeBalance = false {
    didSet {
      balanceBitCoins.isHidden = !showNativeBalance
    }
  }
  private var showNativeSpendableBalance = false {
    didSet {
      spendableBitCoins.isHidden = !showNativeSpendableBalance
    }
  }

  private let uiConfiguration: ShiftUIConfig
  private var fundingSource: FundingSource?

  init(uiConfiguration: ShiftUIConfig) {
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
    showSpendableIfPresent(spendableToday: spendableToday, nativeSpendableToday: nativeSpendableToday)
  }
}

// MARK: - Update labels
private extension BalanceViewTheme1 {
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
      balanceBitCoins.text = custodianWallet.nativeBalance.longText
      showNativeBalance = true
    }
    else {
      showNativeBalance = false
    }
  }

  func showSpendableIfPresent(spendableToday: Amount?, nativeSpendableToday: Amount?) {
    guard fundingSource?.state != .invalid else { return }
    if let spendableToday = spendableToday {
      showSpendable = true
      spendableLabel.text = spendableToday.text
    }
    else {
      showSpendable = false
    }
    if let spendableToday = spendableToday,
      let nativeSpendableToday = nativeSpendableToday,
      !spendableToday.sameCurrencyThan(amount: nativeSpendableToday) {
      spendableBitCoins.text = nativeSpendableToday.longText
      showNativeSpendableBalance = true
    }
    else {
      showNativeSpendableBalance = false
    }
  }

  func showInvalidBalance() {
    let emptyBalance = "manage.shift.card.empty-balance".podLocalized()
    balanceLabel.text = emptyBalance
    spendableLabel.text = emptyBalance
    showBalance = true
    showSpendable = true
    showNativeBalance = false
    showNativeSpendableBalance = false
  }
}

// MARK: - Setup UI
private extension BalanceViewTheme1 {
  func setUpUI() {
    backgroundColor = uiConfiguration.uiBackgroundPrimaryColor
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
    balanceExplanation.font = uiConfiguration.fontProvider.sectionTitleFont
    balanceExplanation.textAlignment = .left
    addSubview(balanceExplanation)
    balanceExplanation.snp.makeConstraints { make in
      make.left.top.equalToSuperview()
    }
  }

  func setUpBalanceLabel() {
    balanceLabel.font = uiConfiguration.fontProvider.amountBigFont
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
    spendableExplanation.font = uiConfiguration.fontProvider.sectionTitleFont
    spendableExplanation.textAlignment = .right
    addSubview(spendableExplanation)
    spendableExplanation.snp.makeConstraints { make in
      make.right.top.equalToSuperview()
    }
  }

  func setUpSpendableLabel() {
    spendableLabel.font = uiConfiguration.fontProvider.amountBigFont
    spendableLabel.textColor = uiConfiguration.textPrimaryColor
    spendableLabel.textAlignment = .right
    addSubview(spendableLabel)
    spendableLabel.snp.makeConstraints { make in
      make.right.equalToSuperview()
      make.top.equalTo(spendableExplanation.snp.bottom).offset(4)
    }
  }

  func setUpBalanceBitCoins() {
    balanceBitCoins.font = uiConfiguration.fontProvider.subCurrencyFont
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
    spendableBitCoins.font = uiConfiguration.fontProvider.subCurrencyFont
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
