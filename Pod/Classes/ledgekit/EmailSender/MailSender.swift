//
//  MailSender.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 04/05/2018.
//

import UIKit
import MessageUI

class MailSender: NSObject {

  var composer: UIViewController?

  func canSendEmail() -> Bool {
    return MFMailComposeViewController.canSendMail()
  }

  func sendMessageWith(subject: String, message: String, recipients: [String?]) {

    guard canSendEmail() else {
      UIApplication.topViewController()?.showMessage("Email client not configured", uiConfig: nil)
      return
    }
    let filteredRecipients = recipients.compactMap { recipient -> String? in
      return recipient
    }
    let composer = MFMailComposeViewController()
    composer.mailComposeDelegate = self
    composer.setSubject(subject)
    composer.setMessageBody(message, isHTML: false)
    composer.setToRecipients(filteredRecipients)
    self.composer = composer
    UIApplication.topViewController()?.present(composer, animated: true, completion: nil)
  }

}

extension MailSender: MFMailComposeViewControllerDelegate {

  func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
    if let composer = self.composer {
      composer.dismiss(animated: true, completion: nil)
      self.composer = nil
    }
  }

}
