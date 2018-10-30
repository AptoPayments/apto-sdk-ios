//
//  ViewLocatorProtocol.swift
//  ShiftSDK
//
//  Created by Takeichi Kanzaki on 07/06/2018.
//

import UIKit

// The methods of this protocol expected will return a compound data type consisting in a UIViewController and a given
// protocol. The reason behind that is that the swift compiler do not support this construction:
//
// protocol ViewControllerProtocol where Self: UIViewController {}
//
// That statement will compile but the app will crash in runtime whenever a UIViewController is expected.
protocol ViewLocatorProtocol {
  func fullScreenDisclaimerView(uiConfig: ShiftUIConfig,
                                eventHandler: FullScreenDisclaimerEventHandler) -> UIViewController
  func authView(uiConfig: ShiftUIConfig, eventHandler: AuthEventHandler) -> AuthViewControllerProtocol
  func externalOAuthView(uiConfiguration: ShiftUIConfig,
                         eventHandler: ExternalOAuthPresenterProtocol) -> UIViewController
  func issueCardView(uiConfig: ShiftUIConfig, eventHandler: IssueCardPresenterProtocol) -> UIViewController
  func serverMaintenanceErrorView(uiConfig: ShiftUIConfig?,
                                  eventHandler: ServerMaintenanceErrorEventHandler) -> UIViewController
  func accountsSettingsView(uiConfig: ShiftUIConfig,
                            presenter: AccountSettingsPresenterProtocol) -> AccountSettingsViewProtocol
  func contentPresenterView(uiConfig: ShiftUIConfig,
                            presenter: ContentPresenterPresenterProtocol) -> ContentPresenterViewController
  func dataConfirmationView(uiConfig: ShiftUIConfig,
                            presenter: DataConfirmationPresenterProtocol) -> DataConfirmationViewController
  func physicalCardActivationView(uiConfig: ShiftUIConfig,
                                  presenter: PhysicalCardActivationSucceedPresenterProtocol)
      -> PhysicalCardActivationSucceedViewController
}
