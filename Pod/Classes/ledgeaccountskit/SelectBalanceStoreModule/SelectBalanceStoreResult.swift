//
//  SelectBalanceStoreResult.swift
//  ShiftSDK
//
//  Created by Takeichi Kanzaki on 24/08/2018.
//
//

import SwiftyJSON

fileprivate let balanceStoreCountryUnsupported = 90191
fileprivate let balanceStoreRegionUnsupported = 90192
fileprivate let balanceStoreAddressUnverified = 90193
fileprivate let balanceStoreCurrencyUnsupported = 90194
fileprivate let balanceStoreCannotCaptureFunds = 90195
fileprivate let balanceStoreInsufficientFunds = 90196

enum SelectBalanceStoreResultType: String {
  case valid
  case invalid
}

struct SelectBalanceStoreResult {
  let result: SelectBalanceStoreResultType
  let errorCode: Int?

  var isSuccess: Bool {
    return result == .valid
  }
  var isError: Bool {
    return !isSuccess
  }

  var errorMessage: String {
    guard isError, let errorCode = self.errorCode else {
      return ""
    }
    switch errorCode {
    case balanceStoreCountryUnsupported:
      return "balance.validations.address.country.unsupported".podLocalized()
    case balanceStoreRegionUnsupported:
      return "balance.validations.address.region.unsupported".podLocalized()
    case balanceStoreAddressUnverified:
      return "balance.validations.address.unverified".podLocalized()
    case balanceStoreCurrencyUnsupported:
      return "balance.validations.currency.unsupported".podLocalized()
    case balanceStoreCannotCaptureFunds:
      return "balance.validations.funds.cannot.capture".podLocalized()
    case balanceStoreInsufficientFunds:
      return "balance.validations.funds.insuficient".podLocalized()
    default:
      return "balance.validations.unknown".podLocalized().replace(["<<ERROR_CODE>>": String(errorCode)])
    }
  }
}

extension JSON {
  var selectBalanceStoreResult: SelectBalanceStoreResult? {
    guard let rawResult = self["result"].string, let result = SelectBalanceStoreResultType(rawValue: rawResult) else {
      return nil
    }
    return SelectBalanceStoreResult(result: result, errorCode: self["error_code"].int)
  }
}
