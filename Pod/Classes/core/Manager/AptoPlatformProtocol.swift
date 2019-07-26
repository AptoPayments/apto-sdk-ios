//
//  AptoPlatformProtocol.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 10/07/2019.
//

import Foundation

@objc public protocol AptoPlatformDelegate {
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
   *   - apiKey: project API key
   */
  func sdkInitialized(apiKey: String)

  /**
   * Called when a network request fails because the device is not connected to the Internet. The failed request will
   * be sent again once the connection is restored.
   *
   * When using the AptoUISDK this error will be automatically handled by the SDK.
   */
  @objc optional func networkConnectionError()

  /**
   * Called when the network connection is restored.
   *
   * When using the AptoUISDK this error will be automatically handled by the SDK.
   */
  @objc optional func networkConnectionRestored()

  /**
   * Called when a network request fails because our server is not available. Once the connection with the server is
   * you should call `AptoPlatform.defaultManager().runPendingNetworkRequests()` to rerun the failing requests.
   *
   * When using the AptoUISDK this error will be automatically handled by the SDK.
   */
  @objc optional func serverMaintenanceError()

  /**
   * This method is called when a network request fails because the current SDK version has been deprecated. To know
   * the version of the SDK use `ShiftSDK.version`.
   */
  @objc func sdkDeprecated()
}

public protocol AptoPlatformProtocol {
  var delegate: AptoPlatformDelegate? { get set }

  // SDK Initialization
  func initializeWithApiKey(_ apiKey: String, environment: AptoPlatformEnvironment, setupCertPinning: Bool)
  func initializeWithApiKey(_ apiKey: String, environment: AptoPlatformEnvironment)
  func initializeWithApiKey(_ apiKey: String)

  // Configuration handling
  func setCardOptions(_ cardOptions: CardOptions?)
  func fetchContextConfiguration(_ forceRefresh: Bool,
                                 callback: @escaping Result<ContextConfiguration, NSError>.Callback)
  func fetchUIConfig() -> UIConfig?
  func fetchCardProducts(callback: @escaping Result<[CardProductSummary], NSError>.Callback)
  func fetchCardProduct(cardProductId: String, forceRefresh: Bool,
                        callback: @escaping Result<CardProduct, NSError>.Callback)
  func isFeatureEnabled(_ featureKey: FeatureKey) -> Bool
  func isShowDetailedCardActivityEnabled() -> Bool
  func setShowDetailedCardActivityEnabled(_ isEnabled: Bool)

  // User tokens handling
  func currentToken() -> AccessToken?
  func clearUserToken()
  func currentPushToken() -> String?

  // User handling
  func createUser(userData: DataPointList, callback: @escaping Result<ShiftUser, NSError>.Callback)
  func loginUserWith(verifications: [Verification], callback: @escaping Result<ShiftUser, NSError>.Callback)
  func fetchCurrentUserInfo(forceRefresh: Bool, filterInvalidTokenResult: Bool,
                            callback: @escaping Result<ShiftUser, NSError>.Callback)
  func updateUserInfo(_ userData: DataPointList, callback: @escaping Result<ShiftUser, NSError>.Callback)
  func logout()

  // Oauth handling
  func startOauthAuthentication(balanceType: AllowedBalanceType,
                                callback: @escaping Result<OauthAttempt, NSError>.Callback)
  func verifyOauthAttemptStatus(_ attempt: OauthAttempt, custodianType: CustodianType,
                                callback: @escaping Result<Custodian?, NSError>.Callback)
  func saveOauthUserData(_ userData: DataPointList, custodian: Custodian,
                         callback: @escaping Result<OAuthSaveUserDataResult, NSError>.Callback)
  func fetchOAuthData(_ custodian: Custodian, callback: @escaping Result<OAuthUserData, NSError>.Callback)

  // Verifications
  func startPhoneVerification(_ phone: PhoneNumber, callback: @escaping Result<Verification, NSError>.Callback)
  func startEmailVerification(_ email: Email, callback: @escaping Result<Verification, NSError>.Callback)
  func startBirthDateVerification(_ birthDate: BirthDate, callback: @escaping Result<Verification, NSError>.Callback)
  func startDocumentVerification(documentImages: [UIImage], selfie: UIImage?, livenessData: [String: AnyObject]?,
                                 associatedTo workflowObject: WorkflowObject?,
                                 callback: @escaping Result<Verification, NSError>.Callback)
  func fetchDocumentVerificationStatus(_ verification: Verification,
                                       callback: @escaping Result<Verification, NSError>.Callback)
  func fetchVerificationStatus(_ verification: Verification, callback: @escaping Result<Verification, NSError>.Callback)
  func restartVerification(_ verification: Verification, callback: @escaping Result<Verification, NSError>.Callback)
  func completeVerification(_ verification: Verification, callback: @escaping Result<Verification, NSError>.Callback)

