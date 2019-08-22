//
//  AptoPlatform.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 18/01/16.
//  Copyright © 2019 Apto Payments. All rights reserved.
//

import Foundation
import TrustKit

@objc public enum AptoPlatformEnvironment: Int {
  case local
  case development
  case staging
  case sandbox
  case production
  public var description: String {
    switch self {
    case .local: return "local"
    case .development: return "development"
    case .staging: return "staging"
    case .sandbox: return "local"
    case .production: return "production"
    }
  }
}

@objc public class AptoPlatform: NSObject, AptoPlatformProtocol {

  // MARK: Authentication attributes

  // swiftlint:disable implicitly_unwrapped_optional
  public private(set) var apiKey: String!
  public private(set) var environment: AptoPlatformEnvironment!
  public private(set) var initialized = false
  // swiftlint:enable implicitly_unwrapped_optional
  private var internalCurrentUser: ShiftUser?

  // MARK: Delegate

  public weak var delegate: AptoPlatformDelegate?

  // MARK: Transport

  private var transportEnvironment: JSONTransportEnvironment! // swiftlint:disable:this implicitly_unwrapped_optional

  // MARK: Storage

  // swiftlint:disable implicitly_unwrapped_optional
  private var userStorage: UserStorageProtocol!
  private var configurationStorage: ConfigurationStorageProtocol!
  private var cardApplicationsStorage: CardApplicationsStorageProtocol!
  private var financialAccountsStorage: FinancialAccountsStorageProtocol!
  private var pushTokenStorage: PushTokenStorageProtocol!
  private var oauthStorage: OauthStorageProtocol!
  private var notificationPreferencesStorage: NotificationPreferencesStorageProtocol!
  private var voIPStorage: VoIPStorageProtocol!
  // swiftlint:enable implicitly_unwrapped_optional
  private lazy var featuresStorage = serviceLocator.storageLocator.featuresStorage()
  private lazy var userPreferencesStorage = serviceLocator.storageLocator.userPreferencesStorage()
  private lazy var userTokenStorage = serviceLocator.storageLocator.userTokenStorage()
  private let pushNotificationsManager = PushNotificationsManager()
  private lazy var serviceLocator: ServiceLocatorProtocol = ServiceLocator.shared

  init(serviceLocator: ServiceLocatorProtocol = ServiceLocator.shared) {
    super.init()
    self.serviceLocator = serviceLocator
  }

  deinit {
    self.removeNotificationObservers()
  }

  // MARK: Setup Manager

  private static var sharedManager = AptoPlatform()
  @objc public static func defaultManager() -> AptoPlatform {
    return sharedManager
  }

  @objc public func initializeWithApiKey(_ apiKey: String,
                                         environment: AptoPlatformEnvironment,
                                         setupCertPinning: Bool) {
    let certPinningConfig: [String: [String: AnyObject]]? = nil
    self.apiKey = apiKey
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
    let storageLocator = serviceLocator.storageLocator
    self.userStorage = storageLocator.userStorage(transport: transport)
    self.configurationStorage = storageLocator.configurationStorage(transport: transport)
    self.cardApplicationsStorage = storageLocator.cardApplicationsStorage(transport: transport)
    self.financialAccountsStorage = storageLocator.financialAccountsStorage(transport: transport)
    self.pushTokenStorage = storageLocator.pushTokenStorage(transport: transport)
    self.oauthStorage = storageLocator.oauthStorage(transport: transport)
    self.notificationPreferencesStorage = storageLocator.notificationPreferencesStorage(transport: transport)
    self.voIPStorage = storageLocator.voIPStorage(transport: transport)

    // Notify the delegate that the manager has already been initialized
    self.initialized = true
    self.delegate?.sdkInitialized(apiKey: apiKey)

    // Configure reachability notification observers
    self.setUpNotificationObservers()
  }

  @objc public func initializeWithApiKey(_ apiKey: String, environment: AptoPlatformEnvironment) {
    self.initializeWithApiKey(apiKey, environment: environment, setupCertPinning: false)
  }

  @objc public func initializeWithApiKey(_ apiKey: String) {
    self.initializeWithApiKey(apiKey, environment: .production)
  }

