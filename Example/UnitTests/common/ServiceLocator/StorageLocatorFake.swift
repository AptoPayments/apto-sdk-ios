//
//  StorageLocatorFake.swift
//  ShiftSDK
//
//  Created by Takeichi Kanzaki on 19/07/2018.
//
//

@testable import ShiftSDK


class StorageLocatorFake: StorageLocatorProtocol {
  func userStorage(transport: JSONTransport) -> UserStorageProtocol {
    Swift.fatalError("userStorage(transport:) has not been implemented")
  }

  func offersStorage(transport: JSONTransport) -> OffersStorageProtocol {
    Swift.fatalError("offersStorage(transport:) has not been implemented")
  }

  func configurationStorage(transport: JSONTransport) -> ConfigurationStorageProtocol {
    Swift.fatalError("configurationStorage(transport:) has not been implemented")
  }

  func loanApplicationStorage(transport: JSONTransport) -> LoanApplicationsStorageProtocol {
    Swift.fatalError("loanApplicationStorage(transport:) has not been implemented")
  }

  func cardApplicationsStorage(transport: JSONTransport) -> CardApplicationsStorageProtocol {
    Swift.fatalError("cardApplicationsStorage(transport:) has not been implemented")
  }

  func storeStorage(transport: JSONTransport) -> StoreStorageProtocol {
    Swift.fatalError("storeStorage(transport:) has not been implemented")
  }

  func financialAccountsStorage(transport: JSONTransport,
                                localCacheManager: LocalCacheFileManagerProtocol) -> FinancialAccountsStorageProtocol {
    Swift.fatalError("financialAccountsStorage(transport:) has not been implemented")
  }

  func pushTokenStorage(transport: JSONTransport) -> PushTokenStorageProtocol {
    Swift.fatalError("pushTokenStorage(transport:) has not been implemented")
  }

  func oauthStorage(transport: JSONTransport) -> OauthStorageProtocol {
    Swift.fatalError("oauthStorage(transport:) has not been implemented")
  }

  func userTokenStorage() -> UserTokenStorageProtocol {
    Swift.fatalError("userTokenStorage() has not been implemented")
  }

  func linkFileStorage() -> LinkFileStorageProtocol {
    Swift.fatalError("linkFileStorage() has not been implemented")
  }
}
