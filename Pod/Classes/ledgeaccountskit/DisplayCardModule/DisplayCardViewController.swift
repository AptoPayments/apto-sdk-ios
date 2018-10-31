//
//  DisplayCardViewController.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 24/10/2017.
//
//

import UIKit
import Stripe

protocol DisplayCardEventHandler {
  func viewLoaded()
  func previousTapped()
  func closeTapped()
  func addToWalletTapped()
}

class DisplayCardViewController: ShiftViewController, DisplayCardViewProtocol {

  let eventHandler: DisplayCardEventHandler
  var addToWalletButton: UIButton!
  var balanceView: UIView!
  var balanceLabel: UILabel!
  var balanceExplanation: UILabel!
  let creditCardView: CreditCardView!

  init(uiConfiguration: ShiftUIConfig, eventHandler:DisplayCardEventHandler) {
    self.eventHandler = eventHandler
    self.creditCardView = CreditCardView(
      uiConfiguration: uiConfiguration,
      cardStyle: CardStyle(background: .color(color: uiConfiguration.uiPrimaryColor)))
    super.init(uiConfiguration: uiConfiguration)
  }

  override func viewDidLoad() {

    super.viewDidLoad()
    self.title = "Card"
    self.view.backgroundColor = self.uiConfiguration.backgroundColor
    self.navigationController?.navigationBar.backgroundColor = self.uiConfiguration.uiPrimaryColor
    self.edgesForExtendedLayout = UIRectEdge()
    self.extendedLayoutIncludesOpaqueBars = true
    self.showNavPreviousButton(uiConfiguration.iconTertiaryColor)

    self.balanceView = UIView()
    view.addSubview(balanceView)
    balanceView.snp.makeConstraints { make in
      make.top.equalTo(view).offset(15)
      make.left.right.equalTo(view).inset(15)
    }

    self.balanceLabel = UILabel()
    balanceLabel.font = uiConfiguration.fonth1
    balanceLabel.textColor = uiConfiguration.tintColor
    balanceLabel.textAlignment = .center
    balanceView.addSubview(balanceLabel)
    balanceLabel.snp.makeConstraints { make in
      make.left.top.right.equalTo(balanceView)
      make.height.equalTo(40)
    }

    self.balanceExplanation = ComponentCatalog.formLabelWith(text: "CARD BALANCE",
                                                             textAlignment: .center,
                                                             uiConfig: uiConfiguration)
    balanceView.addSubview(balanceExplanation)
    balanceExplanation.snp.makeConstraints { make in
      make.top.equalTo(balanceLabel.snp.bottom).offset(15)
      make.height.equalTo(10)
      make.left.right.bottom.equalTo(balanceView)
    }

    view.addSubview(creditCardView)
    creditCardView.snp.makeConstraints { make in
      make.centerX.equalTo(view)
      make.height.equalTo(170)
      make.width.equalTo(300)
      make.top.equalTo(balanceView.snp.bottom).offset(30)
    }

    addToWalletButton = ComponentCatalog.buttonWith(title: "Add to Wallet", uiConfig: uiConfiguration) { [weak self] in
      self?.addToWalletTapped()
    }
    view.addSubview(addToWalletButton)
    addToWalletButton.snp.makeConstraints { make in
      make.bottom.equalTo(view.snp.bottom).inset(30)
      make.centerX.equalTo(view)
      make.width.equalTo(180)
      make.height.equalTo(44)
    }

    self.eventHandler.viewLoaded()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func set(cardNetwork: CardNetwork?,
           cardHolder: String?,
           pan: String?,
           cvv: String?,
           expirationMonth: UInt,
           expirationYear: UInt,
           cardBalance: Amount?,
           cardState: FinancialAccountState) {
    creditCardView.set(cardHolder: cardHolder)
    creditCardView.set(cardNumber: pan)
    creditCardView.set(expirationMonth: expirationMonth, expirationYear: expirationYear)
    creditCardView.set(cvc: cvv)
    creditCardView.set(showInfo: true)
    creditCardView.set(cardState: cardState)

    if let balance = cardBalance {
      balanceView.isHidden = false
      balanceLabel.text = balance.text
    }
    else {
      balanceView.isHidden = true
      balanceView.snp.remakeConstraints { make in
        make.height.equalTo(0)
      }
    }
  }

  func addToWalletTapped() {
    eventHandler.addToWalletTapped()
  }

  override func closeTapped() {
    eventHandler.closeTapped()
  }

  override func previousTapped() {
    eventHandler.previousTapped()
  }

  func showLoadingSpinner() {
    showLoadingSpinner(tintColor: uiConfiguration.uiPrimaryColor)
  }
}
