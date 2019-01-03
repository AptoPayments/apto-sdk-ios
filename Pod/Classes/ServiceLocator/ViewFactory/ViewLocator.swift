//
//  ViewLocator.swift
//  ShiftSDK
//
//  Created by Takeichi Kanzaki on 07/06/2018.
//

import UIKit

final class ViewLocator: ViewLocatorProtocol {
  private unowned let serviceLocator: ServiceLocatorProtocol
  private var uiTheme: UITheme {
    guard let theme = serviceLocator.uiConfig?.uiTheme else {
      return .theme1
    }
    return theme
  }

  init(serviceLocator: ServiceLocatorProtocol) {
    self.serviceLocator = serviceLocator
  }

  func fullScreenDisclaimerView(uiConfig: ShiftUIConfig,
                                eventHandler: FullScreenDisclaimerEventHandler) -> UIViewController {
    switch uiTheme {
    case .theme1:
      return FullScreenDisclaimerViewControllerTheme1(uiConfiguration: uiConfig, eventHandler: eventHandler)
    case .theme2:
      return FullScreenDisclaimerViewControllerTheme2(uiConfiguration: uiConfig, eventHandler: eventHandler)
    }
  }

  func authView(uiConfig: ShiftUIConfig, eventHandler: AuthEventHandler) -> AuthViewControllerProtocol {
    switch uiTheme {
    case .theme1:
      return AuthViewControllerTheme1(uiConfiguration: uiConfig, eventHandler: eventHandler)
    case .theme2:
      return AuthViewControllerTheme2(uiConfiguration: uiConfig, eventHandler: eventHandler)
    }
  }

  func pinVerificationView(presenter: PINVerificationPresenter) -> PINVerificationViewControllerProtocol {
    switch uiTheme {
    case .theme1:
      return PINVerificationViewControllerTheme1(uiConfig: serviceLocator.uiConfig, presenter: presenter)
    case .theme2:
      return PINVerificationViewControllerTheme2(uiConfig: serviceLocator.uiConfig, presenter: presenter)
    }
  }

  func verifyBirthDateView(presenter: VerifyBirthDateEventHandler) -> VerifyBirthDateViewControllerProtocol {
    switch uiTheme {
    case .theme1:
      return VerifyBirthDateViewControllerTheme1(uiConfig: serviceLocator.uiConfig, presenter: presenter)
    case .theme2:
      return VerifyBirthDateViewControllerTheme2(uiConfig: serviceLocator.uiConfig, presenter: presenter)
    }
  }

  func externalOAuthView(uiConfiguration: ShiftUIConfig,
                         eventHandler: ExternalOAuthPresenterProtocol) -> UIViewController {
    switch uiTheme {
    case .theme1:
      return ExternalOAuthViewControllerTheme1(uiConfiguration: uiConfiguration, eventHandler: eventHandler)
    case .theme2:
      return ExternalOAuthViewControllerTheme2(uiConfiguration: uiConfiguration, eventHandler: eventHandler)
    }
  }

  func issueCardView(uiConfig: ShiftUIConfig, eventHandler: IssueCardPresenterProtocol) -> UIViewController {
    switch uiTheme {
    case .theme1:
      return IssueCardViewControllerTheme1(uiConfiguration: uiConfig, eventHandler: eventHandler)
    case .theme2:
      return IssueCardViewControllerTheme2(uiConfiguration: uiConfig, presenter: eventHandler)
    }
  }

  func serverMaintenanceErrorView(uiConfig: ShiftUIConfig?,
                                  eventHandler: ServerMaintenanceErrorEventHandler) -> UIViewController {
    switch uiTheme {
    case .theme1:
      return ServerMaintenanceErrorViewControllerTheme1(uiConfig: uiConfig, eventHandler: eventHandler)
    case .theme2:
      return ServerMaintenanceErrorViewControllerTheme2(uiConfig: uiConfig, eventHandler: eventHandler)
    }
  }

  func accountsSettingsView(uiConfig: ShiftUIConfig,
                            presenter: AccountSettingsPresenterProtocol) -> AccountSettingsViewProtocol {
    switch uiTheme {
    case .theme1:
      return AccountSettingsViewControllerTheme1(uiConfiguration: uiConfig, presenter: presenter)
    case .theme2:
      return AccountSettingsViewControllerTheme2(uiConfiguration: uiConfig, presenter: presenter)
    }
  }

