//
//  LoanApplicationsStorage.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 02/03/16.
//
//

import Foundation

protocol LoanApplicationsStorageProtocol {
  func nextApplications(_ developerKey: String,
                        projectKey: String,
                        userToken: String,
                        page: Int,
                        rows: Int,
                        callback: @escaping Result<[LoanApplicationSummary], NSError>.Callback)
  func createApplication(_ developerKey: String,
                         projectKey: String,
                         userToken: String,
                         offer: LoanOffer,
                         callback: @escaping Result<LoanApplication, NSError>.Callback)
  func applicationStatus(_ developerKey: String,
                         projectKey: String,
                         userToken: String,
                         applicationId: String,
                         callback: @escaping Result<LoanApplication, NSError>.Callback)
  func setApplicationAccount(_ developerKey: String,
                             projectKey: String,
                             userToken: String,
                             financialAccount: FinancialAccount,
                             accountType: ApplicationAccountType,
                             application: LoanApplication,
                             callback: @escaping Result<LoanApplication, NSError>.Callback)
}

class LoanApplicationsStorage: LoanApplicationsStorageProtocol {
  private let transport: JSONTransport

  init(transport: JSONTransport) {
    self.transport = transport
  }

  func nextApplications(_ developerKey: String,
                        projectKey: String,
                        userToken: String,
                        page: Int,
                        rows: Int,
                        callback: @escaping Result<[LoanApplicationSummary], NSError>.Callback) {
    let urlTrailing = "?page=\(page)&rows=\(rows)"
    let url = URLWrapper(baseUrl: self.transport.environment.baseUrl(),
                         url: JSONRouter.loanApplicationList,
                         urlTrailing: urlTrailing)
    let auth = JSONTransportAuthorization.accessAndUserToken(token: developerKey,
                                                             projectToken: projectKey,
                                                             userToken: userToken)
    self.transport.get(url,
                       authorization: auth,
                       parameters: nil,
                       headers: nil,
                       acceptRedirectTo: nil,
                       filterInvalidTokenResult: true) { result in
      callback(result.flatMap { json -> Result<[LoanApplicationSummary], NSError> in
        guard let applications = json.linkObject as? [Any] else {
          return .failure(ServiceError(code: .jsonError))
        }
        let parsedApplications = applications.compactMap { obj -> LoanApplicationSummary? in
          return obj as? LoanApplicationSummary
        }
        return .success(parsedApplications)
      })
    }
  }

  func createApplication(_ developerKey: String,
                         projectKey: String,
                         userToken: String,
                         offer: LoanOffer,
                         callback: @escaping Result<LoanApplication, NSError>.Callback) {
    let urlTrailing = "\(offer.id)/apply"
    let url = URLWrapper(baseUrl: self.transport.environment.baseUrl(),
                         url: JSONRouter.applyToOffer,
                         urlTrailing: urlTrailing)
    let auth = JSONTransportAuthorization.accessAndUserToken(token: developerKey,
                                                             projectToken: projectKey,
                                                             userToken: userToken)
    self.transport.post(url, authorization: auth, parameters: nil, filterInvalidTokenResult: true) { result in
      callback(result.flatMap { json -> Result<LoanApplication, NSError> in
        guard let application = json.linkObject as? LoanApplication else {
          return .failure(ServiceError(code: .jsonError))
        }
        return .success(application)
      })
    }
  }

  func applicationStatus(_ developerKey: String,
                         projectKey: String,
                         userToken: String,
                         applicationId: String,
                         callback: @escaping Result<LoanApplication, NSError>.Callback) {
    let urlTrailing = "\(applicationId)/status"
    let url = URLWrapper(baseUrl: self.transport.environment.baseUrl(),
                         url: JSONRouter.applicationStatus,
                         urlTrailing: urlTrailing)
    let auth = JSONTransportAuthorization.accessAndUserToken(token: developerKey,
                                                             projectToken: projectKey,
                                                             userToken: userToken)
    self.transport.get(url,
                       authorization: auth,
                       parameters: nil,
                       headers: nil,
                       acceptRedirectTo: nil,
                       filterInvalidTokenResult: true) { result in
      callback(result.flatMap { json -> Result<LoanApplication, NSError> in
        guard let application = json.linkObject as? LoanApplication else {
          return .failure(ServiceError(code: .jsonError))
        }
        return .success(application)
      })
    }
  }

  func setApplicationAccount(_ developerKey: String,
                             projectKey: String,
                             userToken: String,
                             financialAccount: FinancialAccount,
                             accountType: ApplicationAccountType,
                             application: LoanApplication,
                             callback: @escaping Result<LoanApplication, NSError>.Callback) {
    let urlTrailing = "\(application.id)/accounts"
    let url = URLWrapper(baseUrl: self.transport.environment.baseUrl(),
                         url: JSONRouter.setApplicationFundingAccount,
                         urlTrailing: urlTrailing)
    let auth = JSONTransportAuthorization.accessAndUserToken(token: developerKey,
                                                             projectToken: projectKey,
                                                             userToken: userToken)
    var data = [String: AnyObject]()
    data["account_id"] = financialAccount.accountId as AnyObject
    data["account_type"] = (accountType == .funding ? 2 : 1) as AnyObject
    self.transport.put(url, authorization: auth, parameters: data, filterInvalidTokenResult: true) { result in
      callback(result.flatMap { json -> Result<LoanApplication, NSError> in
        guard let application = json.linkObject as? LoanApplication else {
          return .failure(ServiceError(code: .jsonError))
        }
        return .success(application)
      })
    }
  }
}
