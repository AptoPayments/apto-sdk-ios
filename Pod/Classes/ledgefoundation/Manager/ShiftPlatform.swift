//
//  ShiftSDK.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 18/01/16.
//  Copyright © 2018 Shift. All rights reserved.
//

import Foundation
import TrustKit

@objc public protocol ShiftPlatformDelegate {
  /**
   * Called when the user authentication status changed, i.e., on sign up, sign in and logout processes.
   *
   * - Parameter userToken: authentication token received or `nil` if the triggering action is a logout.
   */
  func newUserTokenReceived(_ userToken: String?)

  /**
   * Called once the SDK has been completely initialized.
   *
   * - Parameters:
   *   - developerKey: developer API key
   *   - projectKey: project API key
   */
  func shiftSDKInitialized(developerKey: String, projectKey: String)

  /**
   * Called when a network request fails because the device is not connected to the Internet. The failed request will
   * be sent again once the connection is restored. The function should return `true` if it completely handle the
   * situation, `false` otherwise.
   *
   * If `false` is returned a UI blocking error message will be shown and automatically removed once the connection is
   * restored. This is the default behaviour in case the method is not implemented.
   */
  @objc optional func networkConnectionError() -> Bool

  /**
   * Called when the network connection is restored. If you choose to handle the network connection error by yourself
   * on `networkConnectionError` you have to restore the UI state when this function is called.
   */
  @objc optional func networkConnectionRestored()

  /**
   * Called when a network request fails because our server is not available. The function should return `true` if it
   * completely handle the situation, `false` otherwise. If the situation is being handled by the implementation you
   * should call `ShiftPlatform.defaultManager().runPendingNetworkRequests()` to rerun the failing requests.
   *
   * If `false` is returned a UI blocking error message will be shown with a retry call to action. This is the default
   * behaviour in case the method is not implemented.
   */
  @objc optional func serverMaintenanceError() -> Bool

  /**
   * This method is called when a network request fails because the current SDK version has been deprecated. To know
   * the version of the SDK use `ShiftSDK.version`.
   */
  @objc func sdkDeprecated()
}

@objc public enum ShiftPlatformEnvironment: Int {
  case local
  case development
  case staging
  case sandbox
  case production
}

public enum HandleFileResult {
  case noPendingApplications
  case success
  case userCancelled
  case unsupportedFileFormat
  case undefinedUserToken
}

@objc public class ShiftPlatform: NSObject {

  // MARK: Authentication attributes

  // swiftlint:disable implicitly_unwrapped_optional
  public private(set) var developerKey: String!
  public private(set) var projectKey: String!
  public private(set) var environment: ShiftPlatformEnvironment!
  public private(set) var initialized = false
  // swiftlint:enable implicitly_unwrapped_optional

  // MARK: Delegate

  public weak var delegate: ShiftPlatformDelegate?

  // MARK: Transport

  var transportEnvironment: JSONTransportEnvironment! // swiftlint:disable:this implicitly_unwrapped_optional

  // MARK: Storage

  // swiftlint:disable implicitly_unwrapped_optional
  var userStorage: UserStorageProtocol!
  var offersStorage: OffersStorageProtocol!
  var configurationStorage: ConfigurationStorageProtocol!
  var loanApplicationsStorage: LoanApplicationsStorageProtocol!
  var cardApplicationsStorage: CardApplicationsStorageProtocol!
  var storeStorage: StoreStorageProtocol!
  var financialAccountsStorage: FinancialAccountsStorageProtocol!
  var pushTokenStorage: PushTokenStorageProtocol!
  var oauthStorage: OauthStorageProtocol!
  // swiftlint:enable implicitly_unwrapped_optional
  fileprivate lazy var userTokenStorage = serviceLocator.storageLocator.userTokenStorage()
  fileprivate lazy var linkFileStorage = serviceLocator.storageLocator.linkFileStorage()
  fileprivate let pushNotificationsManager = PushNotificationsManager()
  private lazy var serviceLocator = ServiceLocator.shared

