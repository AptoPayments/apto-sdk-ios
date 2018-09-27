//
//  StorageLocator.swift
//  Pods
//
//  Created by Takeichi Kanzaki on 19/07/2018.
//
//


class StorageLocator: StorageLocatorProtocol {
  func userStorage(transport: JSONTransport) -> UserStorageProtocol {
    return UserStorage(transport: transport)
  }

  func offersStorage(transport: JSONTransport) -> OffersStorageProtocol {
    return OffersStorage(transport: transport)
  }

  func configurationStorage(transport: JSONTransport) -> ConfigurationStorageProtocol {
    return ConfigurationStorage(transport: transport)
  }

  func loanApplicationStorage(transport: JSONTransport) -> LoanApplicationsStorageProtocol {
    return LoanApplicationsStorage(transport: transport)
  }

  func cardApplicationsStorage(transport: JSONTransport) -> CardApplicationsStorageProtocol {
    return CardApplicationsStorage(transport: transport)
  }

  func storeStorage(transport: JSONTransport) -> StoreStorageProtocol {
    return StoreStorage(transport: transport)
  }

  func financialAccountsStorage(transport: JSONTransport) -> FinancialAccountsStorageProtocol {
    return FinancialAccountsStorage(transport: transport)
  }

  func pushTokenStorage(transport: JSONTransport) -> PushTokenStorageProtocol {
    return PushTokenStorage(transport: transport)
  }

  func oauthStorage(transport: JSONTransport) -> OauthStorageProtocol {
    return OauthStorage(transport: transport)
  }

  func userTokenStorage() -> UserTokenStorageProtocol {
    return UserTokenStorage()
  }

  func linkFileStorage() -> LinkFileStorageProtocol {
    return LinkFileStorage()
  }
}
