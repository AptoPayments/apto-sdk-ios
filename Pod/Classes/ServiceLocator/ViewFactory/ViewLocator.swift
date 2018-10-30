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
    case .theme1, .theme2:
      return FullScreenDisclaimerViewController(uiConfiguration: uiConfig, eventHandler: eventHandler)
    }
  }

  func authView(uiConfig: ShiftUIConfig, eventHandler: AuthEventHandler) -> AuthViewControllerProtocol {
    switch uiTheme {
    case .theme1, .theme2:
      return AuthViewController(uiConfiguration: uiConfig, eventHandler: eventHandler)
    }
  }

  func externalOAuthView(uiConfiguration: ShiftUIConfig,
                         eventHandler: ExternalOAuthPresenterProtocol) -> UIViewController {
    switch uiTheme {
    case .theme1, .theme2:
      return ExternalOAuthViewController(uiConfiguration: uiConfiguration, eventHandler: eventHandler)
    }
  }

  func issueCardView(uiConfig: ShiftUIConfig, eventHandler: IssueCardPresenterProtocol) -> UIViewController {
    return IssueCardViewController(uiConfiguration: uiConfig, eventHandler: eventHandler)
  }

  func serverMaintenanceErrorView(uiConfig: ShiftUIConfig?,
                                  eventHandler: ServerMaintenanceErrorEventHandler) -> UIViewController {
    switch uiTheme {
    case .theme1, .theme2:
      return ServerMaintenanceErrorViewController(uiConfig: uiConfig, eventHandler: eventHandler)
    }
  }

  func accountsSettingsView(uiConfig: ShiftUIConfig,
                            presenter: AccountSettingsPresenterProtocol) -> AccountSettingsViewProtocol {
    switch uiTheme {
    case .theme1, .theme2:
      return AccountSettingsViewController(uiConfiguration: uiConfig, presenter: presenter)
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
                            presenter: DataConfirmationPresenterProtocol) -> DataConfirmationViewController {
    switch uiTheme {
    case .theme1, .theme2:
      return DataConfirmationViewController(uiConfiguration: uiConfig, presenter: presenter)
    }
  }

  func physicalCardActivationView(uiConfig: ShiftUIConfig,
                                  presenter: PhysicalCardActivationSucceedPresenterProtocol)
      -> PhysicalCardActivationSucceedViewController {
    switch uiTheme {
    case .theme1, .theme2:
      return PhysicalCardActivationSucceedViewController(uiConfiguration: uiConfig, presenter: presenter)
    }
  }
}