  deinit {
    self.removeNetworkChangesNotificationObservers()
  }

  // MARK: Setup Manager

  @objc public static func defaultManager() -> ShiftPlatform {
    guard let sharedManager = ShiftPlatform.sharedManager else {
      ShiftPlatform.sharedManager = ShiftPlatform()
      return ShiftPlatform.sharedManager! // swiftlint:disable:this force_unwrapping
    }
    return sharedManager
  }

  @objc public func initializeWithDeveloperKey(_ developerKey: String,
                                               projectKey: String,
                                               environment: ShiftPlatformEnvironment,
                                               setupCertPinning: Bool) {
    let certPinningConfig: [String: [String: AnyObject]]? = nil
    self.developerKey = developerKey
    self.projectKey = projectKey
    self.environment = environment
    var allowSelfSignedCertificate = false
    switch environment {
    case .local:
      self.transportEnvironment = .local
      allowSelfSignedCertificate = true
    case .development:
      self.transportEnvironment = .development
      allowSelfSignedCertificate = true
    case .staging:
      self.transportEnvironment = .staging
    case .sandbox:
      self.transportEnvironment = .sandbox
    case .production:
      self.transportEnvironment = .live
    }
    let transport = serviceLocator.networkLocator.jsonTransport(environment: transportEnvironment,
                                                                baseUrlProvider: transportEnvironment,
                                                                certPinningConfig: certPinningConfig,
                                                                allowSelfSignedCertificate: allowSelfSignedCertificate)
    self.userStorage = serviceLocator.storageLocator.userStorage(transport: transport)
    self.offersStorage = serviceLocator.storageLocator.offersStorage(transport: transport)
    self.configurationStorage = serviceLocator.storageLocator.configurationStorage(transport: transport)
    self.loanApplicationsStorage = serviceLocator.storageLocator.loanApplicationStorage(transport: transport)
    self.cardApplicationsStorage = serviceLocator.storageLocator.cardApplicationsStorage(transport: transport)
    self.storeStorage = serviceLocator.storageLocator.storeStorage(transport: transport)
    self.financialAccountsStorage = serviceLocator.storageLocator.financialAccountsStorage(transport: transport)
    self.pushTokenStorage = serviceLocator.storageLocator.pushTokenStorage(transport: transport)
    self.oauthStorage = serviceLocator.storageLocator.oauthStorage(transport: transport)

    // Notify the delegate that the manager has already been initialized
    self.initialized = true
    self.delegate?.shiftSDKInitialized(developerKey: developerKey,
                                       projectKey: projectKey)

    // Configure reachability notification observers
    self.setUpNetworkChangesNotificationObservers()
  }

  @objc public func initializeWithDeveloperKey(_ developerKey: String, projectKey: String) {
    self.initializeWithDeveloperKey(developerKey, projectKey: projectKey, environment: .sandbox)
  }

  @objc public func initializeWithDeveloperKey(_ developerKey: String,
                                               projectKey: String,
                                               environment: ShiftPlatformEnvironment) {
    self.initializeWithDeveloperKey(developerKey,
                                    projectKey: projectKey,
                                    environment: environment,
                                    setupCertPinning: false)
  }

  public func currentToken() -> AccessToken? {
    guard let token = self.userTokenStorage.currentToken() else {
      return nil
    }
    var primaryCredential: DataPointType = .phoneNumber
    var secondaryCredential: DataPointType = .email
    if let credential = self.userTokenStorage.currentTokenPrimaryCredential() {
      primaryCredential = credential
    }
    if let credential = self.userTokenStorage.currentTokenSecondaryCredential() {
      secondaryCredential = credential
    }
    return AccessToken(token: token, primaryCredential: primaryCredential, secondaryCredential: secondaryCredential)
  }

  public func currentPushToken() -> String? {
    return self.pushTokenStorage.currentPushToken()
  }

