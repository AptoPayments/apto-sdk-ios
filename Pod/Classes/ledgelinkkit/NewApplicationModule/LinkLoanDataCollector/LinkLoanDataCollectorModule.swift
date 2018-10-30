//
//  LinkLoanDataCollectorModule.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 14/10/2016.
//
//

import Foundation

public enum LinkLoanDataCollectorModuleMode {
  case finalStep
  case firstStep
}

class LinkLoanDataCollectorModule: UIModule {

  var linkSession: LinkSession {
    return shiftSession.linkSession
  }
  let loanData: AppLoanData
  let config: LinkLoanDataCollectorConfig
  var contextConfiguration: ContextConfiguration!
  open var onLoanDataCollected: ((_ loanDataCollectorModule: LinkLoanDataCollectorModule, _ loanData: AppLoanData) -> Void)?

  fileprivate var userDataCollectorModule: UserDataCollectorModule?

  init(serviceLocator: ServiceLocatorProtocol,
       loanData: AppLoanData,
       config: LinkLoanDataCollectorConfig) {
    self.loanData = loanData
    self.config = config
    super.init(serviceLocator: serviceLocator)
  }

  override func initialize(completion: @escaping Result<UIViewController, NSError>.Callback) {
    shiftSession.contextConfiguration { result in
      switch result {
      case .failure(let error):
        completion(.failure(error))
      case .success(let contextConfiguration):
        self.contextConfiguration = contextConfiguration

        // Use the default loan value if no loan amount is defined
        if self.loanData.amount?.amount.value == nil {
          self.loanData.amount?.amount.next(self.config.loanAmountRange.def)
        }
        // Make sure the loan amount is in the limits
        if (self.loanData.amount?.amount.value)! < self.config.loanAmountRange.min {
          self.loanData.amount?.amount.next(self.config.loanAmountRange.min)
        }
        if (self.loanData.amount?.amount.value)! > self.config.loanAmountRange.max {
          self.loanData.amount?.amount.next(self.config.loanAmountRange.max)
        }
        let viewController = self.buildLoanDataCollectorViewController()
        self.addChild(viewController: viewController, completion: completion)
      }
    }
  }

  fileprivate func buildLoanDataCollectorViewController() -> UIViewController {
    let presenter = LinkLoanDataCollectorPresenter(uiConfig: self.uiConfig)
    let interactor = LinkLoanDataCollectorInteractor(loanData: loanData, config: self.config, dataReceiver: presenter)
    let viewController = LinkLoanDataCollectorViewController(uiConfiguration: self.uiConfig, eventHandler: presenter)
    presenter.view = viewController
    presenter.interactor = interactor
    presenter.router = self
    return viewController
  }

}

extension LinkLoanDataCollectorModule: LinkLoanDataCollectorRouterProtocol {

  func getLoanOffersTappedInLoanDataCollector() {
    onLoanDataCollected?(self, loanData)
  }

  func applicationListTappedInLoanDataCollector() {
    // TODO: Instantiate and push the application list module
  }

  func nextTappedInLoanDataCollector() {
    onLoanDataCollected?(self, loanData)
  }

  func profileTappedInLoanDataCollector() {
    let disclaimers = config.loanProducts.compactMap { $0.prequalificationDisclaimer }
    let moduleLocator = serviceLocator.moduleLocator
    let userRequiredData = config.requiredDataPoints
    let finalStepTitle = "birthday-collector.update-user.title".podLocalized()
    let finalStepSubtitle = "birthday-collector.update-user.subtitle".podLocalized()
    let callToAction = CallToAction(title: "birthday-collector.button.update-profile".podLocalized(),
                                    callToActionType: .continueFlow)
    let userDataCollectorModule = moduleLocator.userDataCollectorModule(userRequiredData: userRequiredData,
                                                                        mode: .updateUser,
                                                                        backButtonMode: .close,
                                                                        finalStepTitle: finalStepTitle,
                                                                        finalStepSubtitle: finalStepSubtitle,
                                                                        finalStepCallToAction: callToAction,
                                                                        disclaimers: disclaimers)

    userDataCollectorModule.onClose = { [weak self] _ in
      self?.dismissModule {
        self?.userDataCollectorModule = nil
      }
    }
    userDataCollectorModule.onUserDataCollected = { [weak self] _, _ in
      self?.dismissModule {
        self?.userDataCollectorModule = nil
      }
    }

    self.userDataCollectorModule = userDataCollectorModule
    present(module: userDataCollectorModule) { _ in }
  }

}
