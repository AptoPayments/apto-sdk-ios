//
//  PresenterLocator.swift
//  ShiftSDK
//
//  Created by Takeichi Kanzaki on 07/06/2018.
//
//

final class PresenterLocator: PresenterLocatorProtocol {
  func fullScreenDisclaimerPresenter() -> FullScreenDisclaimerPresenterProtocol {
    return FullScreenDisclaimerPresenter()
  }

  func authPresenter(authConfig: AuthModuleConfig, uiConfig: ShiftUIConfig) -> AuthPresenterProtocol {
    return AuthPresenter(config: authConfig, uiConfig: uiConfig)
  }

  func externalOAuthPresenter(config: ExternalOAuthModuleConfig) -> ExternalOAuthPresenterProtocol {
    return ExternalOAuthPresenter(config: config)
  }

  func issueCardPresenter(router: IssueCardRouter,
                          interactor: IssueCardInteractorProtocol) -> IssueCardPresenterProtocol {
    return IssueCardPresenter(router: router, interactor: interactor)
  }

  func serverMaintenanceErrorPresenter() -> ServerMaintenanceErrorPresenterProtocol {
    return ServerMaintenanceErrorPresenter()
  }

  func accountSettingsPresenter() -> AccountSettingsPresenterProtocol {
    return AccountSettingsPresenter()
  }

  func contentPresenterPresenter() -> ContentPresenterPresenterProtocol {
    return ContentPresenterPresenter()
  }

  func dataConfirmationPresenter() -> DataConfirmationPresenterProtocol {
    return DataConfirmationPresenter()
  }
}
