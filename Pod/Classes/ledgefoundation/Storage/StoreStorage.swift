//
//  StoreStorage.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 15/08/16.
//
//

import Foundation

protocol StoreStorageProtocol {
  func validateStoreKey(_ developerKey: String,
                        projectKey: String,
                        partnerKey: String,
                        merchantKey: String,
                        storeKey: String,
                        callback: @escaping Result<Store?, NSError>.Callback)
}

class StoreStorage: StoreStorageProtocol {
  private let transport: JSONTransport

  init(transport: JSONTransport) {
    self.transport = transport
  }

  // MARK: Single location info
  func validateStoreKey(_ developerKey: String,
                        projectKey: String,
                        partnerKey: String,
                        merchantKey: String,
                        storeKey: String,
                        callback: @escaping Result<Store?, NSError>.Callback) {
    let urlTrailing = "?partner_key=\(partnerKey)&merchant_key=\(merchantKey)&store_key=\(storeKey)"
    let url = URLWrapper(baseUrl: self.transport.environment.baseUrl(),
                         url: JSONRouter.storeInfo,
                         urlTrailing: urlTrailing)
    let auth = JSONTransportAuthorization.accessToken(token: developerKey, projectToken: projectKey)
    self.transport.get(url,
                       authorization: auth,
                       parameters: nil,
                       headers: nil,
                       acceptRedirectTo: nil,
                       filterInvalidTokenResult: true) { result in
      switch (result) {
      case .failure(let error):
        callback(.failure(error))
        return
      case .success:
        callback(result.flatMap { json -> Result<Store?, NSError> in
          guard let store = json.store else {
            return .success(nil)
          }
          store.storeKey = storeKey
          store.merchant?.merchantKey = merchantKey
          return .success(store)
        })
      }
    }
  }
}
