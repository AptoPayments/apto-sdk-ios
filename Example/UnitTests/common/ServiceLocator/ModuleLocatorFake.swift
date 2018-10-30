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
                               finalStepTitle: String,
                               finalStepSubtitle: String,
                               finalStepCallToAction: CallToAction,
                               disclaimers: [Content]) -> UserDataCollectorModule {
    Swift.fatalError("userDataCollectorModule(...) has not been implemented")
  }

  func selectBalanceStoreModule(application: CardApplication) -> SelectBalanceStoreModuleProtocol {
    Swift.fatalError("selectBalanceStoreModule(application:) has not been implemented")
  }

  func showDisclaimerActionModule(workflowObject: WorkflowObject,
                                  workflowAction: WorkflowAction) -> ShowDisclaimerActionModuleProtocol {
    Swift.fatalError("showDisclaimerActionModule(disclaimer:) has not been implemented")
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

  lazy var physicalCardActivationSucceedModuleFake: PhysicalCardActivationSucceedModuleFake = {
    return PhysicalCardActivationSucceedModuleFake(serviceLocator: serviceLocator)
  }()
  func physicalCardActivationSucceedModule(card: Card) -> PhysicalCardActivationSucceedModuleProtocol {
    return physicalCardActivationSucceedModuleFake
  }
}
