//
//  ShowGenericMessageModule.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 13/10/2016.
//
//

import Foundation

class ShowGenericMessageModule: UIModule {

  let showGenericMessageAction: WorkflowAction
  open var onWelcomeScreenContinue: ((_ welcomeScreenModule: ShowGenericMessageModule) -> Void)?

  init (serviceLocator: ServiceLocatorProtocol, showGenericMessageAction: WorkflowAction) {
    self.showGenericMessageAction = showGenericMessageAction
    super.init(serviceLocator: serviceLocator)
  }

  override func initialize(completion: @escaping Result<UIViewController, NSError>.Callback) {
    let viewController = buildWelcomeScreenViewController(uiConfig)
    addChild(viewController: viewController, completion: completion)
  }

  func buildWelcomeScreenViewController(_ uiConfig:ShiftUIConfig) -> UIViewController {
    let presenter = ShowGenericMessagePresenter()
    let interactor = ShowGenericMessageInteractor(showGenericMessageAction: showGenericMessageAction, dataReceiver: presenter)
    let viewController = ShowGenericMessageViewController(uiConfiguration: uiConfig, eventHandler: presenter)
    presenter.view = viewController
    presenter.interactor = interactor
    presenter.router = self
    return viewController
  }

}

extension ShowGenericMessageModule: ShowGenericMessageRouterProtocol {

  func callToActionTapped() {

    // Standard continue callback
    next()

    // Specific allback for the welcomescreenmodule
    onWelcomeScreenContinue?(self)

  }

  func secondaryCallToActionTapped() {

    // What do do here?

  }

}

