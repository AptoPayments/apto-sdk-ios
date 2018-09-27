//
//  IssueCardModule.swift
//  Pods
//
//  Created by Takeichi Kanzaki on 25/06/2018.
//
//

import Bond


enum IssueCardViewState: Int, Equatable {
  case loading
  case error
}

class IssueCardViewModel {
  let state: Observable<IssueCardViewState>

  init(state: IssueCardViewState) {
    self.state = Observable(state)
  }
}

protocol IssueCardInteractorProtocol {
  func issueCard(completion: @escaping Result<Card, NSError>.Callback)
}

protocol IssueCardPresenterProtocol {
  var viewModel: IssueCardViewModel { get }
  func viewLoaded()
  func retryTapped()
}

protocol IssueCardRouter: class {
  func cardIssued(_ card: Card)
  func show(error: Error)
}

protocol IssueCardModuleProtocol: UIModuleProtocol, IssueCardRouter {
}

class IssueCardModule: UIModule, IssueCardModuleProtocol {
  private let application: CardApplication

  var shiftCardSession: ShiftCardSession {
    return shiftSession.shiftCardSession
  }

  init(serviceLocator: ServiceLocatorProtocol, application: CardApplication) {
    self.application = application

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
       let viewController = self.buildIssueCardViewController(uiConfig: config)
       completion(.success(viewController))
     }
   }
  }

  private func buildIssueCardViewController(uiConfig: ShiftUIConfig) -> UIViewController {
    let interactor = serviceLocator.interactorLocator.issueCardInteractor(cardSession: shiftCardSession,
                                                                          application: application)
    let presenter = serviceLocator.presenterLocator.issueCardPresenter(router: self, interactor: interactor)

    return serviceLocator.viewLocator.issueCardView(uiConfig: uiConfig, eventHandler: presenter)
  }

  func cardIssued(_ card: Card) {
    self.onFinish?(self)
  }
}
