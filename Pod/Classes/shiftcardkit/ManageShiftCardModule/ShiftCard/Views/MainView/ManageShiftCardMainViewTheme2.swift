//
// ManageShiftCardMainViewTheme2.swift
// ShiftSDK
//
// Created by Takeichi Kanzaki on 2018-12-12.
//

import UIKit
import SnapKit

class ManageShiftCardMainViewTheme2: UIView, CardPresentationProtocol {
  private let balanceView: BalanceViewProtocol
  private let balanceBackgroundView = UIView()
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
  private var fundingSourceState: FundingSourceState?
  private var activeStateReceived = false
  private var balanceReceived = false
  private var topMessageViewType = TopMessageViewType.none
  private let gearView = UIImageView(image: UIImage.imageFromPodBundle("btn_card_settings", uiTheme: .theme2))
  private let creditCardView: CreditCardView
  private unowned let delegate: ManageShiftCardMainViewDelegate
  private let uiConfiguration: ShiftUIConfig

  init(uiConfiguration: ShiftUIConfig, cardStyle: CardStyle?, delegate: ManageShiftCardMainViewDelegate) {
    self.uiConfiguration = uiConfiguration
    self.delegate = delegate
    self.balanceView = BalanceViewTheme2(uiConfiguration: uiConfiguration)
    self.creditCardView = CreditCardView(uiConfiguration: uiConfiguration, cardStyle: cardStyle)
    super.init(frame: .zero)
    setUpUI()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    refreshLayoutConstraints()
  }

  @objc private func cardTapped() {
    hideMessage(animated: true)
    delegate.cardTapped()
  }

  @objc private func cardSettingsTapped() {
    delegate.cardSettingsTapped()
  }

  @objc private func balanceTapped() {
    delegate.balanceTapped()
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
    fundingSourceState = fundingSource?.state
    balanceReceived = true
    if let fundingSource = fundingSource, fundingSource.balance != nil {
      creditCardView.set(validFundingSource: fundingSource.state == .valid)
      balanceView.set(fundingSource: fundingSource)
      if fundingSource.state == .invalid {
        topMessageViewType = .invalidBalance
        showInvalidBalanceMessage()
      }
      else {
        if topMessageViewType != .activatePhysicalCard {
          hideMessage()
        }
        topMessageViewType = .none
      }
    }
    else {
      showNoBalanceMessage()
      creditCardView.set(validFundingSource: false)
      let fundingSource = FundingSource(fundingSourceId: "",
                                        type: .custodianWallet,
                                        balance: nil,
                                        amountHold: nil,
                                        state: .invalid)
      balanceView.set(fundingSource: fundingSource)
    }
    refreshLayoutConstraints()
  }

  func set(physicalCardActivationRequired: Bool?) {
    // If balance is not valid ignore the physical card activation
    guard topMessageViewType != .invalidBalance || topMessageViewType != .noBalance else { return }
    if physicalCardActivationRequired == true {
      topMessageViewType = .activatePhysicalCard
      showActivatePhysicalCardMessage()
      refreshLayoutConstraints()
    }
  }

  func setSpendable(amount: Amount?, nativeAmount: Amount?) {
    balanceView.set(spendableToday: amount, nativeSpendableToday: nativeAmount)
  }

  func set(cardState: FinancialAccountState?) {
    if let cardState = cardState {
      self.cardState = cardState
      gearView.isHidden = cardState == .created
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
    }
    else {
      balanceView.alpha = 1
    }
  }

  func set(showInfo: Bool?) {
    if let visible = showInfo {
      creditCardView.set(showInfo: visible)
    }
  }
}

// MARK: - Setup UI
private extension ManageShiftCardMainViewTheme2 {
  func setUpUI() {
    backgroundColor = uiConfiguration.uiBackgroundSecondaryColor
    setUpCreditCardView()
    setUpGearView()
    setUpBalanceView()
  }

