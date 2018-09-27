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

  var shiftCardSession: ShiftCardSession {
    return shiftSession.shiftCardSession
  }

  init(serviceLocator: ServiceLocatorProtocol, workflowObject: WorkflowObject, workflowAction: WorkflowAction) {
    guard let disclaimer = workflowAction.configuration as? Content else {
      fatalError("Wrong workflow action")
    }
    self.workflowObject = workflowObject
    self.workflowAction = workflowAction
    self.disclaimer = disclaimer

    super.init(serviceLocator: serviceLocator)
  }

  override func initialize(completion: @escaping (Result<UIViewController, NSError>) -> Void) {
    let module = buildFullScreenDisclaimerModule()
    addChild(module: module, completion: completion)
  }

  private func buildFullScreenDisclaimerModule() -> FullScreenDisclaimerModuleProtocol {
    let module = serviceLocator.moduleLocator.fullScreenDisclaimerModule(disclaimer: disclaimer)
    module.onClose = { [unowned self] _ in
      self.close()
    }
    module.onBack = { [unowned self] _ in
      self.back()
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
}
