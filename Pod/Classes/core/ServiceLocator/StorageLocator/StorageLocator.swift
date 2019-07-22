//
//  StorageLocator.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 19/07/2018.
//
//


class StorageLocator: StorageLocatorProtocol {
  private var authenticatedLocalCache: LocalCacheFileManagerProtocol?

  func userStorage(transport: JSONTransport) -> UserStorageProtocol {
    return UserStorage(transport: transport)
  }

  func configurationStorage(transport: JSONTransport) -> ConfigurationStorageProtocol {
    let cache = ProjectBrandingCache(localCacheFileManager: self.localCacheFileManager())
    return ConfigurationStorage(transport: transport, cache: cache)
  }

  func cardApplicationsStorage(transport: JSONTransport) -> CardApplicationsStorageProtocol {
    return CardApplicationsStorage(transport: transport)
  }

  func financialAccountsStorage(transport: JSONTransport) -> FinancialAccountsStorageProtocol {
    let cache = FinancialAccountCache(localCacheFileManager: self.authenticatedLocalFileManager())
    return FinancialAccountsStorage(transport: transport, cache: cache)
  }

  func pushTokenStorage(transport: JSONTransport) -> PushTokenStorageProtocol {
    return PushTokenStorage(transport: transport)
  }

  func oauthStorage(transport: JSONTransport) -> OauthStorageProtocol {
    return OauthStorage(transport: transport)
  }

  func notificationPreferencesStorage(transport: JSONTransport) -> NotificationPreferencesStorageProtocol {
    return NotificationPreferencesStorage(transport: transport)
  }

  func userTokenStorage() -> UserTokenStorageProtocol {
    return UserTokenStorage()
  }

  func featuresStorage() -> FeaturesStorageProtocol {
    return FeaturesStorage()
  }

  func voIPStorage(transport: JSONTransport) -> VoIPStorageProtocol {
    return VoIPStorage(transport: transport)
  }

  func authenticatedLocalFileManager() -> LocalCacheFileManagerProtocol {
    if authenticatedLocalCache == nil {
      authenticatedLocalCache = AuthenticatedLocalCacheFileManager(userTokenStorage: self.userTokenStorage())
    }
    return authenticatedLocalCache! // swiftlint:disable:this implicitly_unwrapped_optional
  }

  func localCacheFileManager() -> LocalCacheFileManagerProtocol {
    return LocalCacheFileManager()
  }

  func userPreferencesStorage() -> UserPreferencesStorageProtocol {
    return UserPreferencesStorage(userDefaultsStorage: UserDefaultsStorage())
  }
}
