//
//  StorageLocatorProtocol.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 18/07/2018.
//
//

protocol StorageLocatorProtocol {
  func userStorage(transport: JSONTransport) -> UserStorageProtocol
  func configurationStorage(transport: JSONTransport) -> ConfigurationStorageProtocol
  func cardApplicationsStorage(transport: JSONTransport) -> CardApplicationsStorageProtocol
  func financialAccountsStorage(transport: JSONTransport) -> FinancialAccountsStorageProtocol
  func pushTokenStorage(transport: JSONTransport) -> PushTokenStorageProtocol
  func oauthStorage(transport: JSONTransport) -> OauthStorageProtocol
  func notificationPreferencesStorage(transport: JSONTransport) -> NotificationPreferencesStorageProtocol
  func userTokenStorage() -> UserTokenStorageProtocol
  func featuresStorage() -> FeaturesStorageProtocol
  func voIPStorage(transport: JSONTransport) -> VoIPStorageProtocol
  func authenticatedLocalFileManager() -> LocalCacheFileManagerProtocol
  func localCacheFileManager() -> LocalCacheFileManagerProtocol
  func userPreferencesStorage() -> UserPreferencesStorageProtocol
  func paymentSourcesStorage(transport: JSONTransport) -> PaymentSourcesStorageProtocol
    func achAccountAgreementStorage(transport: JSONTransport) -> AgreementStorageProtocol
    func achAccountStorage(transport: JSONTransport) -> ACHAccountStorageProtocol
    func p2pTransferStorage(transport: JSONTransport) -> P2PTransferProtocol
    func applePayIAPStorage(transport: JSONTransport) -> ApplePayIAPStorageProtocol
}
