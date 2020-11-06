//
//  BackendError.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 11/08/16.
//
//

import SwiftyJSON

public let kBackendErrorDomain = "com.ledge.ledgelink.backend"

open class BackendError: NSError {
  public let rawCode: Int?
  public enum ErrorCodes: Int {
    case undefinedError = -1
    case serviceUnavailable
    case incorrectParameters
    case birthDateVerificationFailed
    case emailVerificationFailed
    case phoneVerificationFailed
    case unknownSessionError = 3030
    case sessionExpired = 3031
    case invalidSession = 3032
    case emptySession = 3033
    case agentSessionExpired = 3040
    case agentInvalidSession = 3041
    case agentEmptySession = 3042
    case kycNotPassed = 90248
    case oauthTokenRevoked = 90251
    case loginErrorInvalidCredentials = 90028
    case loginErrorUnverifiedDatapoints = 90032
    case shiftCardActivateError = 90173
    case shiftCardEnableError = 90174
    case shiftCardDisableError = 90175
    case primaryFundingSourceNotFound = 90197
    case shiftActivatePhysicalCardError = 90206
    case wrongPhysicalCardActivationCode = 90207
    case tooManyPhysicalCardActivationAttempts = 90208
    case physicalCardAlreadyActivated = 90209
    case physicalCardActivationNotSupported = 90210
    case invalidPhysicalCardActivationCode = 90211
    case inputPhoneRequired = 200013
    case inputPhoneInvalid = 200014
    case inputPhoneNotAllowed = 200015
    case signupNotAllowed = 200016
    case firstNameRequired = 200017
    case firstNameInvalid = 200018
    case lastNameRequired = 200019
    case lastNameInvalid = 200020
    case emailInvalid = 200023
    case emailNotAllowed = 200024
    case dobRequired = 200025
    case dobTooYoung = 200026
    case idDocumentInvalid = 200027
    case addressInvalid = 200028
    case postalCodeInvalid = 200029
    case localityInvalid = 200030
    case regionInvalid = 200031
    case countryInvalid = 200032
    case cardAlreadyIssued = 200036
    case sdkDeprecated = 415
    case other = 1005
    case serverMaintenance = -1004
    case networkNotAvailable = -1009
    case balanceValidationsEmailSendsDisabled = 200040
    case balanceValidationsInsufficientApplicationLimit = 200041
    case balanceInsufficientFunds = 90196
    case canNotSendSms = 9213
    case invalidPhoneNumber = 9214
    case unreachablePhonenumber = 9215
    case invalidCalledPhoneNumber = 9216
    case cardNotFound = 922

    var descriptionKey: String {
      switch self {
      case .undefinedError: return "error.transport.undefined"
      case .serviceUnavailable: return "error.transport.serviceUnavailable"
      case .incorrectParameters: return "error.transport.incorrectParameters"
      case .birthDateVerificationFailed: return "auth.verify_birthdate.error_wrong_code.message"
      case .emailVerificationFailed: return "error.transport.emailNotVerified"
      case .phoneVerificationFailed: return "auth.verify_phone.error_wrong_code.message"
      case .unknownSessionError: return "error.transport.invalidSession"
      case .invalidSession: return "error.transport.invalidSession"
      case .sessionExpired: return "error.transport.sessionExpired"
      case .primaryFundingSourceNotFound: return "error.transport.primaryFundingSourceNotFound"
      case .other: return "error.transport.undefined"
      case .serverMaintenance: return "error.transport.serverMaintenance"
      case .networkNotAvailable: return "error.transport.networkNotAvailable"
      case .emptySession: return "error.transport.emptySession"
      case .agentSessionExpired: return "error.transport.agentSessionExpired"
      case .agentInvalidSession: return "error.transport.agentInvalidSession"
      case .agentEmptySession: return "error.transport.agentEmptySession"
      case .loginErrorInvalidCredentials: return "error.transport.loginErrorInvalidCredentials"
      case .loginErrorUnverifiedDatapoints: return "error.transport.loginErrorUnverifiedDatapoints"
      case .shiftCardActivateError: return "error.transport.shiftCardActivateError"
      case .shiftCardEnableError: return "error.transport.shiftCardEnableError"
      case .shiftCardDisableError: return "error.transport.shiftCardDisableError"
      case .sdkDeprecated: return "error.transport.sdkDeprecated"
      case .shiftActivatePhysicalCardError,
           .physicalCardActivationNotSupported:
        return "error.transport.physicalCardActivationNotSupported"
      case .wrongPhysicalCardActivationCode,
           .invalidPhysicalCardActivationCode:
        return "error.transport.wrongPhysicalCardActivationCode"
      case .tooManyPhysicalCardActivationAttempts: return "error.transport.tooManyPhysicalCardActivationAttempts"
      case .physicalCardAlreadyActivated: return "error.transport.physicalCardAlreadyActivated"
      case .kycNotPassed: return "KYC not passed"
      case .inputPhoneRequired: return "issue_card.issue_card.error.required_phone"
      case .inputPhoneInvalid: return "issue_card.issue_card.error.invalid_phone"
      case .inputPhoneNotAllowed: return "issue_card.issue_card.error.not_allowed_phone"
      case .signupNotAllowed: return "issue_card.issue_card.error.signup_not_allowed"
      case .firstNameRequired: return "issue_card.issue_card.error.required_first_name"
      case .firstNameInvalid: return "issue_card.issue_card.error.invalid_first_name"
      case .lastNameRequired: return "issue_card.issue_card.error.required_last_name"
      case .lastNameInvalid: return "issue_card.issue_card.error.invalid_last_name"
      case .emailInvalid: return "issue_card.issue_card.error.invalid_email"
      case .emailNotAllowed: return "issue_card.issue_card.error.not_allowed_email"
      case .dobRequired: return "issue_card.issue_card.error.required_dob"
      case .dobTooYoung: return "issue_card.issue_card.error.dob_too_young"
      case .idDocumentInvalid: return "issue_card.issue_card.error.invalid_id_document"
      case .addressInvalid: return "issue_card.issue_card.error.invalid_address"
      case .postalCodeInvalid: return "issue_card.issue_card.error.invalid_postal_code"
      case .localityInvalid: return "issue_card.issue_card.error.invalid_locality"
      case .regionInvalid: return "issue_card.issue_card.error.invalid_region"
      case .countryInvalid: return "issue_card.issue_card.error.invalid_country"
      case .cardAlreadyIssued: return "issue_card.issue_card.error.card_already_issued"
      case .oauthTokenRevoked: return "issue_card.issue_card.error.token_revoked"
      case .balanceValidationsEmailSendsDisabled: return "select_balance_store.login.error_email_sends_disabled.message"
      case .balanceValidationsInsufficientApplicationLimit: return "select_balance_store.login.error_insufficient_application_limit.message" // swiftlint:disable:this line_length
      case .canNotSendSms: return "auth.input_phone.error.can_not_send_sms"
      case .invalidPhoneNumber: return "auth.input_phone.error.invalid_phone_number"
      case .unreachablePhonenumber: return "auth.input_phone.error.unreachable_phone_number"
      case .invalidCalledPhoneNumber: return "auth.input_phone.error.invalid_called_phone_number"
      case .balanceInsufficientFunds: return "select_balance_store.login.error_insufficient_funds.message"
      case .cardNotFound: return "fetch_card.card_not_found"
      }
    }
  }