  func contentPresenterView(uiConfig: ShiftUIConfig,
                            presenter: ContentPresenterPresenterProtocol) -> ContentPresenterViewController {
    switch uiTheme {
    case .theme1, .theme2:
      return ContentPresenterViewController(uiConfiguration: uiConfig, presenter: presenter)
    }
  }

  func dataConfirmationView(uiConfig: ShiftUIConfig,
                            presenter: DataConfirmationPresenterProtocol) -> ShiftViewController {
    switch uiTheme {
    case .theme1:
      return DataConfirmationViewControllerTheme1(uiConfiguration: uiConfig, presenter: presenter)
    case .theme2:
      return DataConfirmationViewControllerTheme2(uiConfiguration: uiConfig, presenter: presenter)
    }
  }

  func webBrowserView(eventHandler: WebBrowserEventHandlerProtocol) -> WebBrowserViewControllerProtocol {
    switch uiTheme {
    case .theme1:
      return WebBrowserViewControllerTheme1(uiConfiguration: serviceLocator.uiConfig, eventHandler: eventHandler)
    case .theme2:
      return WebBrowserViewControllerTheme2(uiConfiguration: serviceLocator.uiConfig, presenter: eventHandler)
    }
  }

  // MARK: - Manage card
  func manageCardView(mode: ShiftCardModuleMode,
                      presenter: ManageShiftCardEventHandler) -> ManageShiftCardViewControllerProtocol {
    switch uiTheme {
    case .theme1:
      return ManageShiftCardViewControllerTheme1(mode: mode,
                                                 uiConfiguration: serviceLocator.uiConfig,
                                                 eventHandler: presenter)
    case .theme2:
      return ManageShiftCardViewControllerTheme2(mode: mode,
                                                 uiConfiguration: serviceLocator.uiConfig,
                                                 presenter: presenter)
    }
  }

  func fundingSourceSelectorView(presenter: FundingSourceSelectorPresenterProtocol) -> ShiftViewController {
    switch uiTheme {
    case .theme1, .theme2:
      return FundingSourceSelectorViewControllerTheme2(uiConfiguration: serviceLocator.uiConfig, presenter: presenter)
    }
  }

  func cardSettingsView(presenter: ShiftCardSettingsPresenterProtocol) -> ShiftCardSettingsViewControllerProtocol {
    switch uiTheme {
    case .theme1:
      return ShiftCardSettingsViewControllerTheme1(uiConfiguration: serviceLocator.uiConfig, presenter: presenter)
    case .theme2:
      return ShiftCardSettingsViewControllerTheme2(uiConfiguration: serviceLocator.uiConfig, presenter: presenter)
    }
  }

  func kycView(presenter: KYCPresenterProtocol) -> KYCViewControllerProtocol {
    switch uiTheme {
    case .theme1, .theme2:
      return KYCViewController(uiConfiguration: serviceLocator.uiConfig, presenter: presenter)
    }
  }

  // MARK: - Physical card activation
  func physicalCardActivation(presenter: PhysicalCardActivationPresenterProtocol) -> ShiftViewController {
    switch uiTheme {
    case .theme1, .theme2:
      return PhysicalCardActivationViewController(uiConfiguration: serviceLocator.uiConfig, presenter: presenter)
    }
  }

  func physicalCardActivationSucceedView(uiConfig: ShiftUIConfig,
                                         presenter: PhysicalCardActivationSucceedPresenterProtocol)
      -> PhysicalCardActivationSucceedViewControllerProtocol {
    switch uiTheme {
    case .theme1:
      return PhysicalCardActivationSucceedViewControllerTheme1(uiConfiguration: uiConfig, presenter: presenter)
    case .theme2:
      return PhysicalCardActivationSucceedViewControllerTheme2(uiConfiguration: uiConfig, presenter: presenter)
    }
  }

  // MARK: - Transaction Details
  func transactionDetailsView(presenter: ShiftCardTransactionDetailsPresenterProtocol)
    -> ShiftCardTransactionDetailsViewControllerProtocol {
    switch uiTheme {
    case .theme1:
      return ShiftCardTransactionDetailsViewControllerTheme1(uiConfiguration: serviceLocator.uiConfig,
                                                             presenter: presenter)
    case .theme2:
      return ShiftCardTransactionDetailsViewControllerTheme2(uiConfiguration: serviceLocator.uiConfig,
                                                             presenter: presenter)
    }
  }
  
}