  public func validateStoreWith(_ projectKey: String,
                                partnerKey: String,
                                merchantKey: String,
                                storeKey: String,
                                callback: @escaping Result<Store?, NSError>.Callback) {
    guard let accessToken = self.developerKey, let projectKey = self.projectKey else {
      let error = BackendError(code: .invalidSession, reason: nil)
      callback(.failure(error))
      return
    }
    self.storeStorage.validateStoreKey(accessToken,
                                       projectKey: projectKey,
                                       partnerKey: partnerKey,
                                       merchantKey: merchantKey,
                                       storeKey: storeKey,
                                       callback: callback)
  }

  @objc public func clearUserToken() {
    self.unregisterPushTokenIfNeeded()
    self.userTokenStorage.clearCurrentToken()
    delegate?.newUserTokenReceived(nil)
  }

  public func createUser(userData: DataPointList,
                         callback: @escaping Result<ShiftUser, NSError>.Callback) {

    guard let developerKey = self.developerKey, let projectKey = self.projectKey else {
      let error = BackendError(code: .invalidSession, reason: nil)
      callback(.failure(error))
      return
    }

    self.userStorage.createUser(developerKey,
                                projectKey: projectKey,
                                userData: userData) { result in
      switch result {
      case .failure(let error): callback(.failure(error))
      case .success(let user):
        self.configurationStorage.contextConfiguration(developerKey,
                                                       projectKey: projectKey) { result in
          switch result {
          case .failure(let error): callback(.failure(error))
          case .success(let contextConfiguration):
            let token = user.accessToken! // swiftlint:disable:this force_unwrapping
            let projectConfiguration = contextConfiguration.projectConfiguration
            self.userTokenStorage.setCurrent(token: token.token,
                                             withPrimaryCredential: projectConfiguration.primaryAuthCredential,
                                             andSecondaryCredential: projectConfiguration.secondaryAuthCredential)
            self.notifyPushTokenIfNeeded()
            callback(.success(user))
            self.delegate?.newUserTokenReceived(token.token)
          }
        }
      }
    }
  }

  public func loginUserWith(verifications: [Verification],
                            callback: @escaping Result<ShiftUser, NSError>.Callback) {

    guard let developerKey = self.developerKey, let projectKey = self.projectKey else {
      let error = BackendError(code: .invalidSession, reason: nil)
      callback(.failure(error))
      return
    }

    self.userStorage?.loginWith(developerKey, projectKey: projectKey, verifications: verifications) { result in
      switch result {
      case .failure(let error): callback(.failure(error))
      case .success(let user):
        self.configurationStorage.contextConfiguration(developerKey, projectKey: projectKey) { result in
          switch result {
          case .failure(let error): callback(.failure(error))
          case .success(let contextConfiguration):
            let token = user.accessToken! // swiftlint:disable:this force_unwrapping
            let projectConfiguration = contextConfiguration.projectConfiguration
            self.userTokenStorage.setCurrent(token: token.token,
                                             withPrimaryCredential: projectConfiguration.primaryAuthCredential,
                                             andSecondaryCredential: projectConfiguration.secondaryAuthCredential)
            self.notifyPushTokenIfNeeded()
            callback(.success(user))
            self.delegate?.newUserTokenReceived(token.token)
          }
        }
      }
    }
  }

  public func contextConfiguration(_ forceRefresh: Bool = false,
                                   callback: @escaping Result<ContextConfiguration, NSError>.Callback) {
    guard let accessToken = self.developerKey, let projectKey = self.projectKey else {
      let error = BackendError(code: .invalidSession, reason: nil)
      callback(.failure(error))
      return
    }
    self.configurationStorage.contextConfiguration(accessToken,
                                                   projectKey: projectKey,
                                                   forceRefresh: forceRefresh,
                                                   callback: callback)
  }

  public func bankOauthConfiguration(_ accessToken: AccessToken,
                                     forceRefresh: Bool = false,
                                     callback: @escaping Result<BankOauthConfiguration, NSError>.Callback) {
    guard let developerKey = self.developerKey, let projectKey = self.projectKey else {
      let error = BackendError(code: .invalidSession, reason: nil)
      callback(.failure(error))
      return
    }
    self.configurationStorage.bankOauthConfiguration(developerKey,
                                                     projectKey: projectKey,
                                                     userToken: accessToken.token,
                                                     forceRefresh: forceRefresh,
                                                     callback: callback)
  }

