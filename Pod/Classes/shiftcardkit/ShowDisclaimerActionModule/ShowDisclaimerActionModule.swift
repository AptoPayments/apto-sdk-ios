//
//  ShowDisclaimerActionModule.swift
//  ShiftSDK
//
//  Created by Takeichi Kanzaki on 28/06/2018.
//
//

import UIKit

protocol ShowDisclaimerActionModuleProtocol: UIModuleProtocol {
}

class ShowDisclaimerActionModule: UIModule, ShowDisclaimerActionModuleProtocol {
  private let workflowObject: WorkflowObject
  private let workflowAction: WorkflowAction
  private let disclaimer: Content
  private let actionConfirmer: ActionConfirmer.Type

  var shiftCardSession: ShiftCardSession {
    return shiftSession.shiftCardSession
  }

  init(serviceLocator: ServiceLocatorProtocol,
       workflowObject: WorkflowObject,
       workflowAction: WorkflowAction,
       actionConfirmer: ActionConfirmer.Type) {
    guard let disclaimer = workflowAction.configuration as? Content else {
      fatalError("Wrong workflow action")
    }
    self.workflowObject = workflowObject
    self.workflowAction = workflowAction
    self.disclaimer = disclaimer
    self.actionConfirmer = actionConfirmer
    super.init(serviceLocator: serviceLocator)
  }

  override func initialize(completion: @escaping (Result<UIViewController, NSError>) -> Void) {
    let module = buildFullScreenDisclaimerModule()
    addChild(module: module, completion: completion)
  }

  private func buildFullScreenDisclaimerModule() -> FullScreenDisclaimerModuleProtocol {
    let module = serviceLocator.moduleLocator.fullScreenDisclaimerModule(disclaimer: disclaimer)
    module.onClose = { [unowned self] _ in
      self.confirmClose {[unowned self] in
        self.close()
      }
    }
    module.onBack = { [unowned self] _ in
      self.confirmClose { [unowned self] in
        self.back()
      }
    }
    module.onDisclaimerAgreed = disclaimerAgreed

    return module
  }

  private func disclaimerAgreed(module: UIModuleProtocol) {
    showLoadingSpinner()
    shiftCardSession.acceptDisclaimer(workflowObject, workflowAction: workflowAction) { result in
      self.hideLoadingSpinner()
      switch result {
      case .failure(let error):
        self.show(error: error)
      case .success:
        self.onFinish?(self)
      }
    }
  }

  private func confirmClose(onConfirm: @escaping () -> ()) {
    if let cardApplication = self.workflowObject as? CardApplication {
      let cancelTitle = "disclaimer.disclaimer.cancel_action.cancel_button".podLocalized()
      actionConfirmer.confirm(title: "disclaimer.disclaimer.cancel_action.title".podLocalized(),
                              message: "disclaimer.disclaimer.cancel_action.message".podLocalized(),
                              okTitle: "disclaimer.disclaimer.cancel_action.ok_button".podLocalized(),
                              cancelTitle: cancelTitle) { [unowned self] action in
        guard let title = action.title, title != cancelTitle else {
          return
        }
        self.showLoadingSpinner()
        self.shiftCardSession.cancelCardApplication(cardApplication.id) { [unowned self] _ in
          self.hideLoadingSpinner()
          onConfirm()
          NotificationCenter.default.post(Notification(name: .UserTokenSessionClosedNotification,
                                                       object: nil,
                                                       userInfo: nil))
        }
      }
    }
    else {
      onConfirm()
    }
  }
}
