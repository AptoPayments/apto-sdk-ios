//
//  EmailChannel.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 22/06/16.
//
//

import Foundation
import MessageUI

class EmailChannel: NSObject, MessagingManagerChannel {
  var delegate: MessagingManagerChannelDelegate?
  
  func channelAvailable() -> Bool {
    return MFMailComposeViewController.canSendMail()
  }
  
  func sendMessageWith(subject:String, message:String, url:URL?, recipients:[String]?) {
    guard self.channelAvailable() else {
      self.delegate?.didCancelFor(channel: self)
      return
    }
    let composer = MFMailComposeViewController()
    composer.mailComposeDelegate = self
    composer.setSubject(subject)
    composer.setMessageBody(message, isHTML: false)
    composer.setToRecipients(recipients)
    UIApplication.topViewController()?.present(composer, animated: true, completion: nil)
  }
}

extension EmailChannel: MFMailComposeViewControllerDelegate {
  func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
    switch (result) {
    case MFMailComposeResult.sent:
      self.delegate?.didSucceededFor(channel: self)
      UIApplication.topViewController()?.dismiss(animated: true, completion: nil)
      break;
    case MFMailComposeResult.saved:
      self.delegate?.didSaveFor(channel: self)
      UIApplication.topViewController()?.dismiss(animated: true, completion: nil)
      break;
    case MFMailComposeResult.cancelled:
      self.delegate?.didCancelFor(channel: self)
      UIApplication.topViewController()?.dismiss(animated: true, completion: nil)
      break;
    case MFMailComposeResult.failed:
      self.delegate?.didReceiveErrorFor(channel: self)
      break;
    }
  }
}

