//
//  CreditCardView.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 29/11/2016.
//
//

import Foundation
import SnapKit
import UIKit
import Stripe

class CreditCardView: UIView {
  private let uiConfiguration: ShiftUIConfig
  // Container View
  private var showingBack = false
  private let logos: [CardNetwork: UIImage?] = [
    .visa: UIImage.imageFromPodBundle("card_network_visa")?.asTemplate(),
    .mastercard: UIImage.imageFromPodBundle("card_network_mastercard")?.asTemplate(),
    .amex: UIImage.imageFromPodBundle("card_logo_amex"),
    .other: nil
  ]

  // MARK: - Front View
  private let frontView = UIView()
  private let imageView = UIImageView()
  private let cardNumber = UIFormattedLabel()
  private let cardHolder = UILabel()
  private let expireDate = UIFormattedLabel()
  private let expireDateText = UILabel()
  private let frontCvv = UIFormattedLabel()
  private let frontCvvText = UILabel()
  private let lockImageView = UIImageView(image: UIImage.imageFromPodBundle("card-locked-icon"))

  // MARK: - Back View
  private let backView = UIView()
  private let backImage = UIImageView()
  private let cvc = UIFormattedLabel()
  private let backLine = UIView()

  // MARK: - State
  private var cardState: FinancialAccountState = .active
  private var cardInfoShown = false {
    didSet {
      cardNumber.isUserInteractionEnabled = cardInfoShown
    }
  }
  private var cardNumberText: String?
  private var lastFourText: String?
  private var cardHolderText: String?
  private var expirationMonth: UInt?
  private var expirationYear: UInt?
  private var cvvText: String?
  private var cardNetwork: CardNetwork?

  // MARK: - Lifecycle
  init(uiConfiguration: ShiftUIConfig) {
    self.uiConfiguration = uiConfiguration
    super.init(frame: .zero)
    self.translatesAutoresizingMaskIntoConstraints = false
    self.layer.cornerRadius = 10
    self.backgroundColor = uiConfiguration.cardBackgroundColor
    setUpShadow()
    setupFrontView()
    setupBackView()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Public methods

  func set(cardHolder: String?) {
    cardHolderText = cardHolder?.uppercased()
    updateCard()
  }

  func set(cardNumber: String?) {
    cardNumberText = cardNumber
    updateCard()
  }

  func set(lastFour: String?) {
    lastFourText = lastFour
    updateCard()
  }

  func set(expirationMonth: UInt, expirationYear: UInt) {
    self.expirationMonth = expirationMonth
    self.expirationYear = expirationYear
    updateCard()
  }

  func set(cvc: String?) {
    cvvText = cvc
    updateCard()
  }

  func set(cardState: FinancialAccountState) {
    self.cardState = cardState
    updateCard()
  }

  func set(showInfo: Bool) {
    self.cardInfoShown = showInfo
    updateCard()
  }

  func set(cardNetwork: CardNetwork?) {
    self.cardNetwork = cardNetwork
    updateCard()
  }

  func didBeginEditingCVC() {
    if !showingBack {
      flip()
      showingBack = true
    }
  }

  func didEndEditingCVC() {
    if showingBack {
      flip()
      showingBack = false
    }
  }

  // MARK: - Private methods

  fileprivate func flip() {
    var showingSide: UIView = frontView
    var hiddenSide: UIView = backView
    if showingBack {
      (showingSide, hiddenSide) = (backView, frontView)
    }
    UIView.transition(from: showingSide,
                      to: hiddenSide,
                      duration: 0.7,
                      options: [.transitionFlipFromRight, .showHideTransitionViews],
                      completion: nil)
  }

  fileprivate func set(cardNetwork: CardNetwork, enabled: Bool, alpha: CGFloat) {
    UIView.animate(withDuration: 2) {
      let color = enabled ? self.uiConfiguration.cardBackgroundColor : self.uiConfiguration.cardBackgroundColorDisabled
      self.imageView.tintColor = self.uiConfiguration.textTopBarColor
      self.imageView.image = self.logos[cardNetwork]! // swiftlint:disable:this force_unwrapping
      self.backView.backgroundColor = color
    }
  }
}

// MARK: - Setup UI
private extension CreditCardView {
  func setUpShadow() {
    layer.shadowOffset = CGSize(width: 0, height: 16)
    layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.16).cgColor
    layer.shadowOpacity = 1
    layer.shadowRadius = 16
  }

