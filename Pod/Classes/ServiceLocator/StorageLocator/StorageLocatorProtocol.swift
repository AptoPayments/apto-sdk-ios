//
//  StorageLocatorProtocol.swift
//  Pods
//
//  Created by Takeichi Kanzaki on 18/07/2018.
//
//

protocol StorageLocatorProtocol {
  func userStorage(transport: JSONTransport) -> UserStorageProtocol
  func offersStorage(transport: JSONTransport) -> OffersStorageProtocol
  func configurationStorage(transport: JSONTransport) -> ConfigurationStorageProtocol
  func loanApplicationStorage(transport: JSONTransport) -> LoanApplicationsStorageProtocol
  func cardApplicationsStorage(transport: JSONTransport) -> CardApplicationsStorageProtocol
  func storeStorage(transport: JSONTransport) -> StoreStorageProtocol
  func financialAccountsStorage(transport: JSONTransport) -> FinancialAccountsStorageProtocol
  func pushTokenStorage(transport: JSONTransport) -> PushTokenStorageProtocol
  func oauthStorage(transport: JSONTransport) -> OauthStorageProtocol
  func userTokenStorage() -> UserTokenStorageProtocol
  func linkFileStorage() -> LinkFileStorageProtocol
}
