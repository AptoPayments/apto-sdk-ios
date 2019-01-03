//
//  ModuleLocatorProtocol.swift
//  ShiftSDK
//
//  Created by Takeichi Kanzaki on 07/06/2018.
//
//

protocol ModuleLocatorProtocol {
  func newApplicationModule(initialDataPointList: DataPointList?) -> NewApplicationModule
  func fullScreenDisclaimerModule(disclaimer: Content) -> FullScreenDisclaimerModuleProtocol

  // MARK: - Auth module
  func authModule(authConfig: AuthModuleConfig, initialUserData: DataPointList) -> AuthModuleProtocol
  func verifyPhoneModule(verificationType: VerificationParams<PhoneNumber, Verification>) -> VerifyPhoneModuleProtocol
  func verifyEmailModule(verificationType: VerificationParams<Email, Verification>) -> VerifyEmailModuleProtocol
  func verifyBirthDateModule(verificationType: VerificationParams<BirthDate, Verification>)
      -> VerifyBirthDateModuleProtocol
  func externalOAuthModule(config: ExternalOAuthModuleConfig, uiConfig: ShiftUIConfig) -> ExternalOAuthModuleProtocol

  // MARK: - Data collector
  func userDataCollectorModule(userRequiredData: RequiredDataPointList,
                               mode: UserDataCollectorFinalStepMode,
                               backButtonMode: UIViewControllerLeftButtonMode,
                               disclaimers: [Content]) -> UserDataCollectorModule
  func selectBalanceStoreModule(application: CardApplication) -> SelectBalanceStoreModuleProtocol
  func showDisclaimerActionModule(workflowObject: WorkflowObject,
                                  workflowAction: WorkflowAction) -> ShowDisclaimerActionModuleProtocol
  func verifyDocumentModule(workflowObject: WorkflowObject?) -> VerifyDocumentModule
  func issueCardModule(application: CardApplication) -> UIModuleProtocol

  // MARK: - Errors
  func serverMaintenanceErrorModule() -> ServerMaintenanceErrorModuleProtocol

  func accountSettingsModule() -> UIModuleProtocol
  func contentPresenterModule(content: Content, title: String) -> ContentPresenterModuleProtocol
  func dataConfirmationModule(userData: DataPointList) -> DataConfirmationModuleProtocol
  func webBrowserModule(url: URL, headers: [String: String]?) -> UIModuleProtocol

  // MARK: - Manage card
  func manageCardModule(card: Card, mode: ShiftCardModuleMode) -> UIModuleProtocol
  func fundingSourceSelector(card: Card) -> FundingSourceSelectorModuleProtocol
  func cardSettingsModule(card: Card) -> ShiftCardSettingsModuleProtocol

  // MARK: - Physical card activation
  func physicalCardActivationModule(card: Card) -> PhysicalCardActivationModuleProtocol
  func physicalCardActivationSucceedModule(card: Card) -> PhysicalCardActivationSucceedModuleProtocol
}
