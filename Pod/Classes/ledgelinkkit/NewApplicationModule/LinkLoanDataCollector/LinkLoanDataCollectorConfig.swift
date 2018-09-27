//
//  LinkLoanDataCollectorConfig.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 21/02/2017.
//
//

import Foundation

@objc open class LinkLoanDataCollectorConfig: NSObject {
  open var mode: LinkLoanDataCollectorModuleMode
  open var loanAmountRange: AmountRangeConfiguration
  open var requiredDataPoints: RequiredDataPointList
  open var missingDataPoints: RequiredDataPointList
  open var requiredLoanAmount: Bool
  open var requiredLoanPurpose: Bool
  open var loanProducts:[LoanProduct]
  open var loanPurposes:[LoanPurpose]
  open var pendingApplications:[LoanApplication]
  public init(mode: LinkLoanDataCollectorModuleMode,
              loanAmountRange: AmountRangeConfiguration,
              requiredDataPoints: RequiredDataPointList,
              missingDataPoints: RequiredDataPointList,
              requiredLoanAmount: Bool,
              requiredLoanPurpose: Bool,
              loanProducts:[LoanProduct],
              loanPurposes:[LoanPurpose],
              pendingApplications:[LoanApplication]) {
    self.mode = mode
    self.loanAmountRange = loanAmountRange
    self.requiredDataPoints = requiredDataPoints
    self.requiredLoanAmount = requiredLoanAmount
    self.requiredLoanPurpose = requiredLoanPurpose
    self.missingDataPoints = missingDataPoints
    self.loanProducts = loanProducts
    self.loanPurposes = loanPurposes
    self.pendingApplications = pendingApplications
  }
}

// MARK: Convenience initializer

extension LinkLoanDataCollectorConfig {
  public convenience init(userMissingDataPoints:RequiredDataPointList,
                          linkConfig:LinkConfiguration) {
    self.init(
      mode: (userMissingDataPoints.count() > 0) ? .firstStep : .finalStep,
      loanAmountRange: linkConfig.loanAmountRange,
      requiredDataPoints: linkConfig.userRequiredData,
      missingDataPoints: userMissingDataPoints,
      requiredLoanAmount: !linkConfig.skipLoanAmount,
      requiredLoanPurpose: !linkConfig.skipLoanPurpose,
      loanProducts: linkConfig.loanProducts,
      loanPurposes: linkConfig.loanPurposes,
      pendingApplications: [])
  }
}
