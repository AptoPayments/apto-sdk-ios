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

  func verifyPhoneInteractor(verificationType: VerificationParams<PhoneNumber, Verification>,
                             dataReceiver: VerifyPhoneDataReceiver) -> VerifyPhoneInteractorProtocol {
    return VerifyPhoneInteractor(session: serviceLocator.session,
                                 verificationType: verificationType,
                                 dataReceiver: dataReceiver)
  }

  func verifyBirthDateInteractor(verificationType: VerificationParams<BirthDate, Verification>,
                                 dataReceiver: VerifyBirthDateDataReceiver) -> VerifyBirthDateInteractorProtocol {
    return VerifyBirthDateInteractor(session: serviceLocator.session,
                                     verificationType: verificationType,
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

  func webBrowserInteractor(url: URL,
                            headers: [String: String]?,
                            dataReceiver: WebBrowserDataReceiverProtocol) -> WebBrowserInteractorProtocol {
    return WebBrowserInteractor(url: url, headers: headers, dataReceiver: dataReceiver)
  }

  // MARK: - Manage card
  func manageCardInteractor(card: Card) -> ManageShiftCardInteractorProtocol {
    return ManageShiftCardInteractor(shiftSession: serviceLocator.session, card: card)
  }

  func fundingSourceSelector(card: Card) -> FundingSourceSelectorInteractorProtocol {
    return FundingSourceSelectorInteractor(card: card, cardSession: serviceLocator.session.shiftCardSession)
  }

  func cardSettingsInteractor() -> ShiftCardSettingsInteractorProtocol {
    return ShiftCardSettingsInteractor()
  }

  func kycInteractor(card: Card) -> KYCInteractorProtocol {
    return KYCInteractor(shiftSession: serviceLocator.session, card: card)
  }

  // MARK: - Physical card activation
  func physicalCardActivationInteractor(card: Card, session: ShiftSession) -> PhysicalCardActivationInteractorProtocol {
    return PhysicalCardActivationInteractor(card: card, session: session)
  }

  func physicalCardActivationSucceedInteractor(card: Card) -> PhysicalCardActivationSucceedInteractorProtocol {
    return PhysicalCardActivationSucceedInteractor(card: card)
  }

  // MARK: - Transaction Details
  func transactionDetailsInteractor(transaction: Transaction) -> ShiftCardTransactionDetailsInteractorProtocol {
    return ShiftCardTransactionDetailsInteractor(shiftSession: serviceLocator.session, transaction: transaction)
  }

}