  func setUpCreditCardView() {
    creditCardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cardTapped)))
  }

  func setUpGearView() {
    gearView.contentMode = .center
    gearView.backgroundColor = uiConfiguration.uiPrimaryColor
    gearView.layer.cornerRadius = 18
    gearView.layer.shadowOffset = CGSize(width: 0, height: 2)
    gearView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6).cgColor
    gearView.layer.shadowOpacity = 1
    gearView.layer.shadowRadius = 8
    gearView.isUserInteractionEnabled = true
    gearView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cardSettingsTapped)))
  }

  func setUpBalanceView() {
    balanceView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(balanceTapped)))
  }

  func showInvalidBalanceMessage() {
    show(message: "invalid-balance.message".podLocalized(),
         title: "invalid-balance.title".podLocalized(),
         animated: false,
         isError: true,
         uiConfig: uiConfiguration) { [unowned self] in
      self.balanceTapped()
    }
  }

  func showNoBalanceMessage() {
    show(message: "no-balance.message".podLocalized(),
         title: "no-balance.title".podLocalized(),
         animated: false,
         isError: true,
         uiConfig: uiConfiguration) { [unowned self] in
      self.balanceTapped()
    }
  }

  func showActivatePhysicalCardMessage() {
    show(message: "manage_card.activate_physical_card_overlay.message".podLocalized(),
         title: "manage_card.activate_physical_card_overlay.title".podLocalized(),
         animated: false,
         isError: false,
         uiConfig: uiConfiguration) { [unowned self] in
      self.activatePhysicalCard()
    }
  }
}

// MARK: - Layout
private extension ManageShiftCardMainViewTheme2 {
  func refreshLayoutConstraints() {
    guard activeStateReceived == true, balanceReceived == true else {
      return
    }
    balanceView.snp.removeConstraints()
    balanceBackgroundView.snp.removeConstraints()
    creditCardView.snp.removeConstraints()
    gearView.snp.removeConstraints()
    layoutBalance()
    layoutCreditCardView()
  }

  func layoutBalance() {
    addSubview(balanceView)
    balanceView.snp.makeConstraints { make in
      make.top.equalToSuperview().offset(4)
      make.left.right.equalToSuperview().inset(16)
    }
    balanceBackgroundView.removeFromSuperview()
    balanceBackgroundView.backgroundColor = uiConfiguration.uiNavigationSecondaryColor
    addSubview(balanceBackgroundView)
    balanceBackgroundView.snp.makeConstraints { make in
      make.left.top.right.equalToSuperview()
      make.bottom.equalTo(balanceView)
    }
    bringSubview(toFront: balanceView)
  }

  func layoutCreditCardView() {
    creditCardView.removeFromSuperview()
    addSubview(creditCardView)
    creditCardView.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(26)
      make.height.equalTo(creditCardView.snp.width).dividedBy(cardAspectRatio)
      make.top.equalTo(topConstraint()).offset(12)
      make.bottom.equalToSuperview().inset(16)
    }
    let backgroundView = UIView()
    backgroundView.backgroundColor = uiConfiguration.uiNavigationSecondaryColor
    addSubview(backgroundView)
    backgroundView.snp.makeConstraints { make in
      make.left.right.equalToSuperview()
      make.top.equalTo(topConstraint())
      make.height.equalTo(creditCardView).dividedBy(2).offset(12)
    }
    bringSubview(toFront: creditCardView)
    layoutGearView()
  }

  func layoutGearView() {
    gearView.removeFromSuperview()
    addSubview(gearView)
    gearView.snp.makeConstraints { make in
      make.height.width.equalTo(36)
      make.top.equalTo(topConstraint()).offset(6)
      make.right.equalToSuperview().inset(20)
    }
  }

  func topConstraint() -> ConstraintItem {
    return balanceView.snp.bottom
  }

  func layoutHiddenBalance() {
    balanceView.removeFromSuperview()
    layoutCreditCardView()
  }
}

// MARK: - MessageView actions
extension ManageShiftCardMainViewTheme2 {
  func activatePhysicalCard() {
    delegate.activatePhysicalCardTapped()
  }
}
