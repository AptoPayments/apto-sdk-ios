//
//  PresenterLocatorProtocol.swift
//  ShiftSDK
//
//  Created by Takeichi Kanzaki on 07/06/2018.
//
//

protocol PresenterLocatorProtocol {
  func fullScreenDisclaimerPresenter() -> FullScreenDisclaimerPresenterProtocol

  // MARK: - Auth module
  func authPresenter(authConfig: AuthModuleConfig, uiConfig: ShiftUIConfig) -> AuthPresenterProtocol
  func verifyPhonePresenter() -> VerifyPhonePresenterProtocol
  func verifyBirthDatePresenter() -> VerifyBirthDatePresenterProtocol
  func externalOAuthPresenter(config: ExternalOAuthModuleConfig) -> ExternalOAuthPresenterProtocol

  func issueCardPresenter(router: IssueCardRouter,
                          interactor: IssueCardInteractorProtocol,
                          configuration: IssueCardActionConfiguration?) -> IssueCardPresenterProtocol
  func serverMaintenanceErrorPresenter() -> ServerMaintenanceErrorPresenterProtocol
  func accountSettingsPresenter() -> AccountSettingsPresenterProtocol
  func contentPresenterPresenter() -> ContentPresenterPresenterProtocol
  func dataConfirmationPresenter() -> DataConfirmationPresenterProtocol
  func webBrowserPresenter() -> WebBrowserPresenterProtocol

  // MARK: - Manage card
  func manageCardPresenter(config: ManageShiftCardPresenterConfig) -> ManageShiftCardPresenterProtocol
  func fundingSourceSelectorPresenter() -> FundingSourceSelectorPresenterProtocol
  func cardSettingsPresenter(cardSession: ShiftCardSession,
                             card: Card,
                             config: ShiftCardSettingsPresenterConfig,
                             emailRecipients: [String?],
                             uiConfig: ShiftUIConfig) -> ShiftCardSettingsPresenterProtocol
  func kycPresenter() -> KYCPresenterProtocol

  // MARK: - Physical card activation
  func physicalCardActivationPresenter() -> PhysicalCardActivationPresenterProtocol
  func physicalCardActivationSucceedPresenter() -> PhysicalCardActivationSucceedPresenterProtocol

  // MARK: - Transaction Details
  func transactionDetailsPresenter() -> ShiftCardTransactionDetailsPresenterProtocol
}
