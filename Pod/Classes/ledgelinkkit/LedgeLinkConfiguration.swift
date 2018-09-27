//
//  LinkConfiguration.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 18/02/2018.
//

import UIKit

public enum OfferListStyle: Int {
  case list
  case carousel
}

open class LinkConfiguration {
  public let loanAmountRange: AmountRangeConfiguration
  public let offerListStyle: OfferListStyle
  public let posMode: Bool
  public let skipLoanAmount: Bool
  public let skipLoanPurpose: Bool
  public let loanPurposes: [LoanPurpose]
  public let loanProducts: [LoanProduct]
  public let userRequiredData: RequiredDataPointList

  init(loanAmountRange: AmountRangeConfiguration,
       offerListStyle: OfferListStyle,
       posMode: Bool,
       loanPurposes: [LoanPurpose],
       loanProducts: [LoanProduct],
       skipLoanAmount: Bool,
       skipLoanPurpose: Bool,
       userRequiredData: RequiredDataPointList) {
    self.loanAmountRange = loanAmountRange
    self.offerListStyle = offerListStyle
    self.posMode = posMode
    self.loanPurposes = loanPurposes
    self.loanProducts = loanProducts
    self.skipLoanAmount = skipLoanAmount
    self.skipLoanPurpose = skipLoanPurpose
    self.userRequiredData = userRequiredData
  }
}
