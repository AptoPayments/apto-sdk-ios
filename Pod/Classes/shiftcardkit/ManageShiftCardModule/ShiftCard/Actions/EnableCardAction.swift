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
    UIAlertController.confirm(title: "card_settings.settings.confirm_unlock_card.title".podLocalized(),
                              message: "card_settings.settings.confirm_unlock_card.message".podLocalized(),
                              okTitle: "card_settings.settings.confirm_unlock_card.ok_button".podLocalized(),
                              cancelTitle: "card_settings.settings.confirm_unlock_card.cancel_button".podLocalized(), handler: { action in
      guard action.title! != "card_settings.settings.confirm_unlock_card.cancel_button".podLocalized() else {
        callback(.failure(ServiceError(code: .aborted)))
        return
      }
      UIApplication.topViewController()?.showLoadingSpinner(tintColor: self.uiConfig.uiPrimaryColor)
      self.shiftCardSession.unlock(card: self.card) { [unowned self] result in
        switch result {
        case .failure(let error):
          UIApplication.topViewController()?.show(error: error, uiConfig: self.uiConfig)
          callback(.failure(error))
        case .success(let card):
          UIApplication.topViewController()?.hideLoadingSpinner()
          callback(.success(card))
        }
      }
    })
  }
}
