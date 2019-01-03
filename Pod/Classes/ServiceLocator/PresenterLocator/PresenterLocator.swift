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

  func verifyPhonePresenter() -> VerifyPhonePresenterProtocol {
    return VerifyPhonePresenter()
  }

  func verifyBirthDatePresenter() -> VerifyBirthDatePresenterProtocol {
    return VerifyBirthDatePresenter()
  }

  func externalOAuthPresenter(config: ExternalOAuthModuleConfig) -> ExternalOAuthPresenterProtocol {
    return ExternalOAuthPresenter(config: config)
  }

  func issueCardPresenter(router: IssueCardRouter,
                          interactor: IssueCardInteractorProtocol,
                          configuration: IssueCardActionConfiguration?) -> IssueCardPresenterProtocol {
    return IssueCardPresenter(router: router, interactor: interactor, configuration: configuration)
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

  func webBrowserPresenter() -> WebBrowserPresenterProtocol {
    return WebBrowserPresenter()
  }

  // MARK: - Manage card
  func manageCardPresenter(config: ManageShiftCardPresenterConfig) -> ManageShiftCardPresenterProtocol {
    return ManageShiftCardPresenter(config: config)
  }

  func fundingSourceSelectorPresenter() -> FundingSourceSelectorPresenterProtocol {
    return FundingSourceSelectorPresenter()
  }

  func cardSettingsPresenter(cardSession: ShiftCardSession,
                             card: Card,
                             config: ShiftCardSettingsPresenterConfig,
                             emailRecipients: [String?],
                             uiConfig: ShiftUIConfig) -> ShiftCardSettingsPresenterProtocol {
    return ShiftCardSettingsPresenter(shiftCardSession: cardSession,
                                      card: card,
                                      config: config,
                                      emailRecipients: emailRecipients,
                                      uiConfig: uiConfig)
  }

  func kycPresenter() -> KYCPresenterProtocol {
    return KYCPresenter()
  }

  // MARK: - Physical card activation
  func physicalCardActivationPresenter() -> PhysicalCardActivationPresenterProtocol {
    return PhysicalCardActivationPresenter()
  }

  func physicalCardActivationSucceedPresenter() -> PhysicalCardActivationSucceedPresenterProtocol {
    return PhysicalCardActivationSucceedPresenter()
  }

  // MARK: - Transaction Details
  func transactionDetailsPresenter() -> ShiftCardTransactionDetailsPresenterProtocol {
    return ShiftCardTransactionDetailsPresenter()
  }
}
