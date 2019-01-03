//
//  HelpAction.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 12/12/2018.
//

import UIKit

class HelpAction {
  private let emailRecipients: [String?]
  private let mailSender: MailSender

  init(emailRecipients: [String?]) {
    self.emailRecipients = emailRecipients
    self.mailSender = MailSender()
  }

  func run() {
    self.mailSender.sendMessageWith(subject: "help.email.subject".podLocalized(),
                                    message: "help.email.body".podLocalized(),
                                    recipients: self.emailRecipients)
  }
}
