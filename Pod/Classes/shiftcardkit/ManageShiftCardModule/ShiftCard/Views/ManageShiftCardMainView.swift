//
//  ManageShiftCardMainView.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 18/03/2017.
//
//

import Foundation
import SnapKit

protocol ManageShiftCardMainViewDelegate: class {
  func cardTapped()
}

class ManageShiftCardMainView: UIView {
  private let balanceView: BalanceView
  private let tapToManageView = UILabel()
  private var isActivateCardFeatureEnabled = false {
    didSet {
      activeStateReceived = true
      updateActivateFeatureState()
    }
  }
  private var cardState = FinancialAccountState.inactive {
    didSet {
      creditCardView.set(cardState: cardState)
      updateActivateFeatureState()
    }
  }
  private var showBalance = false
  private var activeStateReceived = false
  private var balanceReceived = false
  private let creditCardView: CreditCardView
  private unowned let delegate: ManageShiftCardMainViewDelegate
  private let uiConfiguration: ShiftUIConfig

  init(uiConfiguration: ShiftUIConfig, delegate: ManageShiftCardMainViewDelegate) {
    self.uiConfiguration = uiConfiguration
    self.delegate = delegate
    self.balanceView = BalanceView(uiConfiguration: uiConfiguration)
    self.creditCardView = CreditCardView(uiConfiguration: uiConfiguration)
    super.init(frame: .zero)
    setUpUI(uiConfiguration: uiConfiguration)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    refreshLayoutConstraints()
  }

  @objc func cardTapped() {
    // Disable card settings if the card is pending activation
    guard cardState != .created else {
      return
    }
    delegate.cardTapped()
  }

  func set(cardHolder: String?) {
    self.creditCardView.set(cardHolder: cardHolder)
  }

  func set(cardNumber: String?) {
    self.creditCardView.set(cardNumber: cardNumber)
  }

  func set(lastFour: String?) {
    self.creditCardView.set(lastFour: lastFour)
  }

  func set(cvv: String?) {
    self.creditCardView.set(cvc: cvv)
  }

  func set(cardNetwork: CardNetwork?) {
    self.creditCardView.set(cardNetwork: cardNetwork)
  }

  func set(expirationMonth: UInt, expirationYear: UInt) {
    self.creditCardView.set(expirationMonth: expirationMonth, expirationYear: expirationYear)
  }

  func set(fundingSource: FundingSource?) {
    balanceReceived = true
    if let fundingSource = fundingSource, fundingSource.balance != nil {
      balanceView.set(fundingSource: fundingSource)
      showBalance = true
    }
    else {
      showBalance = false
    }
    refreshLayoutConstraints()
  }

  private func nativeSpendableAmount(fundingSource: CustodianWallet) -> Amount {
    let balanceAmount = fundingSource.balance?.amount.value ?? 0
    let spendableAmount = fundingSource.amountSpendable?.amount.value ?? 0
    let nativeAmount = fundingSource.nativeBalance.amount.value ?? 0
    let nativeSpendableAmount: Double
    if nativeAmount == 0 {
      nativeSpendableAmount = 0
    }
    else {
      nativeSpendableAmount = balanceAmount / nativeAmount * spendableAmount
    }

    return Amount(value: nativeSpendableAmount, currency: fundingSource.nativeBalance.currency.value)
  }

  func set(cardState: FinancialAccountState?) {
    if let cardState = cardState {
      self.cardState = cardState
    }
    else {
      self.cardState = .inactive
    }
    refreshLayoutConstraints()
  }

  func set(activateCardFeatureEnabled: Bool?) {
    if let activateCardFeatureEnabled = activateCardFeatureEnabled {
      isActivateCardFeatureEnabled = activateCardFeatureEnabled
    }
    else {
      isActivateCardFeatureEnabled = false
    }
    refreshLayoutConstraints()
  }

  private func updateActivateFeatureState() {
    guard activeStateReceived else {
      return
    }
    if cardState == .created && isActivateCardFeatureEnabled {
      balanceView.alpha = 0.25
      tapToManageView.isHidden = true
    }
    else {
      balanceView.alpha = 1
      tapToManageView.isHidden = false
    }
  }

  func set(showInfo: Bool?) {
    if let visible = showInfo {
      creditCardView.set(showInfo: visible)
      self.tapToManageView.text = visible
        ? "manage.shift.card.tap-to-manage-card-copy-card".podLocalized()
        : "manage.shift.card.tap-to-manage-card".podLocalized()
    }
  }
}

// MARK: - Setup UI
private extension ManageShiftCardMainView {
  func setUpUI(uiConfiguration: ShiftUIConfig) {
    backgroundColor = uiConfiguration.backgroundColor
    balanceView.backgroundColor = backgroundColor
    setUpCreditCardView(uiConfiguration: uiConfiguration)
    setUpTapToManageView(uiConfiguration: uiConfiguration)
  }

  func setUpCreditCardView(uiConfiguration: ShiftUIConfig) {
    creditCardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cardTapped)))
  }

  func setUpTapToManageView(uiConfiguration: ShiftUIConfig) {
    tapToManageView.isUserInteractionEnabled = true
    tapToManageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cardTapped)))
    tapToManageView.font = uiConfiguration.instructionsFont
    tapToManageView.numberOfLines = 0
    tapToManageView.textColor = uiConfiguration.textTertiaryColor
    tapToManageView.textAlignment = .center
    tapToManageView.text = "manage.shift.card.tap-to-manage-card".podLocalized()
    tapToManageView.isUserInteractionEnabled = true
    tapToManageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cardTapped)))
    tapToManageView.isHidden = true
  }
}

// MARK: - Layout
private extension ManageShiftCardMainView {
  func refreshLayoutConstraints() {
    guard activeStateReceived == true, balanceReceived == true else {
      return
    }
    balanceView.snp.removeConstraints()
    creditCardView.snp.removeConstraints()
    tapToManageView.snp.removeConstraints()
    if showBalance {
      layoutBalance()
    }
    else {
      layoutHiddenBalance()
    }
    layoutTapToManageView()
  }

  func layoutBalance() {
    addSubview(balanceView)
    balanceView.snp.makeConstraints { make in
      make.top.equalToSuperview().offset(24)
      make.left.right.equalTo(self).inset(16)
    }
    layoutCreditCardView()
  }

  func layoutCreditCardView() {
    let cardAspectRatio = 1.585772508336421
    addSubview(creditCardView)
    creditCardView.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(26)
      make.height.equalTo(creditCardView.snp.width).dividedBy(cardAspectRatio)
      let topView = showBalance ? balanceView.snp.bottom : self.snp.top
      make.top.equalTo(topView).offset(12)
    }
  }

  func layoutHiddenBalance() {
    balanceView.removeFromSuperview()
    layoutCreditCardView()
  }

  func layoutTapToManageView() {
    addSubview(tapToManageView)
    tapToManageView.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(56)
      make.top.equalTo(creditCardView.snp.bottom).offset(18)
      make.height.equalTo(42)
      make.bottom.equalTo(self.snp.bottom)
    }
  }
}
