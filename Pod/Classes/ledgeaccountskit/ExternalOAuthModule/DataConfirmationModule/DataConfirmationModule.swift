//
//  DataConfirmationModule.swift
//  ShiftSDK
//
//  Created by Takeichi Kanzaki on 25/09/2018.
//

class DataConfirmationModule: UIModule, DataConfirmationModuleProtocol {
  private let userData: DataPointList
  private var presenter: DataConfirmationPresenterProtocol?

  init(serviceLocator: ServiceLocatorProtocol, userData: DataPointList) {
    self.userData = userData
    super.init(serviceLocator: serviceLocator)
  }

  override func initialize(completion: @escaping Result<UIViewController, NSError>.Callback) {
    let viewController = buildViewController(uiConfig)
    addChild(viewController: viewController, completion: completion)
  }

  private func buildViewController(_ config: ShiftUIConfig) -> UIViewController {
    let interactor = serviceLocator.interactorLocator.dataConfirmationInteractor(userData: userData)
    let presenter = serviceLocator.presenterLocator.dataConfirmationPresenter()
    presenter.interactor = interactor
    presenter.router = self
    let viewController = serviceLocator.viewLocator.dataConfirmationView(uiConfig: config, presenter: presenter)
    return viewController
  }

  func confirmData() {
    onFinish?(self)
  }
}
