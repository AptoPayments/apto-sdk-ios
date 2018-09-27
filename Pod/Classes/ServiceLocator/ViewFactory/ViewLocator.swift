//
//  ViewLocator.swift
//  ShiftSDK
//
//  Created by Takeichi Kanzaki on 07/06/2018.
//

import UIKit

final class ViewLocator: ViewLocatorProtocol {
  func fullScreenDisclaimerView(uiConfig: ShiftUIConfig,
                                eventHandler: FullScreenDisclaimerEventHandler) -> UIViewController {
    return FullScreenDisclaimerViewController(uiConfiguration: uiConfig, eventHandler: eventHandler)
  }

  func authView(uiConfig: ShiftUIConfig, eventHandler: AuthEventHandler) -> AuthViewControllerProtocol {
    return AuthViewController(uiConfiguration: uiConfig, eventHandler: eventHandler)
  }

  func externalOAuthView(uiConfiguration: ShiftUIConfig,
                         eventHandler: ExternalOAuthPresenterProtocol) -> UIViewController {
    return ExternalOAuthViewController(uiConfiguration: uiConfiguration, eventHandler: eventHandler)
  }

  func issueCardView(uiConfig: ShiftUIConfig, eventHandler: IssueCardPresenterProtocol) -> UIViewController {
    return IssueCardViewController(uiConfiguration: uiConfig, eventHandler: eventHandler)
  }

  func serverMaintenanceErrorView(uiConfig: ShiftUIConfig?,
                                  eventHandler: ServerMaintenanceErrorEventHandler) -> UIViewController {
    return ServerMaintenanceErrorViewController(uiConfig: uiConfig, eventHandler: eventHandler)
  }

  func accountsSettingsView(uiConfig: ShiftUIConfig,
                            presenter: AccountSettingsPresenterProtocol) -> AccountSettingsViewProtocol {
    return AccountSettingsViewController(uiConfiguration: uiConfig, presenter: presenter)
  }

  func contentPresenterView(uiConfig: ShiftUIConfig,
                            presenter: ContentPresenterPresenterProtocol) -> ContentPresenterViewController {
    return ContentPresenterViewController(uiConfiguration: uiConfig, presenter: presenter)
  }
}
