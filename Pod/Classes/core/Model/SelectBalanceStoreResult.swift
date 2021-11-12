//
//  SelectBalanceStoreResult.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 24/08/2018.
//
//

import SwiftyJSON

private let balanceStoreCountryUnsupported = 90191
private let balanceStoreRegionUnsupported = 90192
private let balanceStoreAddressUnverified = 90193
private let balanceStoreCurrencyUnsupported = 90194
private let balanceStoreCannotCaptureFunds = 90195
private let balanceStoreInsufficientFunds = 90196
private let balanceStoreBalanceNotFound = 90214
private let balanceStoreAccessTokenInvalid = 90215
private let balanceStoreScopesRequired = 90216
private let balanceStoreValidationsLegalNameMissing = 90222
private let balanceStoreValidationsDateOfBirthMissing = 90223
private let balanceStoreValidationsDateOfBirthError = 90224
private let balanceStoreValidationsAddressMissing = 90225
private let balanceStoreValidationsEmailMissing = 90226
private let balanceStoreValidationsEmailError = 90227
private let balanceValidationsEmailSendsDisabled = 200040
private let balanceValidationsInsufficientApplicationLimit = 200041
private let identityNotVerified = 200046

public enum SelectBalanceStoreResultType: String {
  case valid
  case invalid
}

public struct SelectBalanceStoreResult: Equatable {
  public let result: SelectBalanceStoreResultType
  public let errorCode: Int?
  private let errorMessageKeys: [String]?

  public var isSuccess: Bool {
    return result == .valid
  }
  public var isError: Bool {
    return !isSuccess
  }

  public var errorMessage: String {
    guard isError, let errorCode = self.errorCode else {
      return ""
    }
    if let customMessage = self.message {
      return customMessage.podLocalized().replace(["<<ERROR_CODE>>": String(errorCode)])
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
    case balanceStoreBalanceNotFound:
      return "select_balance_store.login.error_balance_not_found.message".podLocalized()
    case balanceStoreAccessTokenInvalid:
      return "select_balance_store.login.error_access_token_invalid.message".podLocalized()
    case balanceStoreScopesRequired:
      return "select_balance_store.login.error_scopes_required.message".podLocalized()
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
    case balanceValidationsEmailSendsDisabled:
      return "select_balance_store.login.error_email_sends_disabled.message".podLocalized()
    case balanceValidationsInsufficientApplicationLimit:
      return "select_balance_store.login.error_insufficient_application_limit.message".podLocalized()
    case identityNotVerified:
      return "select_balance_store.login.error_identity_not_verified.message".podLocalized()
    default:
      let message = "select_balance_store.login.error_unknown.message".podLocalized()
      return message.replace(["<<ERROR_CODE>>": String(errorCode)])
    }
  }

