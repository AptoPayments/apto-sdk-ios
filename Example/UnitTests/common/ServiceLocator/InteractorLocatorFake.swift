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

  func verifyPhoneInteractor(verificationType: VerificationParams<PhoneNumber, Verification>,
                             dataReceiver: VerifyPhoneDataReceiver) -> VerifyPhoneInteractorProtocol {
    Swift.fatalError("verifyPhoneInteractor(verificationType:dataReceiver:) has not been implemented")
  }

  func verifyBirthDateInteractor(verificationType: VerificationParams<BirthDate, Verification>,
                                 dataReceiver: VerifyBirthDateDataReceiver) -> VerifyBirthDateInteractorProtocol {
    Swift.fatalError("verifyBirthDateInteractor(verificationType:dataReceiver:) has not been implemented")
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

  lazy var dataConfirmationInteractorFake = DataConfirmationInteractorFake()
  func dataConfirmationInteractor(userData: DataPointList) -> DataConfirmationInteractorProtocol {
    return dataConfirmationInteractorFake
  }

  lazy var webBrowserInteractorSpy = WebBrowserInteractorSpy()
  func webBrowserInteractor(url: URL,
                            headers: [String: String]?,
                            dataReceiver: WebBrowserDataReceiverProtocol) -> WebBrowserInteractorProtocol {
    return webBrowserInteractorSpy
  }

  // MARK: - Manage card
  func manageCardInteractor(card: Card) -> ManageShiftCardInteractorProtocol {
    Swift.fatalError("manageCardInteractor(card:) has not been implemented")
  }

  func fundingSourceSelector(card: Card) -> FundingSourceSelectorInteractorProtocol {
    Swift.fatalError("fundingSourceSelector(card:) has not been implemented")
  }

  func cardSettingsInteractor() -> ShiftCardSettingsInteractorProtocol {
    Swift.fatalError("cardSettingsInteractor() has not been implemented")
  }

  func kycInteractor(card: Card) -> KYCInteractorProtocol {
    Swift.fatalError("kycInteractor(card:) has not been implemented")
  }

  // MARK: - Physical card activation
  func physicalCardActivationInteractor(card: Card, session: ShiftSession) -> PhysicalCardActivationInteractorProtocol {
    Swift.fatalError("physicalCardActivationInteractor(card:session:) has not been implemented")
  }

  lazy var physicalCardActivationSucceedInteractorFake = PhysicalCardActivationSucceedInteractorFake()
  func physicalCardActivationSucceedInteractor(card: Card) -> PhysicalCardActivationSucceedInteractorProtocol {
    physicalCardActivationSucceedInteractorFake.card = card
    return physicalCardActivationSucceedInteractorFake
  }

  // MARK: - Transaction Details
  func transactionDetailsInteractor(transaction: Transaction) -> ShiftCardTransactionDetailsInteractorProtocol {
    Swift.fatalError("transactionDetailsInteractor(transaction:) has not been implemented")
  }
}