  public func setUserToken(_ userToken: String) {
    let primaryCredential: DataPointType = userTokenStorage.currentTokenPrimaryCredential() ?? .phoneNumber
    let secondaryCredential: DataPointType = userTokenStorage.currentTokenSecondaryCredential() ?? .email
    userTokenStorage.setCurrent(token: userToken, withPrimaryCredential: primaryCredential,
                                andSecondaryCredential: secondaryCredential)
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

  public func setCardOptions(_ cardOptions: CardOptions? = nil) {
    configurationStorage.cardOptions = cardOptions
    if let features = cardOptions?.features {
      featuresStorage.update(features: features)
    }
  }

  public func currentPushToken() -> String? {
    return self.pushTokenStorage.currentPushToken()
  }

  public func logout() {
    NotificationCenter.default.post(Notification(name: .UserTokenSessionClosedNotification,
                                                 object: nil,
                                                 userInfo: nil))
    clearUserToken()
  }

  @objc public func clearUserToken() {
    internalCurrentUser = nil
    try? serviceLocator.storageLocator.authenticatedLocalFileManager().invalidate()
    unregisterPushTokenIfNeeded()
    userTokenStorage.clearCurrentToken()
    delegate?.newUserTokenReceived(nil)
    serviceLocator.analyticsManager.logoutUser()
  }

  public func createUser(userData: DataPointList, custodianUid: String? = nil,
                         callback: @escaping Result<ShiftUser, NSError>.Callback) {
    guard let apiKey = self.apiKey else {
      let error = BackendError(code: .invalidSession, reason: nil)
      callback(.failure(error))
      return
    }

    userStorage.createUser(apiKey, userData: userData, custodianUid: custodianUid) { [weak self] result in
      guard let self = self else { return }
      switch result {
      case .failure(let error): callback(.failure(error))
      case .success(let user):
        self.configurationStorage.contextConfiguration(apiKey) { [weak self] result in
          guard let self = self else { return }
          switch result {
          case .failure(let error): callback(.failure(error))
          case .success(let contextConfiguration):
            let token = user.accessToken! // swiftlint:disable:this force_unwrapping
            self.serviceLocator.analyticsManager.createUser(userId: user.userId)
            let projectConfiguration = contextConfiguration.projectConfiguration
            self.userTokenStorage.setCurrent(token: token.token,
                                             withPrimaryCredential: projectConfiguration.primaryAuthCredential,
                                             andSecondaryCredential: projectConfiguration.secondaryAuthCredential)
            self.notifyPushTokenIfNeeded()
            self.internalCurrentUser = user
            callback(.success(user))
            self.delegate?.newUserTokenReceived(token.token)
          }
        }
      }
    }
  }

  public func loginUserWith(verifications: [Verification], callback: @escaping Result<ShiftUser, NSError>.Callback) {
    guard let apiKey = self.apiKey else {
      let error = BackendError(code: .invalidSession, reason: nil)
      callback(.failure(error))
      return
    }

    userStorage.loginWith(apiKey, verifications: verifications) { [weak self] result in
      guard let self = self else { return }
      switch result {
      case .failure(let error): callback(.failure(error))
      case .success(let user):
        self.fetchContextConfiguration { [weak self] result in
          guard let self = self else { return }
          switch result {
          case .failure(let error):
            callback(.failure(error))
          case .success(let contextConfiguration):
            let token = user.accessToken! // swiftlint:disable:this force_unwrapping
            self.serviceLocator.analyticsManager.loginUser(userId: user.userId)
            let projectConfiguration = contextConfiguration.projectConfiguration
            self.userTokenStorage.setCurrent(token: token.token,
                                             withPrimaryCredential: projectConfiguration.primaryAuthCredential,
                                             andSecondaryCredential: projectConfiguration.secondaryAuthCredential)
            self.notifyPushTokenIfNeeded()
            self.internalCurrentUser = user
            callback(.success(user))
            self.delegate?.newUserTokenReceived(token.token)
          }
        }
      }
    }
  }

  public func fetchContextConfiguration(_ forceRefresh: Bool = false,
                                        callback: @escaping Result<ContextConfiguration, NSError>.Callback) {
    guard let apiKey = self.apiKey else {
      let error = BackendError(code: .invalidSession, reason: nil)
      callback(.failure(error))
      return
    }
    configurationStorage.contextConfiguration(apiKey, forceRefresh: forceRefresh) { [weak self] result in
      callback(result)
      if let contextConfiguration = result.value {
        // Check if the primary and secondary credentials are the same used to retrieve the current user's token. If
        // they're not, invalidate that token
        let token = self?.currentToken()
        if let primaryCredential = token?.primaryCredential, let secondaryCredential = token?.secondaryCredential {
          if (contextConfiguration.projectConfiguration.primaryAuthCredential != primaryCredential)
               || (contextConfiguration.projectConfiguration.secondaryAuthCredential != secondaryCredential) {
            self?.clearUserToken()
          }
        }
        if contextConfiguration.projectConfiguration.isTrackerActive == true {
          if let trackerAccessToken = contextConfiguration.projectConfiguration.trackerAccessToken {
            self?.serviceLocator.analyticsManager.initialize(accessToken: trackerAccessToken)
          }
        }
      }
    }
  }

  public func fetchUIConfig() -> UIConfig? {
    return configurationStorage.uiConfig()
  }

  public func isFeatureEnabled(_ featureKey: FeatureKey) -> Bool {
    return featuresStorage.isFeatureEnabled(featureKey)
  }

  public func isShowDetailedCardActivityEnabled() -> Bool {
    return userPreferencesStorage.shouldShowDetailedCardActivity
  }

  public func setShowDetailedCardActivityEnabled(_ isEnabled: Bool) {
    userPreferencesStorage.shouldShowDetailedCardActivity = isEnabled
  }

  public func fetchCardProducts(callback: @escaping Result<[CardProductSummary], NSError>.Callback) {
    guard let apiKey = self.apiKey, let accessToken = currentToken() else {
      return callback(.failure(BackendError(code: .invalidSession)))
    }
    configurationStorage.cardProducts(apiKey, userToken: accessToken.token, callback: callback)
  }

  public func fetchCurrentUserInfo(forceRefresh: Bool, filterInvalidTokenResult: Bool,
                                   callback: @escaping Result<ShiftUser, NSError>.Callback) {
    guard let apiKey = self.apiKey, let accessToken = currentToken() else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }
    if forceRefresh == false, let user = internalCurrentUser {
      callback(.success(user))
      return
    }
    fetchContextConfiguration { [weak self] result in
      guard let self = self else { return }
      switch result {
      case .failure(let error):
        callback(.failure(error))
      case .success(let contextConfiguration):
        let projectConfiguration = contextConfiguration.projectConfiguration
        self.userStorage.getUserData(apiKey,
                                     userToken: accessToken.token,
                                     availableHousingTypes: projectConfiguration.housingTypes,
                                     availableIncomeTypes: projectConfiguration.incomeTypes,
                                     availableSalaryFrequencies: projectConfiguration.salaryFrequencies,
                                     filterInvalidTokenResult: filterInvalidTokenResult) { [weak self] result in
          guard let self = self else { return }
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

  public func updateUserInfo(_ userData: DataPointList, callback: @escaping Result<ShiftUser, NSError>.Callback) {
    guard let apiKey = self.apiKey, let accessToken = currentToken() else {
      let error = BackendError(code: .invalidSession, reason: nil)
      callback(.failure(error))
      return
    }
    if userData.dataPoints.isEmpty {
      fetchCurrentUserInfo(forceRefresh: false, filterInvalidTokenResult: true, callback: callback)
      return
    }
    userStorage.updateUserData(apiKey, userToken: accessToken.token, userData: userData) { [weak self] result in
      switch result {
      case .failure(let error):
        callback(.failure(error))
      case .success(let user):
        self?.internalCurrentUser = user
        callback(.success(user))
      }
    }
  }

  public func startPhoneVerification(_ phone: PhoneNumber, callback: @escaping Result<Verification, NSError>.Callback) {
    guard let apiKey = self.apiKey else {
      let error = BackendError(code: .invalidSession, reason: nil)
      callback(.failure(error))
      return
    }
    userStorage.startPhoneVerification(apiKey, phone: phone, callback: callback)
  }

  public func startEmailVerification(_ email: Email, callback: @escaping Result<Verification, NSError>.Callback) {
    guard let apiKey = self.apiKey else {
      let error = BackendError(code: .invalidSession, reason: nil)
      callback(.failure(error))
      return
    }
    userStorage.startEmailVerification(apiKey, email: email, callback: callback)
  }

  public func startBirthDateVerification(_ birthDate: BirthDate,
                                         callback: @escaping Result<Verification, NSError>.Callback) {
    guard let apiKey = self.apiKey else {
      let error = BackendError(code: .invalidSession, reason: nil)
      callback(.failure(error))
      return
    }
    userStorage.startBirthDateVerification(apiKey, birthDate: birthDate, callback: callback)
  }

  public func startDocumentVerification(documentImages: [UIImage], selfie: UIImage?, livenessData: [String: AnyObject]?,
                                        associatedTo workflowObject: WorkflowObject?,
                                        callback: @escaping Result<Verification, NSError>.Callback) {
    guard let apiKey = self.apiKey, let accessToken = currentToken() else {
      let error = BackendError(code: .invalidSession, reason: nil)
      callback(.failure(error))
      return
    }
    userStorage.startDocumentVerification(apiKey, userToken: accessToken.token, documentImages: documentImages,
                                          selfie: selfie, livenessData: livenessData, associatedTo: workflowObject,
                                          callback: callback)
  }

  public func fetchDocumentVerificationStatus(_ verification: Verification,
                                              callback: @escaping Result<Verification, NSError>.Callback) {
    guard let apiKey = self.apiKey else {
      let error = BackendError(code: .invalidSession, reason: nil)
      callback(.failure(error))
      return
    }
    userStorage.documentVerificationStatus(apiKey, verificationId: verification.verificationId, callback: callback)
  }

  public func restartVerification(_ verification: Verification,
                                  callback: @escaping Result<Verification, NSError>.Callback) {
    guard let apiKey = self.apiKey else {
      let error = BackendError(code: .invalidSession, reason: nil)
      callback(.failure(error))
      return
    }
    userStorage.restartVerification(apiKey, verificationId: verification.verificationId, callback: callback)
  }

  // TODO: Review the whole BankAccount functionality
  func addBankAccounts(_ publicToken: String, callback: @escaping Result<[BankAccount], NSError>.Callback) {
    guard let apiKey = self.apiKey, let accessToken = currentToken() else {
      let error = BackendError(code: .invalidSession, reason: nil)
      callback(.failure(error))
      return
    }
    financialAccountsStorage.addBankAccounts(userToken: accessToken.token, apiKey: apiKey, publicToken: publicToken,
                                             callback: callback)
  }

  public func completeVerification(_ verification: Verification,
                                   callback: @escaping Result<Verification, NSError>.Callback) {
    guard let apiKey = self.apiKey else {
      let error = BackendError(code: .invalidSession, reason: nil)
      callback(.failure(error))
      return
    }
    userStorage.completeVerification(apiKey, verificationId: verification.verificationId, secret: verification.secret,
                                     callback: callback)
  }

  public func fetchVerificationStatus(_ verification: Verification,
                                      callback: @escaping Result<Verification, NSError>.Callback) {
    guard let apiKey = self.apiKey else {
      let error = BackendError(code: .invalidSession, reason: nil)
      callback(.failure(error))
      return
    }
    userStorage.verificationStatus(apiKey, verificationId: verification.verificationId, callback: callback)
  }

  public func fetchCards(page: Int, rows: Int, callback: @escaping Result<[Card], NSError>.Callback) {
    next(financialAccountsOfType: .card, page: page, rows: rows) { result in
      switch result {
      case .failure(let error):
        callback(.failure(error))
      case .success(let financialAccounts):
        let cards = financialAccounts.compactMap { $0 as? Card }
        callback(.success(cards))
      }
    }
  }

  private func next(financialAccountsOfType: FinancialAccountType, page: Int, rows: Int,
            callback: @escaping Result<[FinancialAccount], NSError>.Callback) {
    guard let apiKey = self.apiKey, let accessToken = currentToken() else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }
    financialAccountsStorage.get(financialAccountsOfType: financialAccountsOfType, apiKey: apiKey,
                                 userToken: accessToken.token, callback: callback)
  }

  public func fetchFinancialAccount(_ accountId: String, forceRefresh: Bool = true, retrieveBalances: Bool = false,
                                    callback: @escaping Result<FinancialAccount, NSError>.Callback) {
    guard let apiKey = self.apiKey, let accessToken = currentToken() else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }
    financialAccountsStorage.getFinancialAccount(apiKey, userToken: accessToken.token, accountId: accountId,
                                                 forceRefresh: forceRefresh, retrieveBalances: retrieveBalances,
                                                 callback: callback)
  }

  public func fetchCardDetails(_ cardId: String, callback: @escaping Result<CardDetails, NSError>.Callback) {
    guard let apiKey = self.apiKey, let accessToken = currentToken() else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }
    financialAccountsStorage.getCardDetails(apiKey, userToken: accessToken.token, accountId: cardId,
                                            callback: callback)
  }

  public func fetchNotificationPreferences(callback: @escaping Result<NotificationPreferences, NSError>.Callback) {
    guard let apiKey = self.apiKey, let accessToken = currentToken() else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }
    notificationPreferencesStorage.fetchPreferences(apiKey, userToken: accessToken.token, callback: callback)
  }

