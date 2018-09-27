//
//  OffersStorage.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 25/01/16.
//  Copyright © 2018 Shift. All rights reserved.
//

import Foundation

protocol OffersStorageProtocol {
  func requestOffers(_ developerKey: String,
                     projectKey: String,
                     userToken: String,
                     loanData: AppLoanData,
                     merchantData: MerchantData?,
                     callback: @escaping Result<OfferRequest, NSError>.Callback)
  func nextOffers(_ developerKey: String,
                  projectKey: String,
                  userToken: String,
                  applicationId: String,
                  page: Int,
                  rows: Int,
                  callback: @escaping Result<[LoanOffer], NSError>.Callback)
  func getExternalApplicationUrl(_ offer: LoanOffer) -> URL?
}

class OffersStorage: OffersStorageProtocol {
  private let transport: JSONTransport

  init(transport: JSONTransport) {
    self.transport = transport
  }

  func requestOffers(_ developerKey: String,
                     projectKey: String,
                     userToken: String,
                     loanData: AppLoanData,
                     merchantData: MerchantData?,
                     callback: @escaping Result<OfferRequest, NSError>.Callback) {
    let url = URLWrapper(baseUrl: transport.environment.baseUrl(), url: JSONRouter.requestOffers)
    let auth = JSONTransportAuthorization.accessAndUserToken(token: developerKey,
                                                             projectToken: projectKey,
                                                             userToken: userToken)
    var data = loanData.jsonSerialize()
    if merchantData != nil {
      for (k, v) in merchantData!.jsonSerialize() {
        if !(v is NSNull) {
          data.updateValue(v, forKey: k)
        }
      }
    }
    transport.post(url, authorization: auth, parameters: data, filterInvalidTokenResult: true) { result in
      callback(result.flatMap { json -> Result<OfferRequest, NSError> in
        guard let offerRequest = json.linkObject as? OfferRequest else {
          return .failure(ServiceError(code: .jsonError))
        }
        return .success(offerRequest)
      })
    }
  }

  func nextOffers(_ developerKey: String,
                  projectKey: String,
                  userToken: String,
                  applicationId: String,
                  page: Int,
                  rows: Int,
                  callback: @escaping Result<[LoanOffer], NSError>.Callback) {
    let urlTrailing = applicationId + "/offers?page=\(page)&rows=\(rows)"
    let url = URLWrapper(baseUrl: self.transport.environment.baseUrl(),
                         url: JSONRouter.nextOffers,
                         urlTrailing: urlTrailing)
    let auth = JSONTransportAuthorization.accessAndUserToken(token: developerKey,
                                                             projectToken: projectKey,
                                                             userToken: userToken)
    transport.get(url,
                  authorization: auth,
                  parameters: nil,
                  headers: nil,
                  acceptRedirectTo: nil,
                  filterInvalidTokenResult: true) { result in
      callback(result.flatMap { json -> Result<[LoanOffer], NSError> in
        guard let offers = json.linkObject as? [Any] else {
          return .failure(ServiceError(code: .jsonError))
        }
        let parsedOffers = offers.compactMap { obj -> LoanOffer? in
          return obj as? LoanOffer
        }
        return .success(parsedOffers)
      })
    }
  }

  func getExternalApplicationUrl(_ offer: LoanOffer) -> URL? {
    let urlTrailing = "\(offer.id)"
    let urlWrapper = URLWrapper(baseUrl: transport.environment.baseUrl(),
                                url: JSONRouter.applyToOfferExternal,
                                urlTrailing: urlTrailing)
    do {
      return try urlWrapper.asURL()
    }
    catch _ {
      return nil
    }
  }
}
