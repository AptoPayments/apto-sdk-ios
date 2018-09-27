//
//  EnableCardAction.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 12/03/2018.
//

import UIKit

class EnableCardAction {
  private let shiftCardSession: ShiftCardSession
  private let card: Card
  private let uiConfig: ShiftUIConfig

  init(shiftCardSession: ShiftCardSession, card: Card, uiConfig: ShiftUIConfig) {
    self.shiftCardSession = shiftCardSession
    self.card = card
    self.uiConfig = uiConfig
  }

  func run(callback: @escaping Result<Card, NSError>.Callback) {
    UIAlertController.confirm(title: "Confirm".podLocalized(),
                              message: "Do you want to activate your card?".podLocalized(),
                              okTitle: "general.button.ok".podLocalized(),
                              cancelTitle: "general.button.cancel".podLocalized(), handler: { action in
      guard action.title! != "general.button.cancel".podLocalized() else {
        callback(.failure(ServiceError(code: .aborted)))
        return
      }
      UIApplication.topViewController()?.showLoadingSpinner(tintColor: self.uiConfig.uiPrimaryColor)
      self.shiftCardSession.unlock(card: self.card) { result in
        switch result {
        case .failure(let error):
          UIApplication.topViewController()?.show(error: error)
          callback(.failure(error))
        case .success(let card):
          UIApplication.topViewController()?.hideLoadingSpinner()
          callback(.success(card))
        }
      }
    })
  }
}
