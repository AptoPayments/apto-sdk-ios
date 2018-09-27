//
//  LoanOffer.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 18/01/16.
//  Copyright © 2018 Shift. All rights reserved.
//

import Foundation

public enum ApplicationMethod {
  case api
  case url
}

public struct Lender {
  let name: String
  let smallIconUrl: URL?
  let bigIconUrl: URL?
  let about: String?
}

public enum TermUnit {
  case week
  case month
}

public struct Term {
  let unit: TermUnit
  let duration: Int
  public var text: String {
    var message: String = ""
    switch unit {
    case .week:
      if (duration > 1) {
        message = "general.weeks".podLocalized().replace(["(%count%)":"\(duration)"])
      }
      else {
        message = "general.week".podLocalized().replace(["(%count%)":"\(duration)"])
      }
    case .month:
      if (duration > 1) {
        message = "general.months".podLocalized().replace(["(%count%)":"\(duration)"])
      }
      else {
        message = "general.month".podLocalized().replace(["(%count%)":"\(duration)"])
      }
    }
    return message
  }
}

public struct OfferRequest {
  let id: String
  let offers: [LoanOffer]
}

public struct LoanOffer {
  let id: String
  let loanProductId: String
  let lender: Lender
  let loanAmount: Amount?
  let term: Term?
  let paymentAmount: Amount?
  let paymentCount: Int?
  let interestRate: Double?
  let expirationDate: Date?
  let applicationMethod: ApplicationMethod
  let customMessage: String?
  let showApplicationSummary: Bool
  let requiresFundingAccount: Bool
}

public enum ApplicationStatus: String {
  case UNKNOWN = "UNKNOWN"
  case RECEIVED = "APPLICATION_RECEIVED"
  case REJECTED = "APPLICATION_REJECTED"
  case PENDING_LENDER_ACTION = "PENDING_LENDER_ACTION"
  case PENDING_BORROWER_ACTION = "PENDING_BORROWER_ACTION"
  case LENDER_REJECTED = "LENDER_REJECTED"
  case BORROWER_REJECTED = "BORROWER_REJECTED"
  case LOAN_APPROVED = "LOAN_APPROVED"
  case PRE_APPROVED = "PREAPPROVED"
}

open class LoanApplication {
  let id: String
  let offer: LoanOffer
  let status: ApplicationStatus
  let applicationDate: Date
  let nextAction: WorkflowAction
  var fundingAccount: FinancialAccount?
  var repaymentAccount: FinancialAccount?
  init(id:String, offer:LoanOffer, status:ApplicationStatus, applicationDate:Date, nextAction: WorkflowAction) {
    self.id = id
    self.offer = offer
    self.status = status
    self.applicationDate = applicationDate
    self.nextAction = nextAction
  }
  open func quickDescription() -> String {
    return "\(offer.lender.name) - (\(applicationDate))"
  }
}

open class LoanApplicationSummary {
  let id: String
  let status: ApplicationStatus
  let projectName: String
  let projectSummary: String?
  let projectLogo: URL?
  let loanAmount: Amount?
  let createTime: Date
  init(id: String, status: ApplicationStatus, projectName: String, projectSummary: String?, projectLogo: URL?, loanAmount: Amount?, createTime: Date) {
    self.id = id
    self.status = status
    self.projectName = projectName
    self.projectSummary = projectSummary
    self.projectLogo = projectLogo
    self.loanAmount = loanAmount
    self.createTime = createTime
  }
  open func quickDescription() -> String {
    return "\(projectName) - (\(createTime))"
  }
}

public enum ApplicationAccountType {
  case funding
  case repayment
}

public enum RequiredAction {
  case uploadDoc([RequiredDocument])
  case addInfo(message:String)
  case confirmLoan(message:String)
  case selectFundingAccount(message:String)
  case other(message:String)
}

public enum RequiredDocument {
  case ID(message:String)
  case bankStatement(message:String)
  case proofOfAddress(message:String)
  case other(message:String)
  func id() -> Int {
    switch self {
    case .ID: return 1
    case .bankStatement: return 2
    case .proofOfAddress: return 3
    case .other: return 4
    }
  }
  func description() -> String {
    switch self {
    case .ID: return "required-document.photo-id".podLocalized()
    case .bankStatement: return "required-document.bank-statement".podLocalized()
    case .proofOfAddress: return "required-document.proof-of-address".podLocalized()
    case .other: return "required-document.other-documents".podLocalized()
    }
  }
}

extension LoanApplication: WorkflowObject {
  var workflowObjectId: String {
    return self.id
  }
}
