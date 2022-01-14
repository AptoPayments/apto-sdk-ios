//
//  StorageLocator.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 19/07/2018.
//
//

class StorageLocator: StorageLocatorProtocol {
    private unowned let serviceLocator: ServiceLocatorProtocol
    private var authenticatedLocalCache: LocalCacheFileManagerProtocol?

    init(serviceLocator: ServiceLocatorProtocol) {
        self.serviceLocator = serviceLocator
    }

    func userStorage(transport: JSONTransport) -> UserStorageProtocol {
        return UserStorage(transport: transport)
    }

    func configurationStorage(transport: JSONTransport) -> ConfigurationStorageProtocol {
        let cache = ProjectBrandingCache(localCacheFileManager: localCacheFileManager())
        return ConfigurationStorage(transport: transport, cache: cache)
    }

    func cardApplicationsStorage(transport: JSONTransport) -> CardApplicationsStorageProtocol {
        return CardApplicationsStorage(transport: transport)
    }

    func financialAccountsStorage(transport: JSONTransport) -> FinancialAccountsStorageProtocol {
        let cache = FinancialAccountCache(localCacheFileManager: authenticatedLocalFileManager())
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
        return UserTokenStorage(notificationHandler: serviceLocator.notificationHandler, keychain: KeychainOS())
    }

    func featuresStorage() -> FeaturesStorageProtocol {
        return FeaturesStorage()
    }

    func voIPStorage(transport: JSONTransport) -> VoIPStorageProtocol {
        return VoIPStorage(transport: transport)
    }

    func authenticatedLocalFileManager() -> LocalCacheFileManagerProtocol {
        guard let cache = authenticatedLocalCache else {
            let localCache = AuthenticatedLocalCacheFileManager(userTokenStorage: userTokenStorage())
            authenticatedLocalCache = localCache
            return localCache
        }
        return cache
    }

    func localCacheFileManager() -> LocalCacheFileManagerProtocol {
        return LocalCacheFileManager()
    }

    func userPreferencesStorage() -> UserPreferencesStorageProtocol {
        return UserPreferencesStorage(userDefaultsStorage: UserDefaultsStorage(),
                                      notificationHandler: serviceLocator.notificationHandler)
    }

    func paymentSourcesStorage(transport: JSONTransport) -> PaymentSourcesStorageProtocol {
        PaymentSourcesStorage(transport: transport)
    }

    func achAccountAgreementStorage(transport: JSONTransport) -> AgreementStorageProtocol {
        AgreementStorage(transport: transport)
    }

    func achAccountStorage(transport: JSONTransport) -> ACHAccountStorageProtocol {
        ACHAccountStorage(transport: transport)
    }

    func p2pTransferStorage(transport: JSONTransport) -> P2PTransferProtocol {
        P2PTransferStorage(transport: transport)
    }

    func applePayIAPStorage(transport: JSONTransport) -> ApplePayIAPStorageProtocol {
        ApplePayIAPStorage(transport: transport)
    }
}