  private var message: String? {
    guard isError, let errorCode = self.errorCode else {
      return nil
    }
    switch errorCode {
    case balanceStoreCountryUnsupported:
      return errorMessageKeys?.first(where: { $0.endsWith("login.error_wrong_country.message") })
    case balanceStoreRegionUnsupported:
      return errorMessageKeys?.first(where: { $0.endsWith("login.error_wrong_region.message") })
    case balanceStoreAddressUnverified:
      return errorMessageKeys?.first(where: { $0.endsWith("login.error_unverified_address.message") })
    case balanceStoreCurrencyUnsupported:
      return errorMessageKeys?.first(where: { $0.endsWith("login.error_unsupported_currency.message") })
    case balanceStoreCannotCaptureFunds:
      return errorMessageKeys?.first(where: { $0.endsWith("login.error_cant_capture_funds.message") })
    case balanceStoreInsufficientFunds:
      return errorMessageKeys?.first(where: { $0.endsWith("login.error_insufficient_funds.message") })
    case balanceStoreBalanceNotFound:
      return errorMessageKeys?.first(where: { $0.endsWith("login.error_balance_not_found.message") })
    case balanceStoreAccessTokenInvalid:
      return errorMessageKeys?.first(where: { $0.endsWith("login.error_access_token_invalid.message") })
    case balanceStoreScopesRequired:
      return errorMessageKeys?.first(where: { $0.endsWith("login.error_scopes_required.message") })
    case balanceStoreValidationsLegalNameMissing:
      return errorMessageKeys?.first(where: { $0.endsWith("login.error_missing_legal_name.message") })
    case balanceStoreValidationsDateOfBirthMissing:
      return errorMessageKeys?.first(where: { $0.endsWith("login.error_missing_birthdate.message") })
    case balanceStoreValidationsDateOfBirthError:
      return errorMessageKeys?.first(where: { $0.endsWith("login.error_wrong_birthdate.message") })
    case balanceStoreValidationsAddressMissing:
      return errorMessageKeys?.first(where: { $0.endsWith("login.error_missing_address.message") })
    case balanceStoreValidationsEmailMissing:
      return errorMessageKeys?.first(where: { $0.endsWith("login.error_missing_email.message") })
    case balanceStoreValidationsEmailError:
      return errorMessageKeys?.first(where: { $0.endsWith("login.error_wrong_email.message") })
    case balanceValidationsEmailSendsDisabled:
      return errorMessageKeys?.first(where: { $0.endsWith("login.error_email_sends_disabled.message") })
    case balanceValidationsInsufficientApplicationLimit:
      return errorMessageKeys?.first(where: { $0.endsWith("login.error_insufficient_application_limit.message") })
    case identityNotVerified:
      return errorMessageKeys?.first(where: { $0.endsWith("login.error_identity_not_verified.message") })
    default:
      return errorMessageKeys?.first(where: { $0.endsWith("login.error_unknown.message") })
    }
  }

  public init(result: SelectBalanceStoreResultType, errorCode: Int?, errorMessageKeys: [String]? = nil) {
    self.result = result
    self.errorCode = errorCode
    self.errorMessageKeys = errorMessageKeys
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

extension SelectBalanceStoreResult {
  public var event: Event {
    guard isError, let errorCode = self.errorCode else {
      return .selectBalanceStoreOauthConfirmUnknownError
    }
    switch errorCode {
    case balanceStoreCountryUnsupported:
      return .selectBalanceStoreOauthConfirmCountryUnsupported
    case balanceStoreRegionUnsupported:
      return .selectBalanceStoreOauthConfirmRegionUnsupported
    case balanceStoreAddressUnverified:
      return .selectBalanceStoreOauthConfirmAddressUnverified
    case balanceStoreCurrencyUnsupported:
      return .selectBalanceStoreOauthConfirmCurrencyUnsupported
    case balanceStoreCannotCaptureFunds:
      return .selectBalanceStoreOauthConfirmCannotCaptureFunds
    case balanceStoreInsufficientFunds:
      return .selectBalanceStoreOauthConfirmInsufficientFunds
    case balanceStoreBalanceNotFound:
      return .selectBalanceStoreOauthConfirmBalanceNotFound
    case balanceStoreAccessTokenInvalid:
      return .selectBalanceStoreOauthConfirmAccessTokenInvalid
    case balanceStoreScopesRequired:
      return .selectBalanceStoreOauthConfirmScopesRequired
    case balanceStoreValidationsLegalNameMissing:
      return .selectBalanceStoreOauthConfirmLegalNameMissing
    case balanceStoreValidationsDateOfBirthMissing:
      return .selectBalanceStoreOauthConfirmDobMissing
    case balanceStoreValidationsDateOfBirthError:
      return .selectBalanceStoreOauthConfirmDobInvalid
    case balanceStoreValidationsAddressMissing:
      return .selectBalanceStoreOauthConfirmAddressMissing
    case balanceStoreValidationsEmailMissing:
      return .selectBalanceStoreOauthConfirmEmailMissing
    case balanceStoreValidationsEmailError:
      return .selectBalanceStoreOauthConfirmEmailError
    case balanceValidationsEmailSendsDisabled:
      return .selectBalanceStoreOauthConfirmEmailSendsDisabled
    case balanceValidationsInsufficientApplicationLimit:
      return .selectBalanceStoreOauthConfirmInsufficientApplicationLimit
    case identityNotVerified:
      return .selectBalanceStoreIdentityNotVerified
    default:
      return .selectBalanceStoreOauthConfirmUnknownError
    }
  }
}