  func currentUserInfo(_ accessToken: AccessToken,
                       filterInvalidTokenResult: Bool = true,
                       callback: @escaping Result<ShiftUser, NSError>.Callback) {
    guard let developerKey = self.developerKey, let projectKey = self.projectKey else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }
    self.contextConfiguration { result in
      switch result {
      case .failure(let error):
        callback(.failure(error))
      case .success(let contextConfiguration):
        let projectConfiguration = contextConfiguration.projectConfiguration
        self.userStorage.getUserData(developerKey,
                                     projectKey: projectKey,
                                     userToken: accessToken.token,
                                     availableHousingTypes: projectConfiguration.housingTypes,
                                     availableIncomeTypes: projectConfiguration.incomeTypes,
                                     availableSalaryFrequencies: projectConfiguration.salaryFrequencies,
                                     filterInvalidTokenResult: filterInvalidTokenResult) { result in
          switch result {
          case .failure(let error):
            if let backendError = error as? BackendError {
              if backendError.invalidSessionError() || backendError.sessionExpiredError() {
                self.clearUserToken()
                callback(.failure(error))
                return
              }
            }
            callback(.failure(error))
          case .success(let user):
            self.notifyPushTokenIfNeeded()
            callback(.success(user))
          }
        }
      }
    }
  }

  func updateUserInfo(_ accessToken: AccessToken,
                      userData: DataPointList,
                      callback: @escaping Result<ShiftUser, NSError>.Callback) {
    guard let developerId = self.developerKey, let projectKey = self.projectKey else {
      let error = BackendError(code: .invalidSession, reason: nil)
      callback(.failure(error))
      return
    }
    self.userStorage.updateUserData(developerId,
                                    projectKey: projectKey,
                                    userToken: accessToken.token,
                                    userData: userData,
                                    callback: callback)
  }

  func getPlaidURL(_ callback: Result<URL, NSError>.Callback) {
    guard let url = URL(string: ShiftPlatform.defaultManager().transportEnvironment.docsBaseUrl() + "/bankoauth") else {
      callback(.failure(ServiceError(code: .internalIncosistencyError)))
      return
    }
    callback(.success(url))
  }

  func startPhoneVerification(_ phone: PhoneNumber,
                              callback: @escaping Result<Verification, NSError>.Callback) {
    guard let accessToken = self.developerKey, let projectKey = self.projectKey else {
      let error = BackendError(code: .invalidSession, reason: nil)
      callback(.failure(error))
      return
    }
    self.userStorage.startPhoneVerification(accessToken, projectKey: projectKey, phone: phone, callback: callback)
  }

  func startEmailVerification(_ email: Email,
                              callback: @escaping Result<Verification, NSError>.Callback) {
    guard let accessToken = self.developerKey, let projectKey = self.projectKey else {
      let error = BackendError(code: .invalidSession, reason: nil)
      callback(.failure(error))
      return
    }
    self.userStorage.startEmailVerification(accessToken, projectKey: projectKey, email: email, callback: callback)
  }

  func startBirthDateVerification(_ birthDate: BirthDate,
                                  callback: @escaping Result<Verification, NSError>.Callback) {
    guard let accessToken = self.developerKey, let projectKey = self.projectKey else {
      let error = BackendError(code: .invalidSession, reason: nil)
      callback(.failure(error))
      return
    }
    self.userStorage.startBirthDateVerification(accessToken,
                                                projectKey: projectKey,
                                                birthDate: birthDate,
                                                callback: callback)
  }

  func startDocumentVerification(_ accessToken: AccessToken,
                                 documentImages: [UIImage],
                                 selfie: UIImage?,
                                 livenessData: [String: AnyObject]?,
                                 associatedTo workflowObject: WorkflowObject?,
                                 callback: @escaping Result<Verification, NSError>.Callback) {
    guard let developerKey = self.developerKey, let projectKey = self.projectKey else {
      let error = BackendError(code: .invalidSession, reason: nil)
      callback(.failure(error))
      return
    }
    self.userStorage.startDocumentVerification(developerKey,
                                               projectKey: projectKey,
                                               userToken: accessToken.token,
                                               documentImages: documentImages,
                                               selfie: selfie,
                                               livenessData: livenessData,
                                               associatedTo: workflowObject,
                                               callback: callback)
  }

  func documentVerificationStatus(_ verification: Verification,
                                  callback: @escaping Result<Verification, NSError>.Callback) {
    guard let accessToken = self.developerKey, let projectKey = self.projectKey else {
      let error = BackendError(code: .invalidSession, reason: nil)
      callback(.failure(error))
      return
    }
    self.userStorage.documentVerificationStatus(accessToken,
                                                projectKey: projectKey,
                                                verificationId: verification.verificationId,
                                                 callback: callback)
  }

  func restartVerification(_ verification: Verification,
                           callback: @escaping Result<Verification, NSError>.Callback) {
    guard let accessToken = self.developerKey, let projectKey = self.projectKey else {
      let error = BackendError(code: .invalidSession, reason: nil)
      callback(.failure(error))
      return
    }
    self.userStorage.restartVerification(accessToken,
                                         projectKey: projectKey,
                                         verificationId: verification.verificationId,
                                         callback: callback)
  }

  func addBankAccounts(_ userToken: AccessToken,
                       publicToken: String,
                       callback: @escaping Result<[BankAccount], NSError>.Callback) {
    guard let accessToken = self.developerKey, let projectKey = self.projectKey else {
      let error = BackendError(code: .invalidSession, reason: nil)
      callback(.failure(error))
      return
    }
    self.financialAccountsStorage.addBankAccounts(userToken: userToken.token,
                                                  developerKey: accessToken,
                                                  projectKey: projectKey,
                                                  publicToken: publicToken,
                                                  callback: callback)
  }

  func completeVerification(_ verification: Verification,
                            callback:@escaping Result<Verification, NSError>.Callback) {
    guard let accessToken = self.developerKey, let projectKey = self.projectKey else {
      let error = BackendError(code: .invalidSession, reason: nil)
      callback(.failure(error))
      return
    }
    self.userStorage.completeVerification(accessToken,
                                          projectKey: projectKey,
                                          verificationId: verification.verificationId,
                                          secret: verification.secret,
                                          callback: callback)
  }

  func verificationStatus(_ verification: Verification,
                          callback: @escaping Result<Verification, NSError>.Callback) {
    guard let accessToken = self.developerKey, let projectKey = self.projectKey else {
      let error = BackendError(code: .invalidSession, reason: nil)
      callback(.failure(error))
      return
    }
    self.userStorage.verificationStatus(accessToken,
                                        projectKey: projectKey,
                                        verificationId: verification.verificationId,
                                        callback: callback)
  }

  func nextFinancialAccounts(_ accessToken: AccessToken,
                             page: Int,
                             rows: Int,
                             callback: @escaping Result<[FinancialAccount], NSError>.Callback) {
    guard let developerKey = self.developerKey, let projectKey = self.projectKey else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }
    self.financialAccountsStorage.getFinancialAccounts(developerKey,
                                                       projectKey: projectKey,
                                                       userToken: accessToken.token,
                                                       callback: callback)
  }

  func next(financialAccountsOfType: FinancialAccountType,
            accessToken: AccessToken,
            page: Int,
            rows: Int,
            callback: @escaping Result<[FinancialAccount], NSError>.Callback) {
    guard let developerKey = self.developerKey, let projectKey = self.projectKey else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }
    self.financialAccountsStorage.get(financialAccountsOfType: financialAccountsOfType,
                                      developerKey: developerKey,
                                      projectKey: projectKey,
                                      userToken: accessToken.token,
                                      callback: callback)
  }

  func getFinancialAccount(_ accessToken: AccessToken,
                           accountId: String,
                           retrieveBalance: Bool = true,
                           callback: @escaping Result<FinancialAccount, NSError>.Callback) {
    guard let developerKey = self.developerKey, let projectKey = self.projectKey else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }
    self.financialAccountsStorage.getFinancialAccount(developerKey,
                                                      projectKey: projectKey,
                                                      userToken: accessToken.token,
                                                      accountId: accountId,
                                                      retrieveBalance: retrieveBalance,
                                                      callback: callback)
  }

  func addCard(_ accessToken: AccessToken,
               cardNumber: String,
               cardNetwork: CardNetwork,
               expirationMonth: UInt,
               expirationYear: UInt,
               cvv: String,
               callback: @escaping Result<Card, NSError>.Callback) {
    guard let developerKey = self.developerKey, let projectKey = self.projectKey else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }

    self.financialAccountsStorage.addCard(developerKey,
                                          projectKey: projectKey,
                                          userToken: accessToken.token,
                                          cardNumber: cardNumber,
                                          cardNetwork: cardNetwork,
                                          expirationYear: expirationYear,
                                          expirationMonth: expirationMonth,
                                          cvv: cvv,
                                          callback: callback)
  }

  public func authorisationHeaders(_ result: Result<[String: String]?, NSError>.Callback) {
    guard let developerKey = self.developerKey, let projectKey = self.projectKey else {
      result(.success(nil))
      return
    }
    guard let accessToken = self.currentToken() else {
      result(.success(["Developer-Authorization: Bearer": developerKey, "Project: Bearer": projectKey]))
      return
    }
    result(.success(["Developer-Authorization: Bearer": developerKey,
                     "Project: Bearer": projectKey,
                     "Authorization: Bearer": accessToken.token]))
  }

  public func runPendingNetworkRequests() {
    serviceLocator.networkLocator.networkManager().runPendingRequests()
  }

  // MARK: Private Attributes

  fileprivate static var sharedManager: ShiftPlatform?

  private func setUpNetworkChangesNotificationObservers() {
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(self.didRestoreNetworkConnection),
                                           name: .NetworkReachableNotification,
                                           object: nil)
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(self.didLoseNetworkConnection),
                                           name: .NetworkNotReachableNotification,
                                           object: nil)
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(self.didLoseConnectionToServer),
                                           name: .ServerMaintenanceNotification,
                                           object: nil)
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(self.sdkDeprecated),
                                           name: .SDKDeprecatedNotification,
                                           object: nil)
  }

  private func removeNetworkChangesNotificationObservers() {
    NotificationCenter.default.removeObserver(self, name: .NetworkReachableNotification, object: nil)
    NotificationCenter.default.removeObserver(self, name: .NetworkNotReachableNotification, object: nil)
    NotificationCenter.default.removeObserver(self, name: .ServerMaintenanceNotification, object: nil)
  }

  private var shouldHandleNetworkRestore = false
  @objc private func didRestoreNetworkConnection() {
    if let callback = delegate?.networkConnectionRestored {
      callback()
    }
    if shouldHandleNetworkRestore {
      dismissNetworkNotReachableError()
    }
    shouldHandleNetworkRestore = false
  }

  @objc private func didLoseNetworkConnection() {
    if let errorHandled = delegate?.networkConnectionError?() {
      shouldHandleNetworkRestore = !errorHandled
      if !errorHandled {
        presentNetworkNotReachableError()
      }
    }
    else {
      presentNetworkNotReachableError()
      shouldHandleNetworkRestore = true
    }
  }

  @objc private func didLoseConnectionToServer() {
    if let errorHandled = delegate?.serverMaintenanceError?() {
      if !errorHandled {
        presentServerMaintenanceError()
      }
    }
    else {
      presentServerMaintenanceError()
    }
  }

  @objc private func sdkDeprecated() {
    delegate?.sdkDeprecated()
  }

  // TODO: Extract to a component that handle the errors
  private func presentNetworkNotReachableError() {
    var uiConfig: ShiftUIConfig? = nil
    if let contextConfiguration = configurationStorage.contextConfigurationCache {
      uiConfig = ShiftUIConfig(projectConfiguration: contextConfiguration.projectConfiguration)
    }
    UIApplication.topViewController()?.showNetworkNotReachableError(uiConfig)
  }

  private func dismissNetworkNotReachableError() {
    UIApplication.topViewController()?.hideNetworkNotReachableError()
  }

  private func presentServerMaintenanceError() {
    var uiConfig: ShiftUIConfig? = nil
    if let contextConfiguration = configurationStorage.contextConfigurationCache {
      uiConfig = ShiftUIConfig(projectConfiguration: contextConfiguration.projectConfiguration)
    }
    UIApplication.topViewController()?.showServerMaintenanceError(uiConfig)
  }
}

