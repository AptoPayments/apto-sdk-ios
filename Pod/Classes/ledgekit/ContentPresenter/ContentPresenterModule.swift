//
//  ContentPresenterModule.swift
//  ShiftSDK
//
//  Created by Takeichi Kanzaki on 17/09/2018.
//
//

class ContentPresenterModule: UIModule, ContentPresenterModuleProtocol {
  private let content: Content
  private let title: String
  private var presenter: ContentPresenterPresenterProtocol?

  init(serviceLocator: ServiceLocatorProtocol, content: Content, title: String) {
    self.content = content
    self.title = title
    super.init(serviceLocator: serviceLocator)
  }

  override func initialize(completion: @escaping Result<UIViewController, NSError>.Callback) {
    shiftSession.contextConfiguration { result in
      switch result {
      case .failure(let error):
        completion(.failure(error))
      case .success(let contextConfiguration):
        let config = ShiftUIConfig(projectConfiguration: contextConfiguration.projectConfiguration)
        self.uiConfig = config
        let viewController = self.buildViewController(config)
        self.addChild(viewController: viewController, completion: completion)
      }
    }
  }

  private func buildViewController(_ uiConfig: ShiftUIConfig) -> UIViewController {
    let presenter = serviceLocator.presenterLocator.contentPresenterPresenter()
    let interactor = serviceLocator.interactorLocator.contentPresenterInteractor(content: content)
    let viewController = serviceLocator.viewLocator.contentPresenterView(uiConfig: uiConfig, presenter: presenter)
    viewController.title = title
    presenter.interactor = interactor
    presenter.router = self
    self.presenter = presenter

    return viewController
  }

  func show(url: URL) {
    showExternal(url: url)
  }
}
