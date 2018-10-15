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

  func authModule(authConfig: AuthModuleConfig,
                  uiConfig: ShiftUIConfig,
                  initialUserData: DataPointList) -> AuthModuleProtocol {
    return AuthModule(serviceLocator: serviceLocator,
                      config: authConfig,
                      uiConfig: uiConfig,
                      initialUserData: initialUserData)
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
                               finalStepTitle: String,
                               finalStepSubtitle: String,
                               finalStepCallToAction: CallToAction,
                               disclaimers: [Content]) -> UserDataCollectorModule {
    return UserDataCollectorModule(serviceLocator: serviceLocator,
                                   userRequiredData: userRequiredData,
                                   mode: mode,
                                   backButtonMode: backButtonMode,
                                   finalStepTitle: finalStepTitle,
                                   finalStepSubtitle: finalStepSubtitle,
                                   finalStepCallToAction: finalStepCallToAction,
                                   disclaimers: disclaimers)
  }

  func selectBalanceStoreModule(application: CardApplication) -> SelectBalanceStoreModuleProtocol {
    return SelectBalanceStoreModule(serviceLocator: serviceLocator, application: application)
  }

  func showDisclaimerActionModule(workflowObject: WorkflowObject,
                                  workflowAction: WorkflowAction) -> ShowDisclaimerActionModuleProtocol {
    return ShowDisclaimerActionModule(serviceLocator: serviceLocator,
                                      workflowObject: workflowObject,
                                      workflowAction: workflowAction)
  }

  func verifyDocumentModule(workflowObject: WorkflowObject?) -> VerifyDocumentModule {
    return VerifyDocumentModule(serviceLocator: serviceLocator, workflowObject: workflowObject)
  }

  func issueCardModule(application: CardApplication) -> UIModuleProtocol {
    return IssueCardModule(serviceLocator: serviceLocator, application: application)
  }

  // MARK: - Errors
  func serverMaintenanceErrorModule(uiConfig: ShiftUIConfig?) -> ServerMaintenanceErrorModuleProtocol {
    return ServerMaintenanceErrorModule(serviceLocator: serviceLocator, uiConfig: uiConfig)
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
}
