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
                  uiConfig: ShiftUIConfig,
                  initialUserData: DataPointList) -> AuthModuleProtocol {
    return AuthModule(serviceLocator: serviceLocator,
                      config: authConfig,
                      uiConfig: uiConfig,
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
  func serverMaintenanceErrorModule(uiConfig: ShiftUIConfig?) -> ServerMaintenanceErrorModuleProtocol {
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
}

class UIModuleSpy: UIModule {
  private(set) var initializeCalled = false
  private(set) var lastInitializeCompletion: Result<UIViewController, NSError>.Callback?
  override func initialize(completion: @escaping Result<UIViewController, NSError>.Callback) {
    initializeCalled = true
    lastInitializeCompletion = completion
  }

  private(set) var closeCalled = false
  override func close() {
    closeCalled = true
  }

  private(set) var backCalled = false
  override func back() {
    backCalled = true
  }

  private(set) var nextCalled = false
  override func next() {
    nextCalled = true
  }

  private(set) var pushViewControllerCalled = false
  private(set) var lastViewControllerPushed: UIViewController?
  private(set) var lastViewControllerPushedAnimated: Bool?
  private(set) var lastViewControllerPushedLeftButtonMode: UIViewControllerLeftButtonMode?
  private(set) var lastViewControllerPushedCompletion: (() -> Void)?
  override func push(viewController: UIViewController,
                     animated: Bool?,
                     leftButtonMode: UIViewControllerLeftButtonMode?,
                     completion: @escaping (() -> Void)) {
    pushViewControllerCalled = true
    lastViewControllerPushed = viewController
    lastViewControllerPushedAnimated = animated
    lastViewControllerPushedLeftButtonMode = leftButtonMode
    lastViewControllerPushedCompletion = completion
  }

  private(set) var popViewControllerCalled = false
  private(set) var lastViewControllerPoppedAnimated: Bool?
  private(set) var lastViewControllerPoppedCompletion: (() -> Void)?
  override func popViewController(animated: Bool?,
                                  completion: @escaping (() -> Void)) {
    popViewControllerCalled = true
    lastViewControllerPoppedAnimated = animated
    lastViewControllerPoppedCompletion = completion
  }

  private(set) var presentViewControllerCalled = false
  private(set) var lastViewControllerPresented: UIViewController?
  private(set) var lastViewControllerPresentedAnimated: Bool?
  private(set) var lastViewControllerPresentedCompletion: (() -> Void)?
  override func present(viewController: UIViewController,
                        animated: Bool?,
                        completion: @escaping (() -> Void)) {
    presentViewControllerCalled = true
    lastViewControllerPresented = viewController
    lastViewControllerPresentedAnimated = animated
    lastViewControllerPresentedCompletion = completion
  }

  private(set) var pushModuleCalled = false
  private(set) var lastModulePushed: UIModuleProtocol?
  private(set) var lastModulePushedAnimated: Bool?
  private(set) var lastModulePushedLeftButtonMode: UIViewControllerLeftButtonMode?
  private(set) var lastModulePushedCompletion: Result<UIViewController, NSError>.Callback?
  override func push(module: UIModuleProtocol,
                     animated: Bool?,
                     leftButtonMode: UIViewControllerLeftButtonMode?,
                     completion: @escaping Result<UIViewController, NSError>.Callback) {
    pushModuleCalled = true
    lastModulePushed = module
    lastModulePushedAnimated = animated
    lastModulePushedLeftButtonMode = leftButtonMode
    lastModulePushedCompletion = completion
  }

  private(set) var popModuleCalled = false
  private(set) var lastModulePoppedAnimated: Bool?
  private(set) var lastModulePoppedCompletion: (() -> Void)?
  override func popModule(animated: Bool?,
                          completion: @escaping (() -> Void)) {
    popModuleCalled = true
    lastModulePoppedAnimated = animated
    lastModulePoppedCompletion = completion
  }

  private(set) var removeModuleCalled = false
  private(set) var lastModuleRemoved: UIModuleProtocol?
  private(set) var lastModuleRemovedCompletion: (() -> Void)?
  override func remove(module: UIModuleProtocol, completion: @escaping (() -> Void)) {
    removeModuleCalled = true
    lastModuleRemoved = module
    lastModuleRemovedCompletion = completion
  }

  private(set) var presentModuleCalled = false
  private(set) var lastModulePresented: UIModuleProtocol?
  private(set) var lastModulePresentedAnimated: Bool?
  private(set) var lastModulePresentedLeftButtonMode: UIViewControllerLeftButtonMode?
  private(set) var lastModulePresentedCompletion: Result<UIViewController, NSError>.Callback?
  override func present(module: UIModuleProtocol,
                        animated: Bool?,
                        leftButtonMode: UIViewControllerLeftButtonMode?,
                        completion: @escaping Result<UIViewController, NSError>.Callback) {
    presentModuleCalled = true
    lastModulePresented = module
    lastModulePresentedAnimated = animated
    lastModulePresentedLeftButtonMode = leftButtonMode
    lastModulePresentedCompletion = completion
  }

  private(set) var dismissViewControllerCalled = false
  private(set) var lastViewControllerDismissedAnimated: Bool?
  private(set) var lastViewControllerDismissedCompletion: (() -> Void)?
  override func dismissViewController(animated: Bool?, completion: @escaping (() -> Void)) {
    dismissViewControllerCalled = true
    lastViewControllerDismissedAnimated = animated
    lastViewControllerDismissedCompletion = completion
  }

  private(set) var dismissModuleCalled = false
  private(set) var lastModuleDismissedAnimated: Bool?
  private(set) var lastModuleDismissedCompletion: (() -> Void)?
  override func dismissModule(animated: Bool?, completion: @escaping (() -> Void)) {
    dismissModuleCalled = true
    lastModuleDismissedAnimated = animated
    lastModuleDismissedCompletion = completion
  }

  private(set) var addChildModuleCalled = false
  private(set) var lastChildModuleAdded: UIModuleProtocol?
  private(set) var lastChildModuleLeftButtonMode: UIViewControllerLeftButtonMode?
  private(set) var lastChildModuleAddedCompletion: Result<UIViewController, NSError>.Callback?
  override func addChild(module: UIModuleProtocol,
                         leftButtonMode: UIViewControllerLeftButtonMode?,
                         completion: @escaping Result<UIViewController, NSError>.Callback) {
    addChildModuleCalled = true
    lastChildModuleAdded = module
    lastChildModuleLeftButtonMode = leftButtonMode
    lastChildModuleAddedCompletion = completion
  }

  private(set) var addChildViewControllerCalled = false
  private(set) var lastChildViewControllerAdded: UIViewController?
  private(set) var lastChildViewControllerLeftButtonMode: UIViewControllerLeftButtonMode?
  private(set) var lastChildViewControllerCompletion: Result<UIViewController, NSError>.Callback?
  override func addChild(viewController: UIViewController,
                         leftButtonMode: UIViewControllerLeftButtonMode?,
                         completion: @escaping Result<UIViewController, NSError>.Callback) {
    addChildViewControllerCalled = true
    lastChildViewControllerAdded = viewController
    lastChildViewControllerLeftButtonMode = leftButtonMode
    lastChildViewControllerCompletion = completion
  }

  private(set) var showLoadingSpinnerCalled = false
  private(set) var loadingSpinnerPosition: SubviewPosition?
  override func showLoadingSpinner(position: SubviewPosition = .center) {
    showLoadingSpinnerCalled = true
    loadingSpinnerPosition = position
  }

  private(set) var hidLoadingSpinnerCalled = false
  override func hideLoadingSpinner() {
    hidLoadingSpinnerCalled = true
  }

  private(set) var showErrorCalled = false
  private(set) var lastErrorShown: Error?
  override func show(error: Error) {
    showErrorCalled = true
    lastErrorShown = error
  }
}
