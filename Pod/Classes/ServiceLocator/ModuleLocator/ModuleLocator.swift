//
//  ModuleLocator.swift
//  ShiftSDK
//
//  Created by Takeichi Kanzaki on 07/06/2018.
//
//

final class ModuleLocator: ModuleLocatorProtocol {
  private unowned let serviceLocator: ServiceLocatorProtocol

  init(serviceLocator: ServiceLocatorProtocol) {
    self.serviceLocator = serviceLocator
  }

  func newApplicationModule(initialDataPointList: DataPointList?) -> NewApplicationModule {
    return NewApplicationModule(serviceLocator: serviceLocator, initialDataPointList: initialDataPointList)
  }

  func fullScreenDisclaimerModule(disclaimer: Content) -> FullScreenDisclaimerModuleProtocol {
    return FullScreenDisclaimerModule(serviceLocator: serviceLocator, disclaimer: disclaimer)
  }

  func authModule(authConfig: AuthModuleConfig, initialUserData: DataPointList) -> AuthModuleProtocol {
    return AuthModule(serviceLocator: serviceLocator, config: authConfig, initialUserData: initialUserData)
  }

  func verifyPhoneModule(verificationType: VerificationParams<PhoneNumber, Verification>) -> VerifyPhoneModuleProtocol {
    return VerifyPhoneModule(serviceLocator: serviceLocator, verificationType: verificationType)
  }

  func verifyEmailModule(verificationType: VerificationParams<Email, Verification>) -> VerifyEmailModuleProtocol {
    return VerifyEmailModule(serviceLocator: serviceLocator, verificationType: verificationType)
  }

  func verifyBirthDateModule(verificationType: VerificationParams<BirthDate, Verification>)
      -> VerifyBirthDateModuleProtocol {
    return VerifyBirthDateModule(serviceLocator: serviceLocator, verificationType: verificationType)
  }

  func externalOAuthModule(config: ExternalOAuthModuleConfig, uiConfig: ShiftUIConfig) -> ExternalOAuthModuleProtocol {
    return ExternalOAuthModule(serviceLocator: serviceLocator, config: config, uiConfig: uiConfig)
  }

  func userDataCollectorModule(userRequiredData: RequiredDataPointList,
                               mode: UserDataCollectorFinalStepMode,
                               backButtonMode: UIViewControllerLeftButtonMode,
                               disclaimers: [Content]) -> UserDataCollectorModule {
    return UserDataCollectorModule(serviceLocator: serviceLocator,
                                   userRequiredData: userRequiredData,
                                   mode: mode,
                                   backButtonMode: backButtonMode,
                                   disclaimers: disclaimers)
  }

  func selectBalanceStoreModule(application: CardApplication) -> SelectBalanceStoreModuleProtocol {
    return SelectBalanceStoreModule(serviceLocator: serviceLocator, application: application)
  }

  func showDisclaimerActionModule(workflowObject: WorkflowObject,
                                  workflowAction: WorkflowAction) -> ShowDisclaimerActionModuleProtocol {
    return ShowDisclaimerActionModule(serviceLocator: serviceLocator,
                                      workflowObject: workflowObject,
                                      workflowAction: workflowAction,
                                      actionConfirmer: UIAlertController.self)
  }

  func verifyDocumentModule(workflowObject: WorkflowObject?) -> VerifyDocumentModule {
    return VerifyDocumentModule(serviceLocator: serviceLocator, workflowObject: workflowObject)
  }

  func issueCardModule(application: CardApplication) -> UIModuleProtocol {
    return IssueCardModule(serviceLocator: serviceLocator, application: application)
  }

  // MARK: - Errors
  func serverMaintenanceErrorModule() -> ServerMaintenanceErrorModuleProtocol {
    return ServerMaintenanceErrorModule(serviceLocator: serviceLocator)
  }

  func accountSettingsModule() -> UIModuleProtocol {
    return AccountSettingsModule(serviceLocator: serviceLocator)
  }

  func contentPresenterModule(content: Content, title: String) -> ContentPresenterModuleProtocol {
    return ContentPresenterModule(serviceLocator: serviceLocator, content: content, title: title)
  }

  func dataConfirmationModule(userData: DataPointList) -> DataConfirmationModuleProtocol {
    return DataConfirmationModule(serviceLocator: serviceLocator, userData: userData)
  }

  func webBrowserModule(url: URL, headers: [String: String]? = nil) -> UIModuleProtocol {
    return WebBrowserModule(serviceLocator: serviceLocator, url: url, headers: headers)
  }

  // MARK: - Manage card
  func manageCardModule(card: Card, mode: ShiftCardModuleMode) -> UIModuleProtocol {
    return ManageShiftCardModule(serviceLocator: serviceLocator, card: card, mode: mode)
  }

  func fundingSourceSelector(card: Card) -> FundingSourceSelectorModuleProtocol {
    return FundingSourceSelectorModule(serviceLocator: serviceLocator, card: card)
  }

  func cardSettingsModule(card: Card) -> ShiftCardSettingsModuleProtocol {
    return ShiftCardSettingsModule(serviceLocator: serviceLocator, card: card, phoneCaller: PhoneCaller())
  }

  // MARK: - Physical card activation
  func physicalCardActivationModule(card: Card) -> PhysicalCardActivationModuleProtocol {
    return PhysicalCardActivationModule(serviceLocator: serviceLocator, card: card, phoneCaller: PhoneCaller())
  }

  func physicalCardActivationSucceedModule(card: Card) -> PhysicalCardActivationSucceedModuleProtocol {
    return PhysicalCardActivationSucceedModule(serviceLocator: serviceLocator, card: card, phoneCaller: PhoneCaller())
  }
}
