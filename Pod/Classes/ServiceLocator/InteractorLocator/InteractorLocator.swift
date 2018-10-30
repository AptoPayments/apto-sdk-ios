//
//  InteractorLocator.swift
//  ShiftSDK
//
//  Created by Takeichi Kanzaki on 07/06/2018.
//
//

final class InteractorLocator: InteractorLocatorProtocol {
  private unowned let serviceLocator: ServiceLocatorProtocol

  init(serviceLocator: ServiceLocatorProtocol) {
    self.serviceLocator = serviceLocator
  }

  func fullScreenDisclaimerInteractor(disclaimer: Content) -> FullScreenDisclaimerInteractorProtocol {
    return FullScreenDisclaimerInteractor(disclaimer: disclaimer)
  }

  func authInteractor(shiftSession: ShiftSession,
                      initialUserData: DataPointList,
                      authConfig: AuthModuleConfig,
                      dataReceiver: AuthDataReceiver) -> AuthInteractorProtocol {
    return AuthInteractor(session: shiftSession,
                          initialUserData: initialUserData,
                          config: authConfig,
                          dataReceiver: dataReceiver)
  }

  func externalOAuthInteractor(session: ShiftSession) -> ExternalOAuthInteractorProtocol {
    return ExternalOAuthInteractor(shiftSession: session)
  }

  func issueCardInteractor(cardSession: ShiftCardSession, application: CardApplication) -> IssueCardInteractorProtocol {
    return IssueCardInteractor(shiftCardSession: cardSession, application: application)
  }

  func serverMaintenanceErrorInteractor() -> ServerMaintenanceErrorInteractorProtocol {
    return ServerMaintenanceErrorInteractor(networkManager: serviceLocator.networkLocator.networkManager())
  }

  func accountSettingsInteractor() -> AccountSettingsInteractorProtocol {
    return AccountSettingsInteractor(shiftSession: serviceLocator.session)
  }

  func contentPresenterInteractor(content: Content) -> ContentPresenterInteractorProtocol {
    return ContentPresenterInteractor(content: content)
  }

  func dataConfirmationInteractor(userData: DataPointList) -> DataConfirmationInteractorProtocol {
    return DataConfirmationInteractor(userData: userData)
  }

  func physicalCardActivationSucceedInteractor(card: Card) -> PhysicalCardActivationSucceedInteractorProtocol {
    return PhysicalCardActivationSucceedInteractor(card: card)
  }
}
