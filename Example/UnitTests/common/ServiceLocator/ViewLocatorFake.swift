//
//  ViewLocatorFake.swift
//  ShiftSDK
//
//  Created by Takeichi Kanzaki on 08/06/2018.
//
//

@testable import ShiftSDK

class ViewLocatorFake: ViewLocatorProtocol {
  func fullScreenDisclaimerView(uiConfig: ShiftUIConfig,
                                eventHandler: FullScreenDisclaimerEventHandler) -> UIViewController {
    return FullScreenDisclaimerViewControllerTheme1(uiConfiguration: uiConfig, eventHandler: eventHandler)
  }

  func authView(uiConfig: ShiftUIConfig, eventHandler: AuthEventHandler) -> AuthViewControllerProtocol {
    return AuthViewControllerTheme1(uiConfiguration: uiConfig, eventHandler: eventHandler)
  }

  func pinVerificationView(presenter: PINVerificationPresenter) -> PINVerificationViewControllerProtocol {
    Swift.fatalError("pinVerificationView(presenter:) has not been implemented")
  }

  func verifyBirthDateView(presenter: VerifyBirthDateEventHandler) -> VerifyBirthDateViewControllerProtocol {
    Swift.fatalError("verifyBirthDateView(presenter:) has not been implemented")
  }

  func externalOAuthView(uiConfiguration: ShiftUIConfig,
                         eventHandler: ExternalOAuthPresenterProtocol) -> UIViewController {
    return ExternalOAuthViewControllerTheme1(uiConfiguration: uiConfiguration, eventHandler: eventHandler)
  }

  func issueCardView(uiConfig: ShiftUIConfig, eventHandler: IssueCardPresenterProtocol) -> UIViewController {
    return IssueCardViewControllerTheme1(uiConfiguration: uiConfig, eventHandler: eventHandler)
  }

  func serverMaintenanceErrorView(uiConfig: ShiftUIConfig?,
                                  eventHandler: ServerMaintenanceErrorEventHandler) -> UIViewController {
    return ServerMaintenanceErrorViewControllerTheme1(uiConfig: uiConfig, eventHandler: eventHandler)
  }

  func accountsSettingsView(uiConfig: ShiftUIConfig,
                            presenter: AccountSettingsPresenterProtocol) -> AccountSettingsViewProtocol {
    Swift.fatalError("accountsSettingsView(uiConfig:presenter:) has not been implemented")
  }

  func contentPresenterView(uiConfig: ShiftUIConfig,
                            presenter: ContentPresenterPresenterProtocol) -> ContentPresenterViewController {
    return ContentPresenterViewController(uiConfiguration: uiConfig, presenter: presenter)
  }

  func dataConfirmationView(uiConfig: ShiftUIConfig,
                            presenter: DataConfirmationPresenterProtocol) -> ShiftViewController {
    return DataConfirmationViewControllerTheme1(uiConfiguration: uiConfig, presenter: presenter)
  }

  func webBrowserView(eventHandler: WebBrowserEventHandlerProtocol) -> WebBrowserViewControllerProtocol {
    return WebBrowserViewControllerTheme1(uiConfiguration: ModelDataProvider.provider.uiConfig,
                                          eventHandler: eventHandler)
  }

  // MARK: - Manage card
  func manageCardView(mode: ShiftCardModuleMode,
                      presenter: ManageShiftCardEventHandler) -> ManageShiftCardViewControllerProtocol {
    Swift.fatalError("manageCardView(mode:presenter:) has not been implemented")
  }

  func fundingSourceSelectorView(presenter: FundingSourceSelectorPresenterProtocol) -> ShiftViewController {
    Swift.fatalError("fundingSourceSelectorView(presenter:) has not been implemented")
  }

  func cardSettingsView(presenter: ShiftCardSettingsPresenterProtocol) -> ShiftCardSettingsViewControllerProtocol {
    Swift.fatalError("cardSettingsView(presenter:) has not been implemented")
  }

  func kycView(presenter: KYCPresenterProtocol) -> KYCViewControllerProtocol {
    Swift.fatalError("kycView(presenter:) has not been implemented")
  }

  // MARK: - Physical card activation
  func physicalCardActivation(presenter: PhysicalCardActivationPresenterProtocol) -> ShiftViewController {
    Swift.fatalError("physicalCardActivation(presenter:) has not been implemented")
  }

  func physicalCardActivationSucceedView(uiConfig: ShiftUIConfig,
                                         presenter: PhysicalCardActivationSucceedPresenterProtocol)
    -> PhysicalCardActivationSucceedViewControllerProtocol {
      return PhysicalCardActivationSucceedViewControllerTheme1(uiConfiguration: uiConfig, presenter: presenter)
  }

  // MARK: - Transaction Details
  func transactionDetailsView(presenter: ShiftCardTransactionDetailsPresenterProtocol)
    -> ShiftCardTransactionDetailsViewControllerProtocol {
      Swift.fatalError("transactionDetailsView(presenter:) has not been implemented")
  }
}
