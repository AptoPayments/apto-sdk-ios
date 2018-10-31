//
//  ManageShiftCardMainView.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 18/03/2017.
//
//

import Foundation
import SnapKit

protocol ManageShiftCardMainViewDelegate: class {
  func cardTapped()
  func needToUpdateUI(action: () -> Void, completion: @escaping () -> Void)
  func activatePhysicalCardTapped()
  func addFundingSourceTapped()
}

private enum TopMessageViewType: Int, Equatable {
  case none
  case invalidBalance
  case noBalance
  case activatePhysicalCard
}

class ManageShiftCardMainView: UIView {
  private let balanceView: BalanceView
  private var topMessageView: ManageShiftCardTopMessageView?
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
  private var topMessageViewType = TopMessageViewType.none
  private let creditCardView: CreditCardView
  private unowned let delegate: ManageShiftCardMainViewDelegate
  private let uiConfiguration: ShiftUIConfig

  init(uiConfiguration: ShiftUIConfig, cardStyle: CardStyle?, delegate: ManageShiftCardMainViewDelegate) {
    self.uiConfiguration = uiConfiguration
    self.delegate = delegate
    self.balanceView = BalanceView(uiConfiguration: uiConfiguration)
    self.creditCardView = CreditCardView(uiConfiguration: uiConfiguration, cardStyle: cardStyle)
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
      creditCardView.set(validFundingSource: fundingSource.state == .valid)
      balanceView.set(fundingSource: fundingSource)
      showBalance = true
      if fundingSource.state == .invalid {
        topMessageViewType = .invalidBalance
      }
      else {
        topMessageViewType = .none
      }
    }
    else {
      showBalance = false
      topMessageViewType = .noBalance
      creditCardView.set(validFundingSource: false)
    }
    refreshLayoutConstraints()
  }

  func set(physicalCardActivationRequired: Bool?) {
    // If balance is not valid ignore the physical card activation
    guard topMessageViewType != .invalidBalance || topMessageViewType != .noBalance else { return }
    if physicalCardActivationRequired == true {
      topMessageViewType = .activatePhysicalCard
      refreshLayoutConstraints()
    }
  }

  func setSpendable(amount: Amount?, nativeAmount: Amount?) {
    balanceView.set(spendableToday: amount, nativeSpendableToday: nativeAmount)
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

  func set(cardStyle: CardStyle?) {
    creditCardView.set(cardStyle: cardStyle)
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
    tapToManageView.font = uiConfiguration.fontProvider.instructionsFont
    tapToManageView.numberOfLines = 0
    tapToManageView.textColor = uiConfiguration.textTertiaryColor
    tapToManageView.textAlignment = .center
    tapToManageView.text = "manage.shift.card.tap-to-manage-card".podLocalized()
    tapToManageView.isUserInteractionEnabled = true
    tapToManageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cardTapped)))
    tapToManageView.isHidden = true
  }

  func setUpInvalidBalanceView(uiConfiguration: ShiftUIConfig) -> ManageShiftCardTopMessageView {
    let config = ManageShiftCardTopMessageViewConfig(title: "invalid-balance.title".podLocalized(),
                                                     message: "invalid-balance.message".podLocalized(),
                                                     actionTitle: "invalid-balance.call-to-action".podLocalized(),
                                                     closeHandler: { [unowned self] in self.closeTopMessageView() },
                                                     actionHandler: { [unowned self] in self.cardTapped() })
    let topMessageView = ManageShiftCardTopMessageView(config: config, uiConfig: uiConfiguration)
    self.topMessageView = topMessageView
    return topMessageView
  }

  func setUpNoBalanceView(uiConfiguration: ShiftUIConfig) -> ManageShiftCardTopMessageView {
    let config = ManageShiftCardTopMessageViewConfig(title: "no-balance.title".podLocalized(),
                                                     message: "no-balance.message".podLocalized(),
                                                     actionTitle: "no-balance.call-to-action".podLocalized(),
                                                     closeHandler: { [unowned self] in self.closeTopMessageView() },
                                                     actionHandler: { [unowned self] in self.addFundingSource() })
    let topMessageView = ManageShiftCardTopMessageView(config: config, uiConfig: uiConfiguration)
    self.topMessageView = topMessageView
    return topMessageView
  }

  func setUpActivatePhysicalCardView(uiConfiguration: ShiftUIConfig) -> ManageShiftCardTopMessageView {
    let actionTitle = "activate-physical-card.call-to-action".podLocalized()
    let config = ManageShiftCardTopMessageViewConfig(title: "activate-physical-card.title".podLocalized(),
                                                     message: "activate-physical-card.message".podLocalized(),
                                                     actionTitle: actionTitle,
                                                     closeHandler: { [unowned self] in self.closeTopMessageView() },
                                                     actionHandler: { [unowned self] in self.activatePhysicalCard() })
    let topMessageView = ManageShiftCardTopMessageView(config: config, uiConfig: uiConfiguration)
    self.topMessageView = topMessageView
    return topMessageView
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
    removeTopMessageView()
    if topMessageViewType != .none {
      layoutTopMessageView()
    }
    else if showBalance {
      layoutBalance()
    }
    else {
      layoutHiddenBalance()
    }
    layoutTapToManageView()
  }

  private func removeTopMessageView() {
    topMessageView?.snp.removeConstraints()
    topMessageView?.removeFromSuperview()
    topMessageView = nil
  }

  func layoutTopMessageView() {
    balanceView.removeFromSuperview()
    guard let topMessageView = topMessageView(for: topMessageViewType) else { return }
    addSubview(topMessageView)
    balanceView.removeFromSuperview()
    topMessageView.snp.makeConstraints { make in
      make.top.left.right.equalToSuperview()
    }
    layoutCreditCardView()
  }

  func topMessageView(for type: TopMessageViewType) -> UIView? {
    switch type {
    case .invalidBalance:
      return setUpInvalidBalanceView(uiConfiguration: uiConfiguration)
    case .noBalance:
      return setUpNoBalanceView(uiConfiguration: uiConfiguration)
    case .activatePhysicalCard:
      return setUpActivatePhysicalCardView(uiConfiguration: uiConfiguration)
    case .none:
      return nil
    }
  }

  func layoutBalance() {
    addSubview(balanceView)
    topMessageView?.removeFromSuperview()
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
      make.top.equalTo(topView()).offset(12)
    }
  }

  func topView() -> ConstraintItem {
    if let topMessageView = self.topMessageView {
      return topMessageView.snp.bottom
    }
    return showBalance ? balanceView.snp.bottom : self.snp.top
  }

  func layoutHiddenBalance() {
    balanceView.removeFromSuperview()
    topMessageView?.removeFromSuperview()
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

// MARK: - ManageShiftCardTopMessageView actions
extension ManageShiftCardMainView {
  func closeTopMessageView() {
    topMessageViewType = .none
    self.delegate.needToUpdateUI(action: { [unowned self] in
                                   self.balanceView.alpha = 0
                                   refreshLayoutConstraints()
                                 },
                                 completion: { [unowned self] in
                                   self.animate(animations: {
                                     self.balanceView.alpha = 1
                                   }, completion: nil)
                                 })
  }

  func addFundingSource() {
    self.delegate.addFundingSourceTapped()
  }

  func activatePhysicalCard() {
    delegate.activatePhysicalCardTapped()
  }
}