// MARK: - Push Notifications management

extension ShiftPlatform {

  public func initializePushNotifications() {
    self.pushNotificationsManager.registerForPushNotifications()
  }

  public func handle(launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
    if let notification = launchOptions?[.remoteNotification] as? [String: AnyObject] {
      self.didReceiveRemoteNotificationWith(userInfo: notification) { _ in }
    }
  }

  public func didReceiveRemoteNotification(userInfo: [AnyHashable: Any],
                                           completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    pushNotificationsManager.didReceiveRemoteNotificationWith(userInfo: userInfo, completionHandler: completionHandler)
  }

  public func didRegisterForRemoteNotificationsWithDeviceToken(deviceToken: Data) {
    let pushToken = self.pushNotificationsManager.newPushTokenReceived(deviceToken: deviceToken)
    self.pushTokenStorage.setCurrent(pushToken: pushToken)
    self.notifyPushTokenIfNeeded()
  }

  public func didFailToRegisterForRemoteNotificationsWithError(error: Error) {
    self.pushNotificationsManager.didFailToRegisterForRemoteNotificationsWithError(error: error)
  }

  public func didReceiveRemoteNotificationWith(userInfo: [AnyHashable: Any],
                                               completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    pushNotificationsManager.didReceiveRemoteNotificationWith(userInfo: userInfo, completionHandler: completionHandler)
  }