  public init(code: ErrorCodes, rawCode: Int? = nil, reason: String? = nil) {
    let errorCode = rawCode != nil ? " (\(rawCode!))" : "" // swiftlint:disable:this force_unwrapping
    var userInfo = [NSLocalizedDescriptionKey: code.descriptionKey.podLocalized()
      .replace(["<<ERROR_CODE>>": errorCode])]
    if let reason = reason {
      userInfo[NSLocalizedFailureReasonErrorKey] = reason
    }
    self.rawCode = rawCode
    super.init(domain: kBackendErrorDomain, code: code.rawValue, userInfo: userInfo)
  }

  public required init(coder aDecoder: NSCoder) {
    fatalError("Not implemented")
  }

  open func unknownSessionError() -> Bool {
    return self.code == ErrorCodes.unknownSessionError.rawValue
  }

  open func invalidSessionError() -> Bool {
    return self.code == ErrorCodes.invalidSession.rawValue
  }

  open func sessionExpiredError() -> Bool {
    return self.code == ErrorCodes.sessionExpired.rawValue
  }

  open func serverMaintenance() -> Bool {
    return self.code == ErrorCodes.serverMaintenance.rawValue
  }

  open func networkNotAvailable() -> Bool {
    return self.code == ErrorCodes.networkNotAvailable.rawValue
  }

  public final func sdkDeprecated() -> Bool {
    return self.code == ErrorCodes.sdkDeprecated.rawValue
  }

  public var isKYCNotPassedError: Bool {
    return self.code == ErrorCodes.kycNotPassed.rawValue
  }

  public var isOauthTokenRevokedError: Bool {
    return code == ErrorCodes.oauthTokenRevoked.rawValue
  }

  public var isBalanceInsufficientFundsError: Bool {
    return code == ErrorCodes.balanceInsufficientFunds.rawValue
  }

  public var isBalanceValidationsInsufficientApplicationLimit: Bool {
    return code == ErrorCodes.balanceValidationsInsufficientApplicationLimit.rawValue
  }

  public var isBalanceValidationsEmailSendsDisabled: Bool {
    return code == ErrorCodes.balanceValidationsEmailSendsDisabled.rawValue
  }

  public var isCardEnableError: Bool {
    return code == ErrorCodes.shiftCardEnableError.rawValue
  }

  public var isCardDisableError: Bool {
    return code == ErrorCodes.shiftCardDisableError.rawValue
  }
}

extension NSError {
  @objc public var eventInfo: [String: Any] {
    var retVal: [String: Any] = [
      "code": self.code as Any,
      "message": self.localizedDescription as Any,
    ]
    if let failure = self.localizedFailureReason {
      retVal["reason"] = failure as Any
    }
    return retVal
  }
}

extension BackendError {
  public override var eventInfo: [String: Any] {
    var retVal: [String: Any] = super.eventInfo
    if let rawCode = self.rawCode {
      retVal["raw_code"] = rawCode as Any
    }
    return retVal
  }
}

extension JSON {
  public var backendError: BackendError? {
    if let errorCode = self["code"].int,
      let code = BackendError.ErrorCodes(rawValue: errorCode) {
      return BackendError(code: code, reason: self["message"].string)
    }
    else if let rawCode = self["code"].int {
      return BackendError(code: .undefinedError, rawCode: rawCode)
    }
    return nil
  }
}
