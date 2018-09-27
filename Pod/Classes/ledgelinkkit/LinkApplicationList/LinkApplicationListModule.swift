//
//  LinkApplicationListModule.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 20/10/2016.
//
//

import Foundation

class LinkApplicationListModule: UIModule {

  let initialApplications: [LoanApplicationSummary]
  open var onApplicationSelected: ((_ linkApplicationListModule: LinkApplicationListModule, _ applicationSummary: LoanApplicationSummary) -> Void)?
  open var onNewApplicationSelected: ((_ linkApplicationListModule: LinkApplicationListModule) -> Void)?

  init(serviceLocator: ServiceLocatorProtocol, initialApplications: [LoanApplicationSummary]) {
    self.initialApplications = initialApplications
    super.init(serviceLocator: serviceLocator)
  }

  override public func initialize(completion: @escaping Result<UIViewController, NSError>.Callback) {
    shiftSession.contextConfiguration { result in
      switch result {
      case .failure (let error):
        completion(.failure(error))
      case .success(let contextConfiguration):
        self.uiConfig = ShiftUIConfig(projectConfiguration: contextConfiguration.projectConfiguration)
        let viewController = self.buildApplicationListViewController(self.uiConfig!, initialApplications: self.initialApplications)
        self.addChild(viewController: viewController, completion: completion)
      }
    }
  }

  func buildApplicationListViewController(_ uiConfig:ShiftUIConfig, initialApplications: [LoanApplicationSummary]) -> UIViewController {
    let presenter = LinkApplicationListPresenter()
    let interactor = LinkApplicationListInteractor(linkSession: shiftSession.linkSession, initialApplications: initialApplications)
    let viewController = LinkApplicationListViewController(uiConfiguration: uiConfig, eventHandler: presenter)
    presenter.view = viewController
    presenter.interactor = interactor
    presenter.router = self
    return viewController
  }

}

extension LinkApplicationListModule: LinkApplicationListRouterProtocol {

  func applicationSelected(applicationSummary: LoanApplicationSummary) {
    onApplicationSelected?(self, applicationSummary)
  }

  func newApplicationSelected() {
    onNewApplicationSelected?(self)
  }

  func back(_ animated: Bool?) {
    self.back()
  }

  func close(_ animated: Bool?) {
    self.close()
  }

}