  func notifyPushTokenIfNeeded() {
    if let accessToken = self.currentToken(), let pushToken = self.currentPushToken() {
      self.pushTokenStorage.registerPushToken(developerKey,
                                              projectKey: projectKey,
                                              userToken: accessToken.token,
                                              pushToken: pushToken) { _ in }
    }
  }

  func unregisterPushTokenIfNeeded() {
    if let accessToken = self.currentToken(), let pushToken = self.currentPushToken() {
      self.pushTokenStorage.unregisterPushToken(developerKey,
                                                projectKey: projectKey,
                                                userToken: accessToken.token,
                                                pushToken: pushToken) { _ in }
    }
  }

  func startOauthAuthentication(_ accessToken: AccessToken,
                                custodianType: CustodianType,
                                callback: @escaping Result<OauthAttempt, NSError>.Callback) {
    guard let developerKey = self.developerKey, let projectKey = self.projectKey else  {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }
    oauthStorage.startOauthAuthentication(developerKey,
                                          projectKey: projectKey,
                                          userToken: accessToken.token,
                                          custodianType: custodianType,
                                          callback: callback)
  }

  func verifyOauthAttemptStatus(_ accessToken: AccessToken,
                                attempt: OauthAttempt,
                                custodianType: CustodianType,
                                callback: @escaping Result<Custodian, NSError>.Callback) {
    guard let developerKey = self.developerKey, let projectKey = self.projectKey else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }
    oauthStorage.waitForOauthAuthenticationConfirmation(developerKey,
                                                        projectKey: projectKey,
                                                        userToken: accessToken.token,
                                                        attempt: attempt,
                                                        custodianType: custodianType,
                                                        callback: callback)
  }
}
