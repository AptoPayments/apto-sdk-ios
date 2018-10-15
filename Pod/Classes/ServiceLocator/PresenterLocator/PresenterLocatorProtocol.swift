//
//  PresenterLocatorProtocol.swift
//  ShiftSDK
//
//  Created by Takeichi Kanzaki on 07/06/2018.
//
//

protocol PresenterLocatorProtocol {
  func fullScreenDisclaimerPresenter() -> FullScreenDisclaimerPresenterProtocol
  func authPresenter(authConfig: AuthModuleConfig, uiConfig: ShiftUIConfig) -> AuthPresenterProtocol
  func externalOAuthPresenter(config: ExternalOAuthModuleConfig) -> ExternalOAuthPresenterProtocol
  func issueCardPresenter(router: IssueCardRouter,
                          interactor: IssueCardInteractorProtocol) -> IssueCardPresenterProtocol
  func serverMaintenanceErrorPresenter() -> ServerMaintenanceErrorPresenterProtocol
  func accountSettingsPresenter() -> AccountSettingsPresenterProtocol
  func contentPresenterPresenter() -> ContentPresenterPresenterProtocol
  func dataConfirmationPresenter() -> DataConfirmationPresenterProtocol
}
