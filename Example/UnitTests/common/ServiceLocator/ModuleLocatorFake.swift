//
//  ModuleLocatorFake.swift
//  ShiftSDK
//
//  Created by Takeichi Kanzaki on 08/06/2018.
//
//

@testable import ShiftSDK

class ModuleLocatorFake: ModuleLocatorProtocol {

  private unowned let serviceLocator: ServiceLocatorProtocol

  init(serviceLocator: ServiceLocatorProtocol) {
    self.serviceLocator = serviceLocator
  }

  func newApplicationModule(initialDataPointList: DataPointList?) -> NewApplicationModule {
    return NewApplicationModule(serviceLocator: serviceLocator, initialDataPointList: initialDataPointList)
  }

  lazy var fullScreenDisclaimerModuleSpy: FullScreenDisclaimerModuleSpy = {
    return FullScreenDisclaimerModuleSpy(serviceLocator: serviceLocator)
  }()
  func fullScreenDisclaimerModule(disclaimer: Content) -> FullScreenDisclaimerModuleProtocol {
    return fullScreenDisclaimerModuleSpy
  }

  func authModule(authConfig: AuthModuleConfig,
                  initialUserData: DataPointList) -> AuthModuleProtocol {
    return AuthModule(serviceLocator: serviceLocator,
                      config: authConfig,
                      initialUserData: initialUserData)
  }

  lazy var externalOauthModuleFake: ExternalOAuthModuleFake = {
    return ExternalOAuthModuleFake(serviceLocator: serviceLocator)
  }()
  func externalOAuthModule(config: ExternalOAuthModuleConfig, uiConfig: ShiftUIConfig) -> ExternalOAuthModuleProtocol {
    return externalOauthModuleFake
  }

  lazy var verifyPhoneModuleSpy: VerifyPhoneModuleSpy = {
    return VerifyPhoneModuleSpy(serviceLocator: serviceLocator)
  }()
  func verifyPhoneModule(verificationType: VerificationParams<PhoneNumber, Verification>) -> VerifyPhoneModuleProtocol {
    return verifyPhoneModuleSpy
  }

  lazy var verifyEmailModuleSpy: VerifyEmailModuleSpy = {
    return VerifyEmailModuleSpy(serviceLocator: serviceLocator)
  }()
  func verifyEmailModule(verificationType: VerificationParams<Email, Verification>) -> VerifyEmailModuleProtocol {
    return verifyEmailModuleSpy
  }

  lazy var verifyBirthDateModuleSpy: VerifyBirthDateModuleSpy = {
    return VerifyBirthDateModuleSpy(serviceLocator: serviceLocator)
  }()
  func verifyBirthDateModule(verificationType: VerificationParams<BirthDate, Verification>)
      -> VerifyBirthDateModuleProtocol {
    return verifyBirthDateModuleSpy
  }

  func userDataCollectorModule(userRequiredData: RequiredDataPointList,
                               mode: UserDataCollectorFinalStepMode,
                               backButtonMode: UIViewControllerLeftButtonMode,
                               disclaimers: [Content]) -> UserDataCollectorModule {
    Swift.fatalError("userDataCollectorModule(...) has not been implemented")
  }

  lazy var selectBalanceStoreModuleSpy: SelectBalanceStoreModuleProtocol = {
      return SelectBalanceStoreModuleSpy(serviceLocator: serviceLocator)
  }()
  func selectBalanceStoreModule(application: CardApplication) -> SelectBalanceStoreModuleProtocol {
    return selectBalanceStoreModuleSpy
  }

  lazy var showDisclaimerActionModuleSpy: ShowDisclaimerActionModuleProtocol = {
    return ShowDisclaimerActionModuleSpy(serviceLocator: serviceLocator)
  }()
  func showDisclaimerActionModule(workflowObject: WorkflowObject,
                                  workflowAction: WorkflowAction) -> ShowDisclaimerActionModuleProtocol {
    return showDisclaimerActionModuleSpy
  }

  func verifyDocumentModule(workflowObject: WorkflowObject?) -> VerifyDocumentModule {
    Swift.fatalError("verifyDocumentModule(workflowObject:) has not been implemented")
  }

  lazy var issueCardModuleSpy: IssueCardModuleSpy = {
    return IssueCardModuleSpy(serviceLocator: serviceLocator)
  }()
  func issueCardModule(application: CardApplication) -> UIModuleProtocol {
    return issueCardModuleSpy
  }

  lazy var serverMaintenanceErrorModuleSpy: ServerMaintenanceErrorModuleSpy = {
    return ServerMaintenanceErrorModuleSpy(serviceLocator: serviceLocator)
  }()
  func serverMaintenanceErrorModule() -> ServerMaintenanceErrorModuleProtocol {
    return serverMaintenanceErrorModuleSpy
  }

  func accountSettingsModule() -> UIModuleProtocol {
    Swift.fatalError("accountSettingsModule() has not been implemented")
  }

  lazy var contentPresenterModuleSpy: ContentPresenterModuleSpy = {
    return ContentPresenterModuleSpy(serviceLocator: serviceLocator)
  }()
  func contentPresenterModule(content: Content, title: String) -> ContentPresenterModuleProtocol {
    return contentPresenterModuleSpy
  }

  lazy var dataConfirmationModuleSpy: DataConfirmationModuleSpy = {
    return DataConfirmationModuleSpy(serviceLocator: serviceLocator)
  }()
  func dataConfirmationModule(userData: DataPointList) -> DataConfirmationModuleProtocol {
    return dataConfirmationModuleSpy
  }

  lazy var webBrowserModuleSpy: WebBrowserModuleSpy = {
    return WebBrowserModuleSpy(serviceLocator: serviceLocator)
  }()
  func webBrowserModule(url: URL, headers: [String: String]? = nil) -> UIModuleProtocol {
    return webBrowserModuleSpy
  }

  // MARK: - Manage card
  func manageCardModule(card: Card, mode: ShiftCardModuleMode) -> UIModuleProtocol {
    Swift.fatalError("manageCardModule(card:mode:) has not been implemented")
  }

  func fundingSourceSelector(card: Card) -> FundingSourceSelectorModuleProtocol {
    Swift.fatalError("fundingSourceSelector(card:) has not been implemented")
  }

  func cardSettingsModule(card: Card) -> ShiftCardSettingsModuleProtocol {
    Swift.fatalError("cardSettingsModule(card:) has not been implemented")
  }

  // MARK: - Physical card activation
  func physicalCardActivationModule(card: Card) -> PhysicalCardActivationModuleProtocol {
    Swift.fatalError("physicalCardActivationModule(card:) has not been implemented")
  }

  lazy var physicalCardActivationSucceedModuleFake: PhysicalCardActivationSucceedModuleFake = {
    return PhysicalCardActivationSucceedModuleFake(serviceLocator: serviceLocator)
  }()
  func physicalCardActivationSucceedModule(card: Card) -> PhysicalCardActivationSucceedModuleProtocol {
    return physicalCardActivationSucceedModuleFake
  }
}