  public func updateNotificationPreferences(_ preferences: NotificationPreferences,
                                            callback: @escaping Result<NotificationPreferences, NSError>.Callback) {
    guard let apiKey = self.apiKey, let accessToken = currentToken() else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }
    notificationPreferencesStorage.updatePreferences(apiKey, userToken: accessToken.token, preferences: preferences,
                                                     callback: callback)
  }

  public func startOauthAuthentication(balanceType: AllowedBalanceType,
                                       callback: @escaping Result<OauthAttempt, NSError>.Callback) {
    guard let apiKey = self.apiKey, let accessToken = currentToken() else  {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }
    oauthStorage.startOauthAuthentication(apiKey, userToken: accessToken.token, balanceType: balanceType,
                                          callback: callback)
  }

  public func verifyOauthAttemptStatus(_ attempt: OauthAttempt, custodianType: CustodianType,
                                       callback: @escaping Result<Custodian?, NSError>.Callback) {
    guard let apiKey = self.apiKey, let accessToken = currentToken() else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }
    oauthStorage.verifyOauthAttemptStatus(apiKey,
                                          userToken: accessToken.token,
                                          attempt: attempt,
                                          custodianType: custodianType,
                                          callback: callback)
  }

  public func saveOauthUserData(_ userData: DataPointList, custodian: Custodian,
                                callback: @escaping Result<OAuthSaveUserDataResult, NSError>.Callback) {
    guard let apiKey = self.apiKey, let accessToken = currentToken() else {
      return callback(.failure(BackendError(code: .invalidSession)))
    }
    userStorage.saveOauthData(apiKey, userToken: accessToken.token, userData: userData, custodian: custodian,
                              callback: callback)
  }

  public func fetchOAuthData(_ custodian: Custodian, callback: @escaping Result<OAuthUserData, NSError>.Callback) {
    guard let apiKey = self.apiKey else {
      return callback(.failure(BackendError(code: .invalidSession)))
    }
    userStorage.fetchOauthData(apiKey, custodian: custodian, callback: callback)
  }

  public func fetchVoIPToken(cardId: String, actionSource: VoIPActionSource,
                             callback: @escaping Result<VoIPToken, NSError>.Callback) {
    guard let apiKey = self.apiKey, let accessToken = currentToken() else {
      return callback(.failure(BackendError(code: .invalidSession)))
    }
    voIPStorage.fetchToken(apiKey, userToken: accessToken.token, cardId: cardId, actionSource: actionSource,
                           callback: callback)
  }

  public func activatePhysicalCard(_ cardId: String, code: String,
                                   callback: @escaping Result<PhysicalCardActivationResult, NSError>.Callback) {
    guard let apiKey = self.apiKey, let accessToken = currentToken() else {
      return callback(.failure(BackendError(code: .invalidSession)))
    }
    financialAccountsStorage.activatePhysical(apiKey, userToken: accessToken.token, accountId: cardId, code: code,
                                              callback: callback)
  }

  public func activateCard(_ cardId: String, callback: @escaping Result<Card, NSError>.Callback) {
    changeCardState(cardId, state: .created, callback: callback)
  }

  public func unlockCard(_ cardId: String, callback: @escaping Result<Card, NSError>.Callback) {
    changeCardState(cardId, state: .active, callback: callback)
  }

  public func lockCard(_ cardId: String, callback: @escaping Result<Card, NSError>.Callback) {
    changeCardState(cardId, state: .inactive, callback: callback)
  }

  private func changeCardState(_ cardId: String, state: FinancialAccountState,
                               callback: @escaping Result<Card, NSError>.Callback) {
    guard let projectKey = self.apiKey, let accessToken = currentToken() else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }
    financialAccountsStorage.updateFinancialAccountState(projectKey, userToken: accessToken.token,
                                                         accountId: cardId, state: state) { result in
      callback(result.flatMap { financialAccount -> Result<Card, NSError> in
        guard let card = financialAccount as? Card else {
          return .failure(ServiceError(code: .jsonError))
        }
        return .success(card)
      })
    }
  }

  public func changeCardPIN(_ cardId: String, pin: String, callback: @escaping Result<Card, NSError>.Callback) {
    guard let projectKey = self.apiKey, let accessToken = currentToken() else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }
    financialAccountsStorage.updateFinancialAccountPIN(projectKey, userToken: accessToken.token,
                                                       accountId: cardId, pin: pin) { result in
      callback(result.flatMap { financialAccount -> Result<Card, NSError> in
        guard let card = financialAccount as? Card else {
          return .failure(ServiceError(code: .jsonError))
        }
        return .success(card)
      })
    }
  }

  public func fetchCardTransactions(_ cardId: String, filters: TransactionListFilters, forceRefresh: Bool = true,
                                    callback: @escaping Result<[Transaction], NSError>.Callback) {
    guard let projectKey = self.apiKey, let accessToken = currentToken() else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }
    financialAccountsStorage.getFinancialAccountTransactions(projectKey, userToken: accessToken.token,
                                                             accountId: cardId, filters: filters,
                                                             forceRefresh: forceRefresh, callback: callback)
  }

  public func fetchCardFundingSources(_ cardId: String, page: Int?, rows: Int?, forceRefresh: Bool = true,
                                      callback: @escaping Result<[FundingSource], NSError>.Callback) {
    guard let projectKey = self.apiKey, let accessToken = currentToken() else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }
    financialAccountsStorage.financialAccountFundingSources(projectKey, userToken: accessToken.token,
                                                            accountId: cardId, page: page, rows: rows,
                                                            forceRefresh: forceRefresh, callback: callback)
  }

  public func fetchCardFundingSource(_ cardId: String, forceRefresh: Bool = true,
                                     callback: @escaping Result<FundingSource?, NSError>.Callback) {
    guard let projectKey = self.apiKey, let accessToken = currentToken() else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }
    financialAccountsStorage.getFinancialAccountFundingSource(projectKey, userToken: accessToken.token,
                                                              accountId: cardId, forceRefresh: forceRefresh,
                                                              callback: callback)
  }

  public func setCardFundingSource(_ fundingSourceId: String, cardId: String,
                                   callback: @escaping Result<FundingSource, NSError>.Callback) {
    guard let projectKey = self.apiKey, let accessToken = currentToken() else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }
    financialAccountsStorage.setFinancialAccountFundingSource(projectKey, userToken: accessToken.token,
                                                              accountId: cardId, fundingSourceId: fundingSourceId,
                                                              callback: callback)
  }

  public func addCardFundingSource(cardId: String, custodian: Custodian,
                                   callback: @escaping Result<FundingSource, NSError>.Callback) {
    guard let projectKey = self.apiKey, let accessToken = currentToken() else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }
    financialAccountsStorage.addFinancialAccountFundingSource(projectKey, userToken: accessToken.token,
                                                              accountId: cardId, custodian: custodian,
                                                              callback: callback)
  }

  public func fetchCardProduct(cardProductId: String, forceRefresh: Bool = false,
                               callback: @escaping Result<CardProduct, NSError>.Callback) {
    guard let projectKey = self.apiKey, let accessToken = currentToken() else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }
    configurationStorage.cardConfiguration(projectKey, userToken: accessToken.token, forceRefresh: forceRefresh,
                                           cardProductId: cardProductId, callback: callback)
  }

  public func nextCardApplications(page: Int, rows: Int,
                                   callback: @escaping Result<[CardApplication], NSError>.Callback) {
    guard let projectKey = self.apiKey, let accessToken = currentToken() else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }
    cardApplicationsStorage.nextApplications(projectKey, userToken: accessToken.token, page: page, rows: rows,
                                             callback: callback)
  }

  public func applyToCard(cardProduct: CardProduct, callback: @escaping Result<CardApplication, NSError>.Callback) {
    guard let projectKey = self.apiKey, let accessToken = currentToken() else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }
    cardApplicationsStorage.createApplication(projectKey, userToken: accessToken.token, cardProduct: cardProduct,
                                              callback: callback)
  }

  public func fetchCardApplicationStatus(_ applicationId: String,
                                         callback: @escaping Result<CardApplication, NSError>.Callback) {
    guard let projectKey = self.apiKey, let accessToken = currentToken() else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }
    cardApplicationsStorage.applicationStatus(projectKey, userToken: accessToken.token, applicationId: applicationId,
                                              callback: callback)
  }

  public func setBalanceStore(applicationId: String, custodian: Custodian,
                              callback: @escaping Result<SelectBalanceStoreResult, NSError>.Callback) {
    guard let projectKey = self.apiKey, let accessToken = currentToken() else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }
    cardApplicationsStorage.setBalanceStore(projectKey, userToken: accessToken.token, applicationId: applicationId,
                                            custodian: custodian, callback: callback)
  }

  public func acceptDisclaimer(workflowObject: WorkflowObject, workflowAction: WorkflowAction,
                               callback: @escaping Result<Void, NSError>.Callback) {
    guard let projectKey = self.apiKey, let accessToken = currentToken() else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }
    cardApplicationsStorage.acceptDisclaimer(projectKey, userToken: accessToken.token, workflowObject: workflowObject,
                                             workflowAction: workflowAction, callback: callback)
  }

  public func cancelCardApplication(_ applicationId: String, callback: @escaping Result<Void, NSError>.Callback) {
    guard let apiKey = self.apiKey, let accessToken = currentToken() else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }
    cardApplicationsStorage.cancelCardApplication(apiKey, userToken: accessToken.token, applicationId: applicationId,
                                                  callback: callback)
  }

  public func issueCard(applicationId: String, callback: @escaping Result<Card, NSError>.Callback) {
    guard let projectKey = self.apiKey, let accessToken = currentToken() else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }
    let balanceVersion: BalanceVersion = isFeatureEnabled(.useBalanceVersionV2) ? .v2 : .v1
    cardApplicationsStorage.issueCard(projectKey, userToken: accessToken.token, applicationId: applicationId,
                                      balanceVersion: balanceVersion, callback: callback)
  }

  public func issueCard(cardProduct: CardProduct, custodian: Custodian?, additionalFields: [String: AnyObject]? = nil,
                        initialFundingSourceId: String? = nil, callback: @escaping Result<Card, NSError>.Callback) {
    guard let apiKey = self.apiKey, let accessToken = currentToken() else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }
    let balanceVersion: BalanceVersion = isFeatureEnabled(.useBalanceVersionV2) ? .v2 : .v1
    financialAccountsStorage.issueCard(apiKey, userToken: accessToken.token, cardProduct: cardProduct,
                                       custodian: custodian, balanceVersion: balanceVersion,
                                       additionalFields: additionalFields,
                                       initialFundingSourceId: initialFundingSourceId, callback: callback)
  }

  public func cardMonthlySpending(_ cardId: String, date: Date,
                                  callback: @escaping Result<MonthlySpending, NSError>.Callback) {
    guard let apiKey = self.apiKey, let accessToken = currentToken() else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }
    financialAccountsStorage.monthlySpending(apiKey, userToken: accessToken.token, accountId: cardId, date: date,
                                             callback: callback)
  }

  public func runPendingNetworkRequests() {
    serviceLocator.networkLocator.networkManager().runPendingRequests()
  }

  // MARK: Private Attributes

  private func setUpNotificationObservers() {
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(self.sdkDeprecated),
                                           name: .SDKDeprecatedNotification,
                                           object: nil)
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
  }

  private func removeNotificationObservers() {
    NotificationCenter.default.removeObserver(self)
  }

  @objc private func sdkDeprecated() {
    delegate?.sdkDeprecated()
  }

  @objc private func didRestoreNetworkConnection() {
    delegate?.networkConnectionRestored?()
  }

  @objc private func didLoseNetworkConnection() {
    delegate?.networkConnectionError?()
  }

  @objc private func didLoseConnectionToServer() {
    delegate?.serverMaintenanceError?()
  }
}

// MARK: - Push Notifications management

extension AptoPlatform {

  public func initializePushNotifications() {
    self.pushNotificationsManager.registerForPushNotifications()
  }

  public func handle(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
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

  private func notifyPushTokenIfNeeded() {
    if let accessToken = self.currentToken(), let pushToken = self.currentPushToken() {
      pushTokenStorage.registerPushToken(apiKey, userToken: accessToken.token, pushToken: pushToken) { _ in }
    }
  }

  private func unregisterPushTokenIfNeeded() {
    if let accessToken = self.currentToken(), let pushToken = self.currentPushToken() {
      pushTokenStorage.unregisterPushToken(apiKey, userToken: accessToken.token, pushToken: pushToken) { _ in }
    }
  }
}
