//
//  ShowGenericMessageInteractor.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 13/10/2016.
//
//

import Foundation

protocol ShowGenericMessageDataReceiver {
  func set(title: String, content: Content?, callToAction: CallToAction?)
}

class ShowGenericMessageInteractor: ShowGenericMessageInteractorProtocol {
  
  let showGenericMessageAction:WorkflowAction
  let dataReceiver: ShowGenericMessageDataReceiver
  
  init(showGenericMessageAction:WorkflowAction, dataReceiver: ShowGenericMessageDataReceiver) {
    self.showGenericMessageAction = showGenericMessageAction
    self.dataReceiver = dataReceiver
  }
  
  func provideContent() {
    guard let showGenericActionConfig = showGenericMessageAction.configuration as? ShowGenericMessageActionConfiguration else {
      // TODO: This shouldn't happen
      return
    }
    dataReceiver.set(title: showGenericActionConfig.title, content: showGenericActionConfig.content, callToAction: showGenericActionConfig.callToAction)
  }
  
}
