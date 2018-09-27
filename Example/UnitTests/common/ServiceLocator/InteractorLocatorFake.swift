//
//  InteractorLocatorFake.swift
//  ShiftSDK
//
//  Created by Takeichi Kanzaki on 08/06/2018.
//
//

@testable import ShiftSDK

class InteractorLocatorFake: InteractorLocatorProtocol {
  lazy var fullScreenDisclaimerInteractorSpy = FullScreenDisclaimerInteractorSpy()
  func fullScreenDisclaimerInteractor(disclaimer: Content) -> FullScreenDisclaimerInteractorProtocol {
    return fullScreenDisclaimerInteractorSpy
  }

  lazy var authInteractorSpy = AuthInteractorSpy()
  func authInteractor(shiftSession: ShiftSession,
                      initialUserData: DataPointList,
                      authConfig: AuthModuleConfig,
                      dataReceiver: AuthDataReceiver) -> AuthInteractorProtocol {
    return authInteractorSpy
  }

  lazy var externalOauthInteractorSpy = ExternalOAuthInteractorSpy()
  func externalOAuthInteractor(session: ShiftSession) -> ExternalOAuthInteractorProtocol {
    return externalOauthInteractorSpy
  }

  lazy var issueCardInteractorFake = IssueCardInteractorFake()
  func issueCardInteractor(cardSession: ShiftCardSession, application: CardApplication) -> IssueCardInteractorProtocol {
    return issueCardInteractorFake
  }

  lazy var serverMaintenanceErrorInteractorSpy = ServerMaintenanceErrorInteractorSpy()
  func serverMaintenanceErrorInteractor() -> ServerMaintenanceErrorInteractorProtocol {
    return serverMaintenanceErrorInteractorSpy
  }

  func accountSettingsInteractor() -> AccountSettingsInteractorProtocol {
    Swift.fatalError("accountSettingsInteractor() has not been implemented")
  }

  lazy var contentProviderInteractorFake = ContentPresenterInteractorFake()
  func contentPresenterInteractor(content: Content) -> ContentPresenterInteractorProtocol {
    return contentProviderInteractorFake
  }
}
