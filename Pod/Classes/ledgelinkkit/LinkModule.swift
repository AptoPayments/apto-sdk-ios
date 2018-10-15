//
//  LinkModule.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 14/10/2016.
//
//

import Foundation

open class LinkModule: UIModule {

  var linkSession: LinkSession {
    return shiftSession.linkSession
  }
  var offerApplierViewController: UIViewController?
  var authModule: AuthModuleProtocol?
  var applicationListModule: LinkApplicationListModule?
  var newApplicationModule: NewApplicationModule?
  var workflowModule: WorkflowModule?

  var contextConfiguration:ContextConfiguration!
  var projectConfiguration: ProjectConfiguration {
    return contextConfiguration.projectConfiguration
  }
  var linkConfiguration:LinkConfiguration!
  var userMissingDataPoints: RequiredDataPointList!
  var userDataPoints: DataPointList!

  let initialLoanData: AppLoanData?
  let initialUserData: DataPointList?

  public init(initialLoanData: AppLoanData? = nil,
              initialUserData: DataPointList? = nil,
              merchantData: MerchantData? = nil) {

    self.initialLoanData = initialLoanData
    self.initialUserData = initialUserData

    super.init(serviceLocator: ServiceLocator.shared)

    self.shiftSession.linkSession = LinkSession(shiftSession: self.shiftSession)

    if let initialLoanData = initialLoanData {
      linkSession.loanData.amount = initialLoanData.amount
      shiftSession.linkSession.loanData.category = initialLoanData.category
      shiftSession.linkSession.loanData.purposeId.next(initialLoanData.purposeId.value)
    }
    if let merchantData = merchantData {
      shiftSession.merchantData = merchantData
    }

  }

  // MARK: - Module Initialization
  override public func close() {
    if self.linkConfiguration.posMode == true {
      clearUserToken()
      NotificationCenter.default.removeObserver(self, name: .UIApplicationDidEnterBackground, object: nil)
    }
    NotificationCenter.default.removeObserver(self, name: .UserTokenSessionExpiredNotification, object: nil)
    super.close()
  }

  @objc fileprivate func clearUserToken() {
    ShiftPlatform.defaultManager().clearUserToken()
  }

