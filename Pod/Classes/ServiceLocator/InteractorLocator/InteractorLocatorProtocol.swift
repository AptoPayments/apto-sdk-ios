//
//  InteractorLocatorProtocol.swift
//  ShiftSDK
//
//  Created by Takeichi Kanzaki on 07/06/2018.
//
//

protocol InteractorLocatorProtocol {
  func fullScreenDisclaimerInteractor(disclaimer: Content) -> FullScreenDisclaimerInteractorProtocol

  // MARK: - Auth
  func authInteractor(shiftSession: ShiftSession,
                      initialUserData: DataPointList,
                      authConfig: AuthModuleConfig,
                      dataReceiver: AuthDataReceiver) -> AuthInteractorProtocol
  func verifyPhoneInteractor(verificationType: VerificationParams<PhoneNumber, Verification>,
                             dataReceiver: VerifyPhoneDataReceiver) -> VerifyPhoneInteractorProtocol
  func verifyBirthDateInteractor(verificationType: VerificationParams<BirthDate, Verification>,
                                 dataReceiver: VerifyBirthDateDataReceiver) -> VerifyBirthDateInteractorProtocol
  func externalOAuthInteractor(session: ShiftSession) -> ExternalOAuthInteractorProtocol

  func issueCardInteractor(cardSession: ShiftCardSession, application: CardApplication) -> IssueCardInteractorProtocol
  func serverMaintenanceErrorInteractor() -> ServerMaintenanceErrorInteractorProtocol
  func accountSettingsInteractor() -> AccountSettingsInteractorProtocol
  func contentPresenterInteractor(content: Content) -> ContentPresenterInteractorProtocol
  func dataConfirmationInteractor(userData: DataPointList) -> DataConfirmationInteractorProtocol
  func webBrowserInteractor(url: URL,
                            headers: [String: String]?,
                            dataReceiver: WebBrowserDataReceiverProtocol) -> WebBrowserInteractorProtocol

  // MARK: - Manage card
  func manageCardInteractor(card: Card) -> ManageShiftCardInteractorProtocol
  func fundingSourceSelector(card: Card) -> FundingSourceSelectorInteractorProtocol
  func cardSettingsInteractor() -> ShiftCardSettingsInteractorProtocol
  func kycInteractor(card: Card) -> KYCInteractorProtocol

  // MARK: - Physical card activation
  func physicalCardActivationInteractor(card: Card, session: ShiftSession) -> PhysicalCardActivationInteractorProtocol
  func physicalCardActivationSucceedInteractor(card: Card) -> PhysicalCardActivationSucceedInteractorProtocol

  // MARK: - Transaction Details
  func transactionDetailsInteractor(transaction: Transaction) -> ShiftCardTransactionDetailsInteractorProtocol
}