  // Card application handling
  func nextCardApplications(page: Int, rows: Int, callback: @escaping Result<[CardApplication], NSError>.Callback)
  func applyToCard(cardProduct: CardProduct, callback: @escaping Result<CardApplication, NSError>.Callback)
  func fetchCardApplicationStatus(_ applicationId: String,
                                  callback: @escaping Result<CardApplication, NSError>.Callback)
  func setBalanceStore(applicationId: String, custodian: Custodian,
                       callback: @escaping Result<SelectBalanceStoreResult, NSError>.Callback)
  func acceptDisclaimer(workflowObject: WorkflowObject, workflowAction: WorkflowAction,
                        callback: @escaping Result<Void, NSError>.Callback)
  func cancelCardApplication(_ applicationId: String, callback: @escaping Result<Void, NSError>.Callback)
  func issueCard(applicationId: String, callback: @escaping Result<Card, NSError>.Callback)
  func issueCard(cardProduct: CardProduct, custodian: Custodian?, callback: @escaping Result<Card, NSError>.Callback)

  // Card handling
  func fetchCards(page: Int, rows: Int, callback: @escaping Result<[Card], NSError>.Callback)
  func fetchFinancialAccount(_ accountId: String, forceRefresh: Bool, retrieveBalances: Bool,
                             callback: @escaping Result<FinancialAccount, NSError>.Callback)
  func fetchCardDetails(_ cardId: String, callback: @escaping Result<CardDetails, NSError>.Callback)
  func activatePhysicalCard(_ cardId: String, code: String,
                            callback: @escaping Result<PhysicalCardActivationResult, NSError>.Callback)
  func activateCard(_ cardId: String, callback: @escaping Result<Card, NSError>.Callback)
  func unlockCard(_ cardId: String, callback: @escaping Result<Card, NSError>.Callback)
  func lockCard(_ cardId: String, callback: @escaping Result<Card, NSError>.Callback)
  func changeCardPIN(_ cardId: String, pin: String, callback: @escaping Result<Card, NSError>.Callback)
  func fetchCardTransactions(_ cardId: String, filters: TransactionListFilters, forceRefresh: Bool,
                             callback: @escaping Result<[Transaction], NSError>.Callback)
  func cardMonthlySpending(_ cardId: String, date: Date, callback: @escaping Result<MonthlySpending, NSError>.Callback)

  // Card funding sources handling
  func fetchCardFundingSources(_ cardId: String, page: Int?, rows: Int?, forceRefresh: Bool,
                               callback: @escaping Result<[FundingSource], NSError>.Callback)
  func fetchCardFundingSource(_ cardId: String, forceRefresh: Bool,
                              callback: @escaping Result<FundingSource?, NSError>.Callback)
  func setCardFundingSource(_ fundingSourceId: String, cardId: String,
                            callback: @escaping Result<FundingSource, NSError>.Callback)
  func addCardFundingSource(cardId: String, custodian: Custodian,
                            callback: @escaping Result<FundingSource, NSError>.Callback)

  // Notification preferences handling
  func fetchNotificationPreferences(callback: @escaping Result<NotificationPreferences, NSError>.Callback)
  func updateNotificationPreferences(_ preferences: NotificationPreferences,
                                     callback: @escaping Result<NotificationPreferences, NSError>.Callback)

  // VoIP
  func fetchVoIPToken(cardId: String, actionSource: VoIPActionSource,
                      callback: @escaping Result<VoIPToken, NSError>.Callback)

  // Miscelaneous
  func runPendingNetworkRequests()
}

public extension AptoPlatformProtocol {
  func fetchContextConfiguration(_ forceRefresh: Bool = false,
                                 callback: @escaping Result<ContextConfiguration, NSError>.Callback) {
    fetchContextConfiguration(forceRefresh, callback: callback)
  }

  func fetchCardProduct(cardProductId: String, forceRefresh: Bool = false,
                        callback: @escaping Result<CardProduct, NSError>.Callback) {
    fetchCardProduct(cardProductId: cardProductId, forceRefresh: forceRefresh, callback: callback)
  }

  func fetchCurrentUserInfo(forceRefresh: Bool = false, filterInvalidTokenResult: Bool = false,
                            callback: @escaping Result<ShiftUser, NSError>.Callback) {
    fetchCurrentUserInfo(forceRefresh: forceRefresh, filterInvalidTokenResult: filterInvalidTokenResult,
                         callback: callback)
  }

  func fetchFinancialAccount(_ accountId: String, forceRefresh: Bool = true, retrieveBalances: Bool = false,
                             callback: @escaping Result<FinancialAccount, NSError>.Callback) {
    fetchFinancialAccount(accountId, forceRefresh: forceRefresh, retrieveBalances: retrieveBalances, callback: callback)
  }
}