  func setupFrontView() {
    frontView.translatesAutoresizingMaskIntoConstraints = false
    frontView.layer.cornerRadius = 10
    frontView.clipsToBounds = true
    self.addSubview(frontView)
    frontView.isHidden = false
    frontView.snp.makeConstraints { make in
      make.top.bottom.left.right.equalTo(self)
    }
    setUpImageView()
    setUpExpireDateText()
    setUpExpireDate()
    setUpFrontCVVText()
    setUpFrontCVV()
    setUpCardHolderView()
    setUpCardNumberView()
    setUpLockImageView()
  }

  func setUpImageView() {
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.contentMode = .bottomRight
    frontView.addSubview(imageView)
    imageView.snp.makeConstraints { make in
      make.width.equalTo(60)
      make.height.equalTo(40)
      make.right.equalTo(frontView).inset(20)
      make.bottom.equalTo(frontView).inset(16)
    }
  }

  func setUpExpireDateText() {
    expireDateText.translatesAutoresizingMaskIntoConstraints = false
    expireDateText.font = uiConfiguration.cardLabelFont
    expireDateText.text = "EXP"
    expireDateText.textColor = uiConfiguration.cardLabelColor
    frontView.addSubview(expireDateText)
    expireDateText.snp.makeConstraints { make in
      make.bottom.equalTo(frontView).inset(16)
      make.left.equalTo(frontView).offset(20)
    }
  }

  func setUpExpireDate() {
    expireDate.translatesAutoresizingMaskIntoConstraints = false
    expireDate.font = uiConfiguration.cardSmallValueFont
    expireDate.formattingPattern = "**/****"
    expireDate.textColor = uiConfiguration.textTopBarColor
    frontView.addSubview(expireDate)
    expireDate.snp.makeConstraints { make in
      make.bottom.equalTo(expireDateText)
      make.left.equalTo(expireDateText.snp.right).offset(4)
    }
  }

  func setUpFrontCVVText() {
    frontCvvText.translatesAutoresizingMaskIntoConstraints = false
    frontCvvText.font = uiConfiguration.cardLabelFont
    frontCvvText.text = "CVV"
    frontCvvText.textColor = uiConfiguration.cardLabelColor
    frontView.addSubview(frontCvvText)
    frontCvvText.snp.makeConstraints { make in
      make.bottom.equalTo(expireDate)
      make.left.equalTo(expireDate.snp.right).offset(20)
    }
  }

  func setUpFrontCVV() {
    frontCvv.translatesAutoresizingMaskIntoConstraints = false
    frontCvv.font = uiConfiguration.cardSmallValueFont
    frontCvv.formattingPattern = "***"
    frontCvv.textColor = uiConfiguration.textTopBarColor
    frontView.addSubview(frontCvv)
    frontCvv.snp.makeConstraints { make in
      make.bottom.equalTo(frontCvvText)
      make.left.equalTo(frontCvvText.snp.right).offset(4)
    }
  }

  func setUpCardHolderView() {
    cardHolder.translatesAutoresizingMaskIntoConstraints = false
    cardHolder.font = uiConfiguration.cardSmallValueFont
    cardHolder.text = ""
    cardHolder.textColor = uiConfiguration.textTopBarColor
    cardHolder.adjustsFontSizeToFitWidth = true
    frontView.addSubview(cardHolder)
    cardHolder.snp.makeConstraints { make in
      make.bottom.equalTo(expireDate.snp.top).offset(-12)
      make.left.right.equalToSuperview().inset(20)
    }
  }

  func setUpCardNumberView() {
    cardNumber.translatesAutoresizingMaskIntoConstraints = false
    cardNumber.formattingPattern = "**** **** **** ****"
    cardNumber.textColor = uiConfiguration.textTopBarColor
    cardNumber.textAlignment = .center
    cardNumber.font = uiConfiguration.cardLargeValueFont
    cardNumber.adjustsFontSizeToFitWidth = true
    cardNumber.isUserInteractionEnabled = false
    cardNumber.addTapGestureRecognizer { [unowned self] in
      UIPasteboard.general.string = self.cardNumberText
      UIApplication.topViewController()?.showMessage("credit.card-number-copied".podLocalized())
    }
    frontView.addSubview(cardNumber)
    cardNumber.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.left.right.equalToSuperview().inset(16)
    }
  }

  func setUpLockImageView() {
    lockImageView.contentMode = .center
    addSubview(lockImageView)
    lockImageView.snp.makeConstraints { make in
      make.left.top.right.bottom.equalToSuperview()
    }
  }

  func setupBackView() {
    backView.translatesAutoresizingMaskIntoConstraints = false
    backView.layer.cornerRadius = 10
    backView.clipsToBounds = true
    self.addSubview(backView)
    backView.isHidden = true
    backView.backgroundColor = uiConfiguration.cardBackgroundColor
    backView.snp.makeConstraints { make in
      make.top.bottom.left.right.equalTo(self)
    }
    setUpBackLine()
    setUpCVC()
  }

  func setUpBackLine() {
    backLine.translatesAutoresizingMaskIntoConstraints = false
    backLine.backgroundColor = colorize(0x000000)
    backView.addSubview(backLine)
    backLine.snp.makeConstraints { make in
      make.top.equalTo(backView).offset(20)
      make.centerX.equalTo(backView)
      make.width.equalTo(300)
      make.height.equalTo(50)
    }
  }

  func setUpCVC() {
    cvc.translatesAutoresizingMaskIntoConstraints = false
    cvc.formattingPattern = "***"
    cvc.backgroundColor = uiConfiguration.textTopBarColor
    cvc.textAlignment = .center
    backView.addSubview(cvc)
    cvc.snp.makeConstraints { make in
      make.top.equalTo(backLine.snp.bottom).offset(10)
      make.width.equalTo(50)
      make.height.equalTo(25)
      make.right.equalTo(backView).inset(10)
    }
  }
}

