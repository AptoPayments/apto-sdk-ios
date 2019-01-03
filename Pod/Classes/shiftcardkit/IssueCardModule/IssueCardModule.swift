//
//  IssueCardModule.swift
//  ShiftSDK
//
//  Created by Takeichi Kanzaki on 25/06/2018.
//
//

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
    let viewController = buildIssueCardViewController(uiConfig: uiConfig)
    completion(.success(viewController))
  }

  private func buildIssueCardViewController(uiConfig: ShiftUIConfig) -> UIViewController {
    let interactor = serviceLocator.interactorLocator.issueCardInteractor(cardSession: shiftCardSession,
                                                                          application: application)
    let configuration = (application.nextAction.configuration as? IssueCardActionConfiguration) ?? nil
    let presenter = serviceLocator.presenterLocator.issueCardPresenter(router: self,
                                                                       interactor: interactor,
                                                                       configuration: configuration)

    return serviceLocator.viewLocator.issueCardView(uiConfig: uiConfig, eventHandler: presenter)
  }

  func cardIssued(_ card: Card) {
    self.onFinish?(self)
  }

  func backTapped() {
    back()
  }

  func show(url: URL) {
    showExternal(url: url)
  }
}
