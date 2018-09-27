//
//  LoanRequestSerializer.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 24/02/16.
//
//

import Foundation

extension AppLoanData: JSONSerializable {
  
  public func jsonSerialize() -> [String: AnyObject] {
    var data = [String: AnyObject]()
    if self.amount != nil {
      data["loan_amount"]   = self.amount?.amount.value as AnyObject? ?? NSNull()
      data["currency"]      = self.amount?.currency.value as AnyObject? ?? NSNull()
    }
    if self.purposeId.value != nil {
      data["loan_purpose_id"] = self.purposeId.value as AnyObject? ?? NSNull()
    }
    if self.category != nil {
      data["loan_category_id"]  = self.category?.rawValue as AnyObject
    }
    return data
  }
  
}

extension MerchantData: JSONSerializable {
  
  public func jsonSerialize() -> [String: AnyObject] {
    var data = [String: AnyObject]()
    data["project_key"]   = self.projectKey as AnyObject? ?? NSNull()
    data["partner_key"]   = self.partnerKey as AnyObject? ?? NSNull()
    data["merchant_key"]  = self.merchantKey as AnyObject? ?? NSNull()
    data["store_key"]     = self.storeKey as AnyObject? ?? NSNull()
    return data
  }
  
}
