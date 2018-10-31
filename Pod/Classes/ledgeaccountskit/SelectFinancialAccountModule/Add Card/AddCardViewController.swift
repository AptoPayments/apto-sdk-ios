//
//  AddCardViewController.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 20/10/2016.
//
//

import UIKit
import Stripe

protocol AddCardTypeEventHandler {
  func viewLoaded()
  func backTapped()
  func cardDataEntered(cardNumber:String, expirationMonth:UInt, expirationYear:UInt, cvv:String)
}

class AddCardViewController: ShiftViewController, AddCardViewProtocol {

  let eventHandler: AddCardTypeEventHandler
  var doneButton: UIButton!
  var scanCardButton: UIButton!
  let paymentField: STPPaymentCardTextField
  let creditCardView: CreditCardView!

  init(uiConfiguration: ShiftUIConfig, eventHandler:AddCardTypeEventHandler) {
    self.eventHandler = eventHandler
    self.paymentField = STPPaymentCardTextField(frame: CGRect(x: 10, y: 10, width:300, height: 44))
    self.creditCardView = CreditCardView(
      uiConfiguration: uiConfiguration,
      cardStyle: CardStyle(background: .color(color: uiConfiguration.uiPrimaryColor)))
    super.init(uiConfiguration: uiConfiguration)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = self.uiConfiguration.backgroundColor
    self.navigationController?.navigationBar.backgroundColor = self.uiConfiguration.uiPrimaryColor
    self.edgesForExtendedLayout = UIRectEdge()
    self.extendedLayoutIncludesOpaqueBars = true
    self.showNavPreviousButton(uiConfiguration.iconTertiaryColor)

    view.addSubview(creditCardView)
    creditCardView.snp.makeConstraints { make in
      make.centerX.equalTo(view)
      make.height.equalTo(170)
      make.width.equalTo(300)
      make.top.equalTo(view).offset(15)
    }
    view.addSubview(paymentField)
    paymentField.snp.makeConstraints { make in
      make.centerX.equalTo(view)
      make.height.equalTo(44)
      make.width.equalTo(300)
      make.top.equalTo(creditCardView.snp.bottom).offset(15)
    }
    paymentField.delegate = self
    paymentField.accessibilityLabel = "Card Data Field"

    let title = "select-financial-account.add-card-button.title".podLocalized()
    doneButton = ComponentCatalog.buttonWith(title: title,
                                             accessibilityLabel: "Add Card Button",
                                             uiConfig: uiConfiguration) { [weak self] in
                                              self?.doneTapped()
    }
    view.addSubview(doneButton)
    doneButton.snp.makeConstraints { make in
      make.top.equalTo(paymentField.snp.bottom).offset(30)
      make.centerX.equalTo(view)
      make.width.equalTo(180)
      make.height.equalTo(44)
    }
    doneButton.isEnabled = false
    doneButton.backgroundColor = uiConfiguration.disabledTintColor

    if CardIOUtilities.canReadCardWithCamera() {
      CardIOUtilities.preloadCardIO()
      let title = "select-financial-account.scan-card-button.title".podLocalized()
      scanCardButton = ComponentCatalog.formTextLinkButtonWith(title: title,
                                                               uiConfig: uiConfiguration) { [weak self] in
                                                                self?.scanCardTapped()
      }
      view.addSubview(scanCardButton)
      scanCardButton.snp.makeConstraints { make in
        make.top.equalTo(doneButton.snp.bottom).offset(30)
        make.left.right.equalTo(paymentField)
        make.height.equalTo(44)
      }
    }

    self.view.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                          action: #selector(AddCardViewController.hideKeyboard)))

    self.eventHandler.viewLoaded()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func viewWillAppear() {
    CardIOUtilities.preloadCardIO()
  }

  @objc func hideKeyboard() {
    paymentField.resignFirstResponder()
  }

  func set(cardHolder:String?) {
    creditCardView.set(cardHolder:cardHolder)
  }

  func set(cardInfoShown:Bool) {
    creditCardView.set(showInfo: cardInfoShown)
  }

  override func previousTapped() {
    eventHandler.backTapped()
  }

  func doneTapped() {
    self.hideKeyboard()
    let expYear = paymentField.cardParams.expYear < 100 ?
      2000 + paymentField.cardParams.expYear : paymentField.cardParams.expYear
    eventHandler.cardDataEntered(cardNumber: paymentField.cardParams.number!,
                                 expirationMonth: paymentField.cardParams.expMonth,
                                 expirationYear: expYear,
                                 cvv: paymentField.cardParams.cvc!)
  }

  func scanCardTapped() {
    self.hideKeyboard()
    let vc = CardIOPaymentViewController(paymentDelegate:self)
    vc?.hideCardIOLogo = true
    vc?.disableManualEntryButtons = true
    self.navigationController?.present(vc!, animated:true, completion:nil)
  }

  func showLoadingSpinner() {
    showLoadingSpinner(tintColor: uiConfiguration.uiPrimaryColor)
  }
}

extension AddCardViewController: STPPaymentCardTextFieldDelegate {

  func paymentCardTextFieldDidChange(_ textField: STPPaymentCardTextField) {
    doneButton.isEnabled = textField.isValid
    if doneButton.isEnabled {
      doneButton.backgroundColor = uiConfiguration.tintColor
      self.hideKeyboard()
    }
    else {
      doneButton.backgroundColor = uiConfiguration.disabledTintColor
    }

    // Update credit card view
    creditCardView.set(cardNumber:textField.cardNumber)
    creditCardView.set(expirationMonth:textField.expirationMonth, expirationYear:textField.expirationYear)
    creditCardView.set(cvc:textField.cvc)
  }

  func paymentCardTextFieldDidBeginEditingCVC(_ textField: STPPaymentCardTextField) {
    creditCardView.didBeginEditingCVC()
  }

  func paymentCardTextFieldDidEndEditingCVC(_ textField: STPPaymentCardTextField) {
    creditCardView.didEndEditingCVC()
  }
}

extension AddCardViewController: CardIOPaymentViewControllerDelegate {

  func userDidCancel(_ paymentViewController:CardIOPaymentViewController) {
    self.navigationController?.dismiss(animated: true, completion:nil)

  }

  func userDidProvide(_ cardInfo:CardIOCreditCardInfo, in inPaymentViewController:CardIOPaymentViewController) {
    self.navigationController?.dismiss(animated: true, completion:nil)
    eventHandler.cardDataEntered(cardNumber: cardInfo.cardNumber,
                                 expirationMonth: cardInfo.expiryMonth,
                                 expirationYear: cardInfo.expiryYear,
                                 cvv: cardInfo.cvv)
  }

}
