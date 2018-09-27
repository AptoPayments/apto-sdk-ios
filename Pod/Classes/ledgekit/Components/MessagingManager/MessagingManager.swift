//
//  MessagingManager.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 22/06/16.
//
//

import Foundation

enum MessagingChannel {
  case email
}

protocol MessagingManagerDelegate {
  func messagingManager(_ messagingManager:MessagingManager, didCancelForChannel:MessagingManagerChannel)
  func messagingManager(_ messagingManager:MessagingManager, didReceiveErrorForChannel:MessagingManagerChannel)
  func messagingManager(_ messagingManager:MessagingManager, didSuccededForChannel:MessagingManagerChannel)
  func messagingManager(_ messagingManager:MessagingManager, didSaveForChannel:MessagingManagerChannel)
}

protocol MessagingManagerChannelDelegate {
  func didCancelFor(channel:MessagingManagerChannel)
  func didReceiveErrorFor(channel:MessagingManagerChannel)
  func didSucceededFor(channel:MessagingManagerChannel)
  func didSaveFor(channel:MessagingManagerChannel)
}

protocol MessagingManagerChannel {
  var delegate: MessagingManagerChannelDelegate? { get set }
  func channelAvailable() -> Bool
  func sendMessageWith(subject:String, message:String, url:URL?, recipients:[String]?)
}

class MessagingManager {
  var delegate: MessagingManagerDelegate?
  let channels: [MessagingChannel: MessagingManagerChannel]
  
  init() {
    self.channels = [.email: EmailChannel()]
  }
  
  func send(subject:String, message:String, url:URL?, channel:MessagingChannel, recipients:[String]?) {
    guard let channel = self.channels[channel] else {
      return
    }
    channel.sendMessageWith(subject: subject, message: message, url: url, recipients: recipients)
  }
}

extension MessagingManager : MessagingManagerChannelDelegate {
  func didCancelFor(channel:MessagingManagerChannel) {
    self.delegate?.messagingManager(self, didCancelForChannel: channel)
  }

  func didReceiveErrorFor(channel:MessagingManagerChannel) {
    self.delegate?.messagingManager(self, didReceiveErrorForChannel: channel)
  }
  
  func didSucceededFor(channel:MessagingManagerChannel) {
    self.delegate?.messagingManager(self, didSuccededForChannel: channel)
  }
  
  func didSaveFor(channel:MessagingManagerChannel) {
    self.delegate?.messagingManager(self, didSaveForChannel: channel)
  }
}
