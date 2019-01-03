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
fileprivate let balanceStoreValidationsLegalNameMissing = 90221
fileprivate let balanceStoreValidationsDateOfBirthMissing = 90222
fileprivate let balanceStoreValidationsDateOfBirthError = 90223
fileprivate let balanceStoreValidationsAddressMissing = 90224
fileprivate let balanceStoreValidationsEmailMissing = 90225
fileprivate let balanceStoreValidationsEmailError = 90226

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
      return "select_balance_store.login.error_wrong_country.message".podLocalized()
    case balanceStoreRegionUnsupported:
      return "select_balance_store.login.error_wrong_region.message".podLocalized()
    case balanceStoreAddressUnverified:
      return "select_balance_store.login.error_unverified_address.message".podLocalized()
    case balanceStoreCurrencyUnsupported:
      return "select_balance_store.login.error_unsupported_currency.message".podLocalized()
    case balanceStoreCannotCaptureFunds:
      return "select_balance_store.login.error_cant_capture_funds.message".podLocalized()
    case balanceStoreInsufficientFunds:
      return "select_balance_store.login.error_insufficient_funds.message".podLocalized()
    case balanceStoreValidationsLegalNameMissing:
      return "select_balance_store.login.error_missing_legal_name.message".podLocalized()
    case balanceStoreValidationsDateOfBirthMissing:
      return "select_balance_store.login.error_missing_birthdate.message".podLocalized()
    case balanceStoreValidationsDateOfBirthError:
      return "select_balance_store.login.error_wrong_birthdate.message".podLocalized()
    case balanceStoreValidationsAddressMissing:
      return "select_balance_store.login.error_missing_address.message".podLocalized()
    case balanceStoreValidationsEmailMissing:
      return "select_balance_store.login.error_missing_email.message".podLocalized()
    case balanceStoreValidationsEmailError:
      return "select_balance_store.login.error_wrong_email.message".podLocalized()
    default:
      let message = "select_balance_store.login.error_unknown.message".podLocalized()
      return message.replace(["<<ERROR_CODE>>": String(errorCode)])
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
