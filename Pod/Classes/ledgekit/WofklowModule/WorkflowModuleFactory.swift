//
//  WorkflowModuleFactory.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 15/11/2017.
//

import UIKit

protocol WorkflowModuleFactory {
  func getModuleFor(workflowAction: WorkflowAction) -> UIModuleProtocol?
}

class WorkflowModuleFactoryImpl: WorkflowModuleFactory {

  let serviceLocator: ServiceLocatorProtocol
  let workflowObject: WorkflowObject

  init(serviceLocator: ServiceLocatorProtocol, workflowObject: WorkflowObject) {
    self.serviceLocator = serviceLocator
    self.workflowObject = workflowObject
  }

  func getModuleFor(workflowAction: WorkflowAction) -> UIModuleProtocol? {

    switch workflowAction.actionType {
    case .showGenericMessage:
      return ShowGenericMessageModule(serviceLocator: serviceLocator, showGenericMessageAction: workflowAction)
    case .selectFundingAccount:
      guard let application = workflowObject as? LoanApplication else {
        return nil
      }
      return LinkSelectFundingAccountModule(serviceLocator: serviceLocator, application: application)
    case .collectUserData:
      guard let config = workflowAction.configuration as? CollectUserDataActionConfiguration else {
        fatalError("Wrong configuration for collectUserData action.")
      }
      let finalStepTitle = "birthday-collector.get-card.title".podLocalized()
      let finalStepSubtitle = "birthday-collector.get-card.subtitle".podLocalized()
      let callToAction = CallToAction(title: "birthday-collector.button.get-card".podLocalized(),
                                      callToActionType: .continueFlow)
      return serviceLocator.moduleLocator.userDataCollectorModule(userRequiredData: config.requiredDataPointsList,
                                                                  mode: .continueFlow,
                                                                  backButtonMode: .back,
                                                                  finalStepTitle: finalStepTitle,
                                                                  finalStepSubtitle: finalStepSubtitle,
                                                                  finalStepCallToAction: callToAction,
                                                                  disclaimers: [])
    case .issueCard:
      guard let application = workflowObject as? CardApplication else {
        return nil
      }
      return serviceLocator.moduleLocator.issueCardModule(application: application)
    case .selectBalanceStore:
      guard let application = workflowObject as? CardApplication else {
        return nil
      }
      return serviceLocator.moduleLocator.selectBalanceStoreModule(application: application)
    case .showDisclaimer:
      guard let _ = workflowAction.configuration as? Content else {
        return nil
      }
      return serviceLocator.moduleLocator.showDisclaimerActionModule(workflowObject: workflowObject,
                                                                     workflowAction: workflowAction)
    case .verifyIDDocument:
      return serviceLocator.moduleLocator.verifyDocumentModule(workflowObject: workflowObject)
    case .notSupportedActionType:
      return notSupportedActionModule()
    }
  }

  fileprivate func notSupportedActionModule() -> UIModule {
    return UIModule(serviceLocator: serviceLocator)
  }

}
