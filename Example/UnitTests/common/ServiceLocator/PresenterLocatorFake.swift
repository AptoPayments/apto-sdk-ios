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

  func verifyPhonePresenter() -> VerifyPhonePresenterProtocol {
    Swift.fatalError("verifyPhonePresenter() has not been implemented")
  }

  func verifyBirthDatePresenter() -> VerifyBirthDatePresenterProtocol {
    Swift.fatalError("verifyBirthDayPresenter() has not been implemented")
  }

  lazy var externalOauthPresenterSpy = ExternalOAuthPresenterSpy()
  func externalOAuthPresenter(config: ExternalOAuthModuleConfig) -> ExternalOAuthPresenterProtocol {
    return externalOauthPresenterSpy
  }

  lazy var issueCardPresenterSpy = IssueCardPresenterSpy()
  func issueCardPresenter(router: IssueCardRouter,
                          interactor: IssueCardInteractorProtocol,
                          configuration: IssueCardActionConfiguration?) -> IssueCardPresenterProtocol {
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

  lazy var dataConfirmationPresenterSpy = DataConfirmationPresenterSpy()
  func dataConfirmationPresenter() -> DataConfirmationPresenterProtocol {
    return dataConfirmationPresenterSpy
  }

  lazy var webBrowserPresenterSpy = WebBrowserPresenterSpy()
  func webBrowserPresenter() -> WebBrowserPresenterProtocol {
    return webBrowserPresenterSpy
  }

  // MARK: - Manage card
  func manageCardPresenter(config: ManageShiftCardPresenterConfig) -> ManageShiftCardPresenterProtocol {
    Swift.fatalError("manageCardPresenter(config:) has not been implemented")
  }

  func fundingSourceSelectorPresenter() -> FundingSourceSelectorPresenterProtocol {
    Swift.fatalError("fundingSourceSelectorPresenter() has not been implemented")
  }

  func cardSettingsPresenter(cardSession: ShiftCardSession,
                             card: Card,
                             config: ShiftCardSettingsPresenterConfig,
                             emailRecipients: [String?],
                             uiConfig: ShiftUIConfig) -> ShiftCardSettingsPresenterProtocol {
    Swift.fatalError("cardSettingsPresenter(cardSession:card:config:emailRecipients:uiConfig:) " +
                       "has not been implemented")
  }

  func kycPresenter() -> KYCPresenterProtocol {
    Swift.fatalError("kycPresenter() has not been implemented")
  }

  // MARK: - Physical card activation
  func physicalCardActivationPresenter() -> PhysicalCardActivationPresenterProtocol {
    Swift.fatalError("physicalCardActivationPresenter() has not been implemented")
  }

  lazy var physicalCardActivationSucceedPresenterSpy = PhysicalCardActivationSucceedPresenterSpy()
  func physicalCardActivationSucceedPresenter() -> PhysicalCardActivationSucceedPresenterProtocol {
    return physicalCardActivationSucceedPresenterSpy
  }

  // MARK: - Transaction Details
  func transactionDetailsPresenter() -> ShiftCardTransactionDetailsPresenterProtocol {
    Swift.fatalError("transactionDetailsPresenter() has not been implemented")
  }
}
