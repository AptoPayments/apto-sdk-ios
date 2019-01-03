//
//  PhysicalCardActivationSucceedModule.swift
//  ShiftSDK
//
// Created by Takeichi Kanzaki on 22/10/2018.
//

import Foundation

class PhysicalCardActivationSucceedModule: UIModule, PhysicalCardActivationSucceedModuleProtocol {
  private let card: Card
  private let caller: PhoneCallerProtocol
  private var presenter: PhysicalCardActivationSucceedPresenterProtocol?

  init(serviceLocator: ServiceLocatorProtocol, card: Card, phoneCaller: PhoneCallerProtocol) {
    self.card = card
    self.caller = phoneCaller
    super.init(serviceLocator: serviceLocator)
  }

  override func initialize(completion: @escaping Result<UIViewController, NSError>.Callback) {
    let viewController = buildViewController(uiConfig: uiConfig)
    completion(.success(viewController))
  }

  func call(url: URL, completion: @escaping () -> Void) {
    caller.call(phoneNumberURL: url, from: self, completion: completion)
  }

  func getPinFinished() {
    onFinish?(self)
  }

  private func buildViewController(uiConfig: ShiftUIConfig) -> UIViewController {
    let presenter = serviceLocator.presenterLocator.physicalCardActivationSucceedPresenter()
    let viewController = serviceLocator.viewLocator.physicalCardActivationSucceedView(uiConfig: uiConfig,
                                                                                      presenter: presenter)
    let interactor = serviceLocator.interactorLocator.physicalCardActivationSucceedInteractor(card: card)
    presenter.interactor = interactor
    presenter.router = self
    self.presenter = presenter
    return viewController
  }
}
