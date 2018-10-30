//
//  FullScreenDisclaimerModule.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 13/10/2016.
//
//

import Foundation
import Bond

protocol FullScreenDisclaimerRouterProtocol: class {
  func close()
  func showExternal(url: URL, headers: [String:String]?, useSafari: Bool?)
  func agreeTapped()
}

protocol FullScreenDisclaimerInteractorProtocol {
  func provideDisclaimer(completion: @escaping((_ disclaimer: Content) -> Void))
}

class FullScreenDisclaimerViewModel {
  var disclaimer: Observable<Content?> = Observable(nil)
}

protocol FullScreenDisclaimerEventHandler: class {
  var viewModel: FullScreenDisclaimerViewModel { get }
  func viewLoaded()
  func closeTapped()
  func agreeTapped()
  func linkTapped(_ url: URL)
}

protocol FullScreenDisclaimerPresenterProtocol: FullScreenDisclaimerEventHandler {
  var router: FullScreenDisclaimerRouterProtocol! { get set }
  var interactor: FullScreenDisclaimerInteractorProtocol! { get set }
}

protocol FullScreenDisclaimerModuleProtocol: UIModuleProtocol {
  var onDisclaimerAgreed: ((_ fullScreenDisclaimerModule: FullScreenDisclaimerModuleProtocol) -> Void)? { get set }
}

class FullScreenDisclaimerModule: UIModule, FullScreenDisclaimerModuleProtocol {
  private let disclaimer: Content
  private var presenter: FullScreenDisclaimerPresenterProtocol!

  var onDisclaimerAgreed: ((_ fullScreenDisclaimerModule: FullScreenDisclaimerModuleProtocol) -> Void)?

  init(serviceLocator: ServiceLocatorProtocol, disclaimer: Content) {
    self.disclaimer = disclaimer

    super.init(serviceLocator: serviceLocator)
  }

  override func initialize(completion: @escaping Result<UIViewController, NSError>.Callback) {
    let viewController = buildFullScreenDisclaimerViewController(uiConfig)
    addChild(viewController: viewController, completion: completion)
  }

  private func buildFullScreenDisclaimerViewController(_ uiConfig: ShiftUIConfig) -> UIViewController {
    presenter = serviceLocator.presenterLocator.fullScreenDisclaimerPresenter()
    let interactor = serviceLocator.interactorLocator.fullScreenDisclaimerInteractor(disclaimer: disclaimer)
    let viewController = serviceLocator.viewLocator.fullScreenDisclaimerView(uiConfig: uiConfig,
                                                                             eventHandler: presenter)
    presenter.interactor = interactor
    presenter.router = self

    return viewController
  }
}

extension FullScreenDisclaimerModule: FullScreenDisclaimerRouterProtocol {
  func agreeTapped() {
    onDisclaimerAgreed?(self)
    onFinish?(self)
  }
}
