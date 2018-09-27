//
//  PresenterLocatorFake.swift
//  ShiftSDK
//
//  Created by Takeichi Kanzaki on 08/06/2018.
//
//

@testable import ShiftSDK

class PresenterLocatorFake: PresenterLocatorProtocol {
  lazy var fullScreenDisclaimerPresenterSpy = FullScreenDisclaimerPresenterSpy()
  func fullScreenDisclaimerPresenter() -> FullScreenDisclaimerPresenterProtocol {
    return fullScreenDisclaimerPresenterSpy
  }

  lazy var authPresenterSpy = AuthPresenterSpy()
  func authPresenter(authConfig: AuthModuleConfig, uiConfig: ShiftUIConfig) -> AuthPresenterProtocol {
    return authPresenterSpy
  }

  lazy var externalOauthPresenterSpy = ExternalOAuthPresenterSpy()
  func externalOAuthPresenter(config: ExternalOAuthModuleConfig) -> ExternalOAuthPresenterProtocol {
    return externalOauthPresenterSpy
  }

  lazy var issueCardPresenterSpy = IssueCardPresenterSpy()
  func issueCardPresenter(router: IssueCardRouter,
                          interactor: IssueCardInteractorProtocol) -> IssueCardPresenterProtocol {
    return issueCardPresenterSpy
  }

  lazy var serverMaintenanceErrorPresenterSpy = ServerMaintenanceErrorPresenterSpy()
  func serverMaintenanceErrorPresenter() -> ServerMaintenanceErrorPresenterProtocol {
    return serverMaintenanceErrorPresenterSpy
  }

  func accountSettingsPresenter() -> AccountSettingsPresenterProtocol {
    Swift.fatalError("accountSettingsPresenter() has not been implemented")
  }

  lazy var contentPresenterPresenterSpy = ContentPresenterPresenterSpy()
  func contentPresenterPresenter() -> ContentPresenterPresenterProtocol {
    return contentPresenterPresenterSpy
  }
}
