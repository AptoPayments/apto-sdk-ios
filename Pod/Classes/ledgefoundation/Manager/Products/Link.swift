//
//  Link.swift
//  Link
//
//  Created by Ivan Oliver Martínez on 07/03/2018.
//

import Foundation

extension ShiftPlatform {
  public func linkConfiguration(_ forceRefresh: Bool = false,
                                callback: @escaping Result<LinkConfiguration, NSError>.Callback) {
    guard let accessToken = self.developerKey, let projectKey = self.projectKey else {
      let error = BackendError(code: .invalidSession, reason: nil)
      callback(.failure(error))
      return
    }
    self.configurationStorage.linkConfiguration(accessToken,
                                                projectKey: projectKey,
                                                forceRefresh: forceRefresh,
                                                callback: callback)
  }

  public func loanPurposeDetails(loanPurposeId: Int) -> LoanPurpose? {
    // Warning: we suppose here that the loan purposes list has been already retrieved from the server
    guard let linkConfig = self.configurationStorage.linkConfigurationCache else {
      return nil
    }

    return linkConfig.loanPurposes.first { $0.loanPurposeId == loanPurposeId }
  }

  func requestOffers(_ accessToken: AccessToken,
                     loanData: AppLoanData,
                     merchantData: MerchantData?,
                     callback: @escaping Result<OfferRequest, NSError>.Callback) {
    guard let developerKey = self.developerKey, let projectKey = self.projectKey else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }
    self.offersStorage.requestOffers(developerKey,
                                     projectKey: projectKey,
                                     userToken: accessToken.token,
                                     loanData: loanData,
                                     merchantData: merchantData) { result in
      switch result {
      case .success(let offerRequest):
        callback(.success(offerRequest))
      case .failure(let error):
        callback(.failure(error))
      }
    }
  }

  func nextOffers(_ accessToken: AccessToken,
                  applicationId: String,
                  page: Int,
                  rows: Int,
                  callback: @escaping Result<[LoanOffer], NSError>.Callback) {
    guard let developerKey = self.developerKey, let projectKey = self.projectKey else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }
    self.offersStorage.nextOffers(developerKey,
                                  projectKey: projectKey,
                                  userToken: accessToken.token,
                                  applicationId: applicationId,
                                  page: page,
                                  rows: rows,
                                  callback: callback)
  }

  func applyToOffer(_ accessToken: AccessToken,
                    offer: LoanOffer,
                    callback: @escaping Result<LoanApplication, NSError>.Callback) {
    guard let developerKey = self.developerKey, let projectKey = self.projectKey else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }
    self.loanApplicationsStorage.createApplication(developerKey,
                                                   projectKey: projectKey,
                                                   userToken: accessToken.token,
                                                   offer: offer,
                                                   callback: callback)
  }

  func applicationStatus(_ accessToken: AccessToken,
                         applicationId: String,
                         callback: @escaping Result<LoanApplication, NSError>.Callback) {
    guard let developerKey = self.developerKey, let projectKey = self.projectKey else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }
    self.loanApplicationsStorage.applicationStatus(developerKey,
                                                   projectKey: projectKey,
                                                   userToken: accessToken.token,
                                                   applicationId: applicationId,
                                                   callback: callback)
  }

  func nextLoanApplications(_ accessToken: AccessToken,
                            page: Int,
                            rows: Int,
                            callback: @escaping Result<[LoanApplicationSummary], NSError>.Callback) {
    guard let developerKey = self.developerKey, let projectKey = self.projectKey else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }
    self.loanApplicationsStorage.nextApplications(developerKey,
                                                  projectKey: projectKey,
                                                  userToken: accessToken.token,
                                                  page: page,
                                                  rows: rows,
                                                  callback: callback)
  }

  func setApplicationAccount(_ accessToken: AccessToken,
                             financialAccount: FinancialAccount,
                             accountType: ApplicationAccountType,
                             application: LoanApplication,
                             callback: @escaping Result<LoanApplication, NSError>.Callback) {
    guard let developerKey = self.developerKey, let projectKey = self.projectKey else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }
    self.loanApplicationsStorage.setApplicationAccount(developerKey,
                                                       projectKey: projectKey,
                                                       userToken: accessToken.token,
                                                       financialAccount: financialAccount,
                                                       accountType: accountType,
                                                       application: application,
                                                       callback: callback)
  }

  func getExternalApplicationURL(_ offer: LoanOffer,
                                 callback: Result<URL, NSError>.Callback) {
    guard let url = self.offersStorage.getExternalApplicationUrl(offer) else {
      callback(.failure(ServiceError(code: ServiceError.ErrorCodes.internalIncosistencyError)))
      return
    }
    callback(Result.success(url))
  }

}

extension ShiftSession {

  func getExternalApplicationUrl(_ offer: LoanOffer, callback: Result<URL, NSError>.Callback) {
    ShiftPlatform.defaultManager().getExternalApplicationURL(offer, callback: callback)
  }

}