// MARK: - Update card info
private extension CreditCardView {
  func updateCard() {
    cardHolder.text = self.cardHolderText
    updateCardInfo()
    updateCardEnabledState()
    updateCardNetwork()
  }

  func updateCardInfo() {
    if !self.cardInfoShown {
      hideCardInfo()
    }
    else {
      showCardInfo()
    }
  }

  func hideCardInfo() {
    if let lastFourText = lastFourText {
      cardNumber.text = "**** **** **** \(lastFourText)"
    }
    else {
      cardNumber.text = "**** **** **** ****"
    }
    expireDate.text = "**/**"
    frontCvv.text = "***"
  }

  func showCardInfo() {
    if let cardNumberText = self.cardNumberText {
      cardNumber.text = cardNumberText
    }
    else {
      cardNumber.text = ""
    }
    if let expirationMonth = expirationMonth, let expirationYear = expirationYear {
      expireDate.text = NSString(format: "%02ld", expirationMonth) as String + "/\(expirationYear)" as String
    }
    else {
      expireDate.text = "MM/YY"
    }
    if let cvv = self.cvvText {
      frontCvv.text = cvv
    }
  }

  func updateCardEnabledState() {
    if cardState == .active {
      setUpEnabledCard()
    }
    else {
      setUpDisabledCard()
    }
  }

  func setUpEnabledCard() {
    backgroundColor = uiConfiguration.cardBackgroundColor
    frontView.layer.borderWidth = 0
    cardHolder.textColor = uiConfiguration.textTopBarColor
    cardNumber.textColor = uiConfiguration.textTopBarColor
    expireDateText.textColor = uiConfiguration.textTopBarColor
    expireDate.textColor = uiConfiguration.textTopBarColor
    frontCvv.textColor = uiConfiguration.textTopBarColor
    frontCvvText.textColor = uiConfiguration.textTopBarColor
    imageView.alpha = 1
    lockImageView.isHidden = true
  }

  func setUpDisabledCard() {
    backgroundColor = uiConfiguration.cardBackgroundColorDisabled
    cardHolder.textColor = uiConfiguration.disabledTextTopBarColor
    cardNumber.textColor = uiConfiguration.disabledTextTopBarColor
    expireDateText.textColor = uiConfiguration.disabledTextTopBarColor
    expireDate.textColor = uiConfiguration.disabledTextTopBarColor
    frontCvv.textColor = uiConfiguration.disabledTextTopBarColor
    frontCvvText.textColor = uiConfiguration.disabledTextTopBarColor
    lockImageView.image = cardState == .created
      ? UIImage.imageFromPodBundle("icon-card-activate")
      : UIImage.imageFromPodBundle("card-locked-icon")
    lockImageView.isHidden = false
    imageView.alpha = 0.4
    bringSubview(toFront: lockImageView)
  }

  func updateCardNetwork() {
    let enabled = cardState == .active
    if let cardNetwork = cardNetwork {
      self.set(cardNetwork: cardNetwork, enabled: enabled, alpha: 1)
    }
    else {
      if let cardNumberText = self.cardNumberText {
        let stripeCardType = STPCardValidator.brand(forNumber: cardNumberText)
        switch stripeCardType {
        case .visa:
          self.set(cardNetwork: .visa, enabled: enabled, alpha: 1)
        case .masterCard:
          self.set(cardNetwork: .mastercard, enabled: enabled, alpha: 1)
        case .amex:
          self.set(cardNetwork: .amex, enabled: enabled, alpha: 1)
        default:
          self.set(cardNetwork: .other, enabled: enabled, alpha: 1)
        }
      }
      else {
        self.set(cardNetwork: .other, enabled: enabled, alpha: 1)
      }
    }
  }
}