  override public func initialize(completion: @escaping Result<UIViewController, NSError>.Callback) {

    self.loadConfigurationFromServer { result in

      switch result {
      case .failure(let error):
        completion(.failure(error))
        return
      case .success:

        self.uiConfig = ShiftUIConfig(projectConfiguration: self.projectConfiguration)

        if self.linkConfiguration.posMode == true {

          // POS Mode
          NotificationCenter.default.addObserver(self, selector: #selector(self.clearUserToken), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)

          // Empty user data
          self.userDataPoints = DataPointList()
          self.userMissingDataPoints = self.linkConfiguration.userRequiredData.getMissingDataPoints(self.userDataPoints)

          // Prepare the initial screen
          self.prepareInitialScreen(completion)

          // Register to the session expired event
          NotificationCenter.default.addObserver(self, selector: #selector(self.didReceiveSessionExpiredEvent(_:)), name: .UserTokenSessionExpiredNotification, object: nil)

        }
        else {

          // try to get info about the current user
          self.shiftSession.currentUser (filterInvalidTokenResult:false) { result in

            switch result {
            case .failure:

              // There's no current user.
              self.userDataPoints = DataPointList()
              ShiftPlatform.defaultManager().clearUserToken()

            case .success (let user):
              self.userDataPoints = user.userData
            }

            // Calculate the missing data points
            self.userMissingDataPoints = self.linkConfiguration.userRequiredData.getMissingDataPoints(self.userDataPoints)

            // Prepare the initial screen
            self.prepareInitialScreen(completion)

            // Register to the session expired event
            NotificationCenter.default.addObserver(self, selector: #selector(self.didReceiveSessionExpiredEvent(_:)), name: .UserTokenSessionExpiredNotification, object: nil)

          }
        }
      }
    }
  }

  fileprivate func prepareInitialScreen(_ completion:@escaping Result<UIViewController, NSError>.Callback) {

    if self.projectConfiguration.welcomeScreenAction.status == .enabled {
      let welcomeScreenModule = self.buildWelcomeScreenModule()
      self.addChild(module: welcomeScreenModule, completion: completion)
    }
    else {
      guard let _ = self.shiftSession.currentUserToken() else {
        // There's no user. Show the auth module
        let authModule = self.buildAuthModule()
        self.addChild(module:authModule, completion:completion)
        return
      }
      // There's a user. Check if he has already open applications
      self.getApplications() { result in
        switch result {
        case .failure(let error):
          UIApplication.topViewController()?.show(error:error)
        case .success(let applications):
          if applications.count > 0 {
            let applicationListModule = self.buildListApplicationModuleFor(applications: applications)
            self.addChild(module: applicationListModule, completion: completion)
          }
          else {
            let newApplicationModule = self.buildNewApplicationModule(initialDataPointList: nil)
            self.addChild(module: newApplicationModule, completion: completion)
          }
        }
      }
    }
  }

  // MARK: - Welcome Screen Module Handling

  fileprivate func buildWelcomeScreenModule() -> ShowGenericMessageModule {
    let welcomeScreenModule = ShowGenericMessageModule(serviceLocator: serviceLocator,
                                                       showGenericMessageAction: projectConfiguration.welcomeScreenAction)
    welcomeScreenModule.onWelcomeScreenContinue = { [weak self] module in
      guard let wself = self else {
        return
      }
      guard let _ = wself.shiftSession.currentUserToken() else {
        // There's no user. Show the auth module
        wself.authModule = wself.buildAuthModule()
        wself.push(module:wself.authModule!, leftButtonMode: .close) { result in }
        return
      }
      wself.getApplications() { result in
        switch result {
        case .failure(let error):
          UIApplication.topViewController()?.show(error:error)
        case .success(let applications):
          if applications.count > 0 {
            wself.showApplicationListModuleFor(applications: applications, leftButtonMode: .close)
          }
          else {
            wself.showNewApplicationFlow(initialDataPointList: nil, leftButtonMode: .close)
          }
        }
      }
    }
    welcomeScreenModule.onClose = { [weak self] module in
      self?.close()
    }
    return welcomeScreenModule
  }

  // MARK: - Auth Module Handling

  fileprivate func buildAuthModule() -> AuthModuleProtocol {

    // Build the user data collector's config
    let authModuleConfig = self.buildAuthModuleConfig(contextConfiguration: self.contextConfiguration)
    // Prepare the current user's data
    let authModule = serviceLocator.moduleLocator.authModule(authConfig: authModuleConfig,
                                                             uiConfig: uiConfig!,
                                                             initialUserData: userDataPoints)
    authModule.onBack = { [weak self] module in
      self?.popModule {
        self?.authModule = nil
      }
    }
    authModule.onClose = { module in
      self.close()
      self.authModule = nil
    }
    authModule.onExistingUser = { [weak self] module, user in
      guard let wself = self else {
        return
      }
      module.showLoadingSpinner()
      wself.getApplications() { [weak self] result in
        guard let wself = self else {
          return
        }
        switch result {
        case .failure(let error):
          UIApplication.topViewController()!.show(error:error)
        case .success(let applications):
          module.hideLoadingSpinner()
          if applications.count > 0 {
            let applicationListModule = wself.buildListApplicationModuleFor(applications: applications)
            self?.applicationListModule = applicationListModule
            self?.push(module: applicationListModule) { result in }
          }
          else {
            self?.showNewApplicationFlow(initialDataPointList:nil, leftButtonMode: .close) {
              self?.remove(module: module) {}
            }
          }
        }
      }
    }
    return authModule
  }

  fileprivate func buildAuthModuleConfig(contextConfiguration: ContextConfiguration) -> AuthModuleConfig {
    return AuthModuleConfig(projectConfiguration: contextConfiguration.projectConfiguration)
  }

  // MARK: - Loan Application List Handling

  fileprivate func getApplications(callback: @escaping Result<[LoanApplicationSummary], NSError>.Callback) {
    shiftSession.linkSession.nextApplications(0, rows: 100, callback: callback)
  }

  fileprivate func showApplicationListModuleFor(applications: [LoanApplicationSummary], leftButtonMode: UIViewControllerLeftButtonMode? = .back) {
    self.applicationListModule = self.buildListApplicationModuleFor(applications: applications)
    self.push(module: applicationListModule!, leftButtonMode: leftButtonMode) { result in }
  }

  fileprivate func buildListApplicationModuleFor(applications: [LoanApplicationSummary]) -> LinkApplicationListModule {
    let applicationListModule = LinkApplicationListModule(serviceLocator: serviceLocator,
                                                          initialApplications: applications)
    applicationListModule.onApplicationSelected = { module, applicationSummary in
      self.shiftSession.linkSession.applicationStatus(applicationSummary.id) { result in
        switch result {
        case .failure(let error):
          UIApplication.topViewController()?.show(error:error)
        case .success(let application):
          self.workflowModule = self.workflowModuleFor(application: application)
          self.push(module: self.workflowModule!) { result in }
        }
      }
    }
    applicationListModule.onNewApplicationSelected = { module in
      self.showNewApplicationFlow(initialDataPointList:nil)
    }
    applicationListModule.onClose = { [weak self] module in
      self?.close()
      self?.applicationListModule = nil
    }
    applicationListModule.onBack = { module in
      self.popModule() {
        self.applicationListModule = nil
      }
    }
    return applicationListModule
  }

  // MARK: - New Loan Application Flow Handling

  fileprivate func showNewApplicationFlow(initialDataPointList:DataPointList?, leftButtonMode: UIViewControllerLeftButtonMode? = .back, completion:(() -> Void)? = nil) {
    newApplicationModule = buildNewApplicationModule(initialDataPointList:initialDataPointList)
    self.push(module: newApplicationModule!, leftButtonMode: leftButtonMode, completion: { result in
      completion?()
    })
  }

  fileprivate func buildNewApplicationModule(initialDataPointList:DataPointList?) -> NewApplicationModule {
    let newApplicationModule = serviceLocator.moduleLocator.newApplicationModule(
        initialDataPointList: initialDataPointList)
    newApplicationModule.onClose = { module in
      self.close()
      self.newApplicationModule = nil
    }
    newApplicationModule.onBack = { module in
      self.popModule() {
        self.newApplicationModule = nil
      }
    }
    newApplicationModule.onOfferApplied = { module, offer in
      self.showOfferApplierFor(offer: offer)
    }

    return newApplicationModule
  }

  // MARK: - Offer Applier Module Handling

  fileprivate func showOfferApplierFor(offer: LoanOffer) {
    self.offerApplierViewController = self.buildOfferApplierViewController(offer, uiConfig: uiConfig!)
    self.push(viewController: self.offerApplierViewController!) {}
  }

  fileprivate func buildOfferApplierViewController(_ offer:LoanOffer, uiConfig:ShiftUIConfig) -> UIViewController {
    let presenter = LinkApplierPresenter(uiConfiguration: uiConfig)
    let interactor = LinkApplierInteractor(linkSession:self.linkSession, offer:offer)
    let viewController = LinkApplierViewController(uiConfiguration: uiConfig, eventHandler:presenter)
    presenter.view = viewController
    presenter.interactor = interactor
    presenter.router = self
    return viewController
  }

  // MARK: - Configuration HandlingApplication

  fileprivate func loadConfigurationFromServer(_ completion:@escaping Result<Void, NSError>.Callback) {
    self.shiftSession.contextConfiguration(true) { result in
      switch result {
      case .failure(let error):
        completion(.failure(error))
      case .success (let contextConfiguration):
        self.contextConfiguration = contextConfiguration
        self.linkSession.linkConfiguration(true) { result in
          switch result {
          case .failure(let error):
            completion(.failure(error))
          case .success(let linkConfiguration):
            self.linkConfiguration = linkConfiguration
            completion(.success(Void()))
          }
        }
      }
    }
  }

  // MARK: - Notification Handling

  @objc private func didReceiveSessionExpiredEvent(_ notification: Notification) {
    DispatchQueue.main.async {
      UIAlertController.confirm(title: "error.transport.sessionExpired.title".podLocalized(),
                                message: "error.transport.sessionExpired".podLocalized(),
                                okTitle: "general.button.ok".podLocalized(), handler: { action in
        self.close()
      })
    }
  }

}

// MARK: - LinkApplierRouterProtocol protocol

extension LinkModule: LinkApplierRouterProtocol {

  func offerApplied(application: LoanApplication) {

    let workflowModule = self.workflowModuleFor(application: application)

    self.popViewController(animated: false) {
      self.push(module: workflowModule) { [weak self] result in
        self?.offerApplierViewController = nil
      }
    }

  }

  func close(_ animated: Bool?) {
    self.close()
  }

  fileprivate func workflowModuleFor(application: LoanApplication) -> WorkflowModule {
    let moduleFactory = WorkflowModuleFactoryImpl(serviceLocator: serviceLocator, workflowObject: application)

    let workflowModule = WorkflowModule(serviceLocator: serviceLocator,
                                        workflowObject: application,
                                        workflowObjectStatusRequester: self,
                                        workflowModuleFactory: moduleFactory)

    workflowModule.onBack = { module in
      self.popModule() {
        self.workflowModule = nil
      }
    }

    workflowModule.onClose = { module in
      self.close()
      self.workflowModule = nil
    }

    return workflowModule

  }

}

// MARK: - LinkLoanConsentRouterProtocol protocol

extension LinkModule: LinkLoanConsentRouterProtocol {
  func backFromLoanconsent(_ animated:Bool?) {
    self.popViewController() {}
  }
}

// MARK: - WorkflowObjectStatusRequester protocol

extension LinkModule: WorkflowObjectStatusRequester {

  func getStatusOf(workflowObject: WorkflowObject, completion: @escaping (Result<WorkflowObject,NSError>.Callback)) {

    guard let application = workflowObject as? LoanApplication else {
      completion(.failure(ServiceError(code:ServiceError.ErrorCodes.internalIncosistencyError)))
      return
    }

    shiftSession.linkSession.applicationStatus(application.id) { result in
      switch result {
      case .failure(let error):
        UIApplication.topViewController()?.show(error: error)
      case .success(let application):
        completion(.success(application))
      }
    }

  }

}

extension ShiftSession {

  public func startLinkFlow(from: UIViewController, completion: @escaping (Result<UIModule,NSError>.Callback)) {
    self.contextConfiguration(false) { result in
      switch result {
      case .failure(let error):
        completion(.failure(error))
      case .success(let contextConfiguration):
        let linkModule = LinkModule()
        self.initialModule = linkModule
        linkModule.onClose = { [unowned self] module in
          from.dismiss(animated: true) {}
          self.initialModule = nil
        }
        let uiConfig = ShiftUIConfig(projectConfiguration: contextConfiguration.projectConfiguration)
        from.present(module: linkModule, animated: true, uiConfig: uiConfig) { result in
          switch result {
          case .failure(let error):
            completion(.failure(error))
          case .success:
            completion(.success(linkModule))
            break
          }
        }
      }
    }
  }

}
