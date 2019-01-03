//
//  ReportLostCardAction.swift
//  ShiftSDK
//
// Created by Takeichi Kanzaki on 16/10/2018.
//

import UIKit

class ReportLostCardAction {
  private let session: ShiftCardSession
  private let card: Card
  private let emailRecipients: [String?]
  private let uiConfig: ShiftUIConfig
  private let mailSender: MailSender

  init(session: ShiftCardSession, card: Card, emailRecipients: [String?], uiConfig: ShiftUIConfig) {
    self.session = session
    self.card = card
    self.emailRecipients = emailRecipients
    self.mailSender = MailSender()
    self.uiConfig = uiConfig
  }

  func run(callback: @escaping Result<Card, NSError>.Callback) {
    UIAlertController.confirm(title: "card_settings.settings.confirm_report_lost_card.title".podLocalized(),
                              message: "card_settings.settings.confirm_report_lost_card.message".podLocalized(),
                              okTitle: "card_settings.settings.confirm_report_lost_card.ok_button".podLocalized(),
                              cancelTitle: "card_settings.settings.confirm_report_lost_card.cancel_button".podLocalized()) { [unowned self] action in
      guard let title = action.title, title != "card_settings.settings.confirm_report_lost_card.cancel_button".podLocalized() else {
        callback(.failure(ServiceError(code: .aborted)))
        return
      }
      UIApplication.topViewController()?.showLoadingSpinner(tintColor: self.uiConfig.uiPrimaryColor)
      self.session.lock(card: self.card) { result in
        switch result {
        case .failure(let error):
          UIApplication.topViewController()?.show(error: error, uiConfig: self.uiConfig)
          callback(.failure(error))
        case .success(let card):
          UIApplication.topViewController()?.hideLoadingSpinner()
          self.mailSender.sendMessageWith(subject: "email.lost-card.subject".podLocalized(),
                                          message: "",
                                          recipients: self.emailRecipients)
          callback(.success(card))
        }
      }
    }
  }
}
