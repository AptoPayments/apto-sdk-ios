//
//  LinkSession.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 13/10/2016.
//
//

import Bond

open class LinkSession {

  // MARK: Current application data

  public let loanData: AppLoanData
  let applicationStatus: Observable<AppStatus?> = Observable(nil)
  let applicationId: Observable<Int?> = Observable(nil)

  // MARK: Previous applications data

  let linkPendingApplications: Observable<[LoanApplication]> = Observable([])

  // MARK: Access to the global shift session
  weak var shiftSession: ShiftSession! // swiftlint:disable:this implicitly_unwrapped_optional

  init(shiftSession: ShiftSession) {
    self.loanData = AppLoanData()
    self.shiftSession = shiftSession
  }

  func loanPurposeDetails(loanPurposeId: Int?) -> LoanPurpose? {
    guard let purposeId = loanPurposeId else {
      return nil
    }
    return ShiftPlatform.defaultManager().loanPurposeDetails(loanPurposeId: purposeId)
  }

  func requestOffers(_ callback: @escaping Result<OfferRequest, NSError>.Callback) {
    guard let accessToken = ShiftPlatform.defaultManager().currentToken() else {
      callback(.failure(BackendError(code: .invalidSession, reason: nil)))
      return
    }
    ShiftPlatform.defaultManager().requestOffers(accessToken,
                                                 loanData: loanData,
                                                 merchantData: shiftSession.merchantData,
                                                 callback: callback)
  }

  func nextOffers(_ applicationId: String,
                  page: Int,
                  rows: Int,
                  callback: @escaping Result<[LoanOffer], NSError>.Callback) {
    guard let accessToken = ShiftPlatform.defaultManager().currentToken() else {
      callback(.failure(BackendError(code: .invalidSession, reason: nil)))
      return
    }
    ShiftPlatform.defaultManager().nextOffers(accessToken,
                                              applicationId: applicationId,
                                              page: page,
                                              rows: rows,
                                              callback: callback)
  }

  func applyToOffer(_ offer: LoanOffer, callback: @escaping Result<LoanApplication, NSError>.Callback) {
    guard let accessToken = ShiftPlatform.defaultManager().currentToken() else {
      callback(.failure(BackendError(code: .invalidSession, reason: nil)))
      return
    }
    ShiftPlatform.defaultManager().applyToOffer(accessToken, offer: offer, callback: callback)
  }

  func applicationStatus(_ applicationId: String, callback: @escaping Result<LoanApplication, NSError>.Callback) {
    guard let accessToken = ShiftPlatform.defaultManager().currentToken() else {
      callback(.failure(BackendError(code: .invalidSession, reason: nil)))
      return
    }
    ShiftPlatform.defaultManager().applicationStatus(accessToken, applicationId: applicationId, callback: callback)
  }

  func nextApplications(_ page: Int,
                        rows: Int,
                        callback: @escaping Result<[LoanApplicationSummary], NSError>.Callback) {
    guard let accessToken = ShiftPlatform.defaultManager().currentToken() else {
      // If no user is logged in, return an empty list
      callback(.success([]))
      return
    }
    ShiftPlatform.defaultManager().nextLoanApplications(accessToken, page: page, rows: rows, callback: callback)
  }

  func setApplicationAccount(financialAccount: FinancialAccount,
                             accountType: ApplicationAccountType,
                             application: LoanApplication,
                             callback: @escaping Result<LoanApplication, NSError>.Callback) {
    guard let accessToken = ShiftPlatform.defaultManager().currentToken() else {
      callback(.failure(BackendError(code: .invalidSession, reason: nil)))
      return
    }
    ShiftPlatform.defaultManager().setApplicationAccount(accessToken,
                                                         financialAccount: financialAccount,
                                                         accountType: accountType,
                                                         application: application,
                                                         callback: callback)
  }

  open func linkConfiguration(_ forceRefresh: Bool = false,
                              callback: @escaping Result<LinkConfiguration, NSError>.Callback) {
    ShiftPlatform.defaultManager().linkConfiguration(forceRefresh) { result in
      switch result {
      case .failure(let error):
        callback(.failure(error))
      case .success(let linkConfiguration):
        callback(.success(linkConfiguration))
      }
    }
  }
}

private var shiftLinkSessionDataAssociationKey: UInt8 = 0

public extension ShiftSession {
  var linkSession: LinkSession {
    get {
      guard let retVal = objc_getAssociatedObject(self, &shiftLinkSessionDataAssociationKey) as? LinkSession else {
        let linkSessionData = LinkSession(shiftSession: self)
        objc_setAssociatedObject(self,
                                 &shiftLinkSessionDataAssociationKey,
                                 linkSessionData,
                                 objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        return linkSessionData
      }
      return retVal
    }
    set(newValue) {
      objc_setAssociatedObject(self,
                               &shiftLinkSessionDataAssociationKey,
                               newValue,
                               objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
    }
  }
}
