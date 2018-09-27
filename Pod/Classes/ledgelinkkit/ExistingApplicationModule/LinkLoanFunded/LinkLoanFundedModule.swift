//
//  LinkLoanFundedModule.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 18/11/2016.
//
//

import Foundation

class LinkLoanFundedModule: UIModule {

  var linkSession: LinkSession {
    return shiftSession.linkSession
  }
  let application: LoanApplication
  var displayCardModule: DisplayCardModule?
  var currentUser: ShiftUser?

  public init(serviceLocator: ServiceLocatorProtocol, application: LoanApplication) {
    self.application = application
    super.init(serviceLocator: serviceLocator)
  }

  override public func initialize(completion: @escaping Result<UIViewController, NSError>.Callback) {

    linkSession.shiftSession.contextConfiguration { result in
      switch result {
      case .failure (let error):
        completion(.failure(error))
      case .success(let contextConfiguration):
        self.uiConfig = ShiftUIConfig(projectConfiguration: contextConfiguration.projectConfiguration)
        self.linkSession.shiftSession.currentUser { result in
          switch result {
          case .failure (let error):
            completion(.failure(error))
          case .success(let user):
            self.currentUser = user
            let viewController = self.buildLinkLoanFundedViewController(self.uiConfig!,
                                                                        contextConfiguration:contextConfiguration,
                                                                        application: self.application)
            self.addChild(viewController: viewController, completion: completion)
          }
        }
      }
    }
  }

  fileprivate func display(card: Card) {
    let displayCardModule = self.buildDisplayCardModule(card: card)
    displayCardModule.onClose = { module in
      self.close()
      self.displayCardModule = nil
    }
    displayCardModule.onBack = { module in
      self.popModule() {
        self.displayCardModule = nil
      }
    }
    self.displayCardModule = displayCardModule
    push(module:displayCardModule) { result in }
  }

  fileprivate func buildLinkLoanFundedViewController(_ uiConfig: ShiftUIConfig,
                                                     contextConfiguration: ContextConfiguration,
                                                     application: LoanApplication) -> UIViewController {

    let presenter = LinkLoanFundedPresenter(uiConfiguration:uiConfig,
                                            contextConfiguration:contextConfiguration)
    let interactor = LinkLoanFundedInteractor(linkSession: self.linkSession,
                                              application: self.application,
                                              dataReceiver: presenter)
    let viewController = LinkLoanFundedViewController(uiConfiguration: uiConfig,
                                                      eventHandler: presenter)
    presenter.view = viewController
    presenter.interactor = interactor
    presenter.router = self
    return viewController
  }

  fileprivate func buildDisplayCardModule(card: Card) -> DisplayCardModule {
    if let user = currentUser {
      let nameDataPoint = user.userData.nameDataPoint
      card.cardHolder = nameDataPoint.fullName()
    }
    let displayCardModule = DisplayCardModule(serviceLocator: serviceLocator,
                                              card: card,
                                              initialCardAmount: application.offer.loanAmount!)
    return displayCardModule
  }

}

extension LinkLoanFundedModule: LinkLoanFundedRouterProtocol {

  func show(financialAccount: FinancialAccount) {

    if let card = financialAccount as? Card {
      self.display(card:card)
    }

  }

}
