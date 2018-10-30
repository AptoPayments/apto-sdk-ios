//
//  ChangeCardPINAction.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 12/03/2018.
//

import UIKit

class ChangeCardPINAction {
  private let shiftCardSession: ShiftCardSession
  private let card: Card
  private let uiConfig: ShiftUIConfig
  private var alert: ChangePinView?

  init(shiftCardSession: ShiftCardSession, card: Card, uiConfig: ShiftUIConfig) {
    self.uiConfig = uiConfig
    self.shiftCardSession = shiftCardSession
    self.card = card
  }

  func run() {
    let alert = ChangePinView(uiConfig: uiConfig)
    alert.delegate = self
    alert.show(animated: true)
    self.alert = alert
  }
}

extension ChangeCardPINAction: ChangePinViewDelegate {
  func newCardPin(pin: String) {
    var topViewController = UIApplication.topViewController()
    if let navigationController = topViewController?.navigationController {
      topViewController = navigationController
    }
    if let topViewController = topViewController, let alert = self.alert {
      let point = alert.dialogView.center
      topViewController.showLoadingSpinner(tintColor: uiConfig.uiPrimaryColor, position: .custom(coordinates: point))
    }
    alert?.dismiss(animated: true) { }
    shiftCardSession.changeCard(card: card, pin: pin) { [unowned self] result in
      topViewController?.hideLoadingSpinner()
      switch result {
      case .failure(let error):
        topViewController?.show(error: error)
      case .success:
        self.showPinChangedMessage()
      }
    }
  }

  func showPinChangedMessage() {
    let delayTime = DispatchTime.now() + Double(Int64(0.3 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
    DispatchQueue.main.asyncAfter(deadline: delayTime) {
      UIApplication.topViewController()?.showMessage("change.pin.success".podLocalized())
    }
  }
}
