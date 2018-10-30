//
//  InteractorLocatorProtocol.swift
//  ShiftSDK
//
//  Created by Takeichi Kanzaki on 07/06/2018.
//
//

protocol InteractorLocatorProtocol {
  func fullScreenDisclaimerInteractor(disclaimer: Content) -> FullScreenDisclaimerInteractorProtocol
  func authInteractor(shiftSession: ShiftSession,
                      initialUserData: DataPointList,
                      authConfig: AuthModuleConfig,
                      dataReceiver: AuthDataReceiver) -> AuthInteractorProtocol
  func externalOAuthInteractor(session: ShiftSession) -> ExternalOAuthInteractorProtocol
  func issueCardInteractor(cardSession: ShiftCardSession, application: CardApplication) -> IssueCardInteractorProtocol
  func serverMaintenanceErrorInteractor() -> ServerMaintenanceErrorInteractorProtocol
  func accountSettingsInteractor() -> AccountSettingsInteractorProtocol
  func contentPresenterInteractor(content: Content) -> ContentPresenterInteractorProtocol
  func dataConfirmationInteractor(userData: DataPointList) -> DataConfirmationInteractorProtocol
  func physicalCardActivationSucceedInteractor(card: Card) -> PhysicalCardActivationSucceedInteractorProtocol
}
