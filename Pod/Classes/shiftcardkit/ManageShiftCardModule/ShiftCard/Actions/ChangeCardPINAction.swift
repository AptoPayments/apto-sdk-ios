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
    UIApplication.topViewController()?.showLoadingSpinner(tintColor: uiConfig.tintColor)
    self.shiftCardSession.changeCard(card: card, pin: pin) { result in
      switch result {
      case .failure(let error):
        UIApplication.topViewController()?.show(error: error)
      case .success:
        UIApplication.topViewController()?.hideLoadingSpinner()
        if let alert = self.alert {
          alert.dismiss(animated: true) {
            self.showPinChangedMessage()
          }
        }
        else {
          self.showPinChangedMessage()
        }
      }
    }
  }

  func showPinChangedMessage() {
    let delayTime = DispatchTime.now() + Double(Int64(0.3 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
    DispatchQueue.main.asyncAfter(deadline: delayTime) {
      UIApplication.topViewController()?.showMessage("Card PIN has been changed")
    }
  }
}
