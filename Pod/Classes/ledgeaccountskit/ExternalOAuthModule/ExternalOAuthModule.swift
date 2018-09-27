//
//  ExternalOAuthModule.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 03/06/2018.
//
//

import Foundation
import Bond

protocol ExternalOAuthModuleProtocol: UIModuleProtocol, ExternalOAuthRouterProtocol {
  var onOAuthSucceeded:
    ((_ externalOAuthModule: ExternalOAuthModuleProtocol, _ custodian: Custodian) -> Void)? { get set }
}

protocol ExternalOAuthPresenterProtocol: class {
  // swiftlint:disable implicitly_unwrapped_optional
  var router: ExternalOAuthRouterProtocol! { get set }
  var interactor: ExternalOAuthInteractorProtocol! { get set }
  // swiftlint:enable implicitly_unwrapped_optional
  var viewModel: ExternalOAuthViewModel { get }
  func show(error: NSError)
  func show(url: URL)
  func custodianSelected(_ custodian: Custodian)
  func backTapped()
  func custodianTapped(custodianType: CustodianType)
}

protocol ExternalOAuthRouterProtocol: class {
  func backInExternalOAuth(_ animated: Bool?)
  func oauthSucceeded(_ custodian: Custodian)
  func show(url: URL, completion: @escaping () -> ())
  func showLoadingSpinner()
  func hideLoadingSpinner()
}

protocol ExternalOAuthInteractorProtocol {
  var presenter: ExternalOAuthPresenterProtocol! { get set } // swiftlint:disable:this implicitly_unwrapped_optional
  func custodianSelected(custodianType: CustodianType)
  func custodianAuthenticationSucceed()
}

protocol ExternalOAuthViewProtocol: ViewControllerProtocol {}

class ExternalOAuthViewModel {
  var title: Observable<String?> = Observable(nil)
  var imageName: Observable<String?> = Observable(nil)
  var provider: Observable<String?> = Observable(nil)
  var accessDescription: Observable<String?> = Observable(nil)
  var callToActionTitle: Observable<String?> = Observable(nil)
  var description: Observable<String?> = Observable(nil)
  var error: Observable<Error?> = Observable(nil)
}

class ExternalOAuthModule: UIModule, ExternalOAuthModuleProtocol {
  private let config: ExternalOAuthModuleConfig
  private var presenter: ExternalOAuthPresenterProtocol! // swiftlint:disable:this implicitly_unwrapped_optional

  open var onOAuthSucceeded: ((_ externalOAuthModule: ExternalOAuthModuleProtocol, _ custodian: Custodian) -> Void)?

  init(serviceLocator: ServiceLocatorProtocol, config: ExternalOAuthModuleConfig, uiConfig: ShiftUIConfig) {
    self.config = config
    super.init(serviceLocator: serviceLocator)
    self.uiConfig = uiConfig
  }

  override func initialize(completion: @escaping Result<UIViewController, NSError>.Callback) {
    let viewController = buildExternalOAuthViewController(uiConfig!) // swiftlint:disable:this force_unwrapping
    self.addChild(viewController: viewController, completion: completion)
  }

  fileprivate func buildExternalOAuthViewController(_ uiConfig: ShiftUIConfig) -> UIViewController {
    presenter = serviceLocator.presenterLocator.externalOAuthPresenter(config: config)
    var interactor = serviceLocator.interactorLocator.externalOAuthInteractor(session: shiftSession)
    let viewController = serviceLocator.viewLocator.externalOAuthView(uiConfiguration: uiConfig,
                                                                      eventHandler: presenter)
    presenter.interactor = interactor
    presenter.router = self
    interactor.presenter = presenter
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
