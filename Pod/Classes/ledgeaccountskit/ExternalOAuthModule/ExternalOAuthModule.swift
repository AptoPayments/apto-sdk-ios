//
//  ExternalOAuthModule.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 03/06/2018.
//
//

import Foundation

class ExternalOAuthModule: UIModule, ExternalOAuthModuleProtocol {
  private let config: ExternalOAuthModuleConfig
  private var presenter: ExternalOAuthPresenterProtocol?
  private var dataConfirmationModule: DataConfirmationModuleProtocol?

  open var onOAuthSucceeded: ((_ externalOAuthModule: ExternalOAuthModuleProtocol, _ custodian: Custodian) -> Void)?

  init(serviceLocator: ServiceLocatorProtocol, config: ExternalOAuthModuleConfig, uiConfig: ShiftUIConfig) {
    self.config = config
    super.init(serviceLocator: serviceLocator)
  }

  override func initialize(completion: @escaping Result<UIViewController, NSError>.Callback) {
    let viewController = buildExternalOAuthViewController(uiConfig)
    self.addChild(viewController: viewController, completion: completion)
  }

  fileprivate func buildExternalOAuthViewController(_ uiConfig: ShiftUIConfig) -> UIViewController {
    let presenter = serviceLocator.presenterLocator.externalOAuthPresenter(config: config)
    var interactor = serviceLocator.interactorLocator.externalOAuthInteractor(session: shiftSession)
    let viewController = serviceLocator.viewLocator.externalOAuthView(uiConfiguration: uiConfig,
                                                                      eventHandler: presenter)
    presenter.interactor = interactor
    presenter.router = self
    interactor.presenter = presenter
    self.presenter = presenter
    return viewController
  }
}

extension ExternalOAuthModule: ExternalOAuthRouterProtocol {
  func backInExternalOAuth(_ animated: Bool?) {
    self.back()
  }

  func oauthSucceeded(_ custodian: Custodian) {
    onOAuthSucceeded?(self, custodian)
  }

  func show(url: URL, completion: @escaping () -> ()) {
    showExternal(url: url, completion: completion)
  }

  func showLoadingSpinner() {
    showLoadingSpinner(position: .center)
  }
}
