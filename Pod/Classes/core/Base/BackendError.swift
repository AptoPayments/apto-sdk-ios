//
//  BackendError.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 11/08/16.
//
//

import SwiftyJSON

public let kBackendErrorDomain = "com.aptopayments.sdk.backend"

open class BackendError: NSError {
    public let rawCode: Int?
    public enum ErrorCodes: Int {
        case undefinedError = -1
        case serviceUnavailable
        case incorrectParameters
        case birthDateVerificationFailed
        case emailVerificationFailed
        case phoneVerificationFailed
        case tooManyRequests
        case unknownSessionError = 3030
        case sessionExpired = 3031
        case sessionAuthenticationFailure = 3032
        case invalidSession = 3045
        case emptySession = 3033
        case invalidApiKey = 3035
        case agentSessionExpired = 3040
        case agentInvalidSession = 3041
        case agentEmptySession = 3042
        case kycNotPassed = 90248
        case oauthTokenRevoked = 90251
        case accountCreationProhibited = 90301
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
        case inputPhoneRequired = 200_013
        case inputPhoneInvalid = 200_014
        case inputPhoneNotAllowed = 200_015
        case signupNotAllowed = 200_016
        case firstNameRequired = 200_017
        case firstNameInvalid = 200_018
        case lastNameRequired = 200_019
        case lastNameInvalid = 200_020
        case emailInvalid = 200_023
        case emailNotAllowed = 200_024
        case dobRequired = 200_025
        case dobTooYoung = 200_026
        case idDocumentInvalid = 200_027
        case addressInvalid = 200_028
        case postalCodeInvalid = 200_029
        case localityInvalid = 200_030
        case regionInvalid = 200_031
        case countryInvalid = 200_032
        case cardAlreadyIssued = 200_036
        case sdkDeprecated = 415
        case other = 1005
        case serverMaintenance = -1004
        case networkNotAvailable = -1009
        case balanceValidationsEmailSendsDisabled = 200_040
        case balanceValidationsInsufficientApplicationLimit = 200_041
        case balanceInsufficientFunds = 90196
        case canNotSendSms = 9213
        case invalidPhoneNumber = 9214
        case unreachablePhonenumber = 9215
        case invalidCalledPhoneNumber = 9216
        case cardNotFound = 922
        case physicalCardAlreadyOrdered = 90230
        case orderPhysicalCardNotSupported = 90231
        case invalidPaymentSourceDuplicate = 200_074
        case dateOfBirthInvalid = 200_035
        case cardTypeNotSupported = 200_058
        case invalidCardNumber = 200_059
        case invalidCVV = 200_060
        case invalidExpirationDate = 200_061
        case invalidPostalCode = 200_062
        case geographyNotSupported = 200_063
        case recipientNotFound = 200_116
        case cannotDeletePreferredPaymentSource = 200_070
        case loadFundsDailyLimitExceeded = 200_069
        case transferMoneyToYourself = 200115
        
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
            case .accountCreationProhibited: return "error.transport.account_creation_prohibited"
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
            case .tooManyRequests: return "error.transport.rate_limit"
            case .sessionAuthenticationFailure: return "error.transport.authenticationFailure"
            case .invalidApiKey: return "error.auth.invalid_api_key"
            case .physicalCardAlreadyOrdered: return "error.physical_card.card_already_ordered"
            case .orderPhysicalCardNotSupported: return "error.physical_card.order_not_supported"
            case .invalidPaymentSourceDuplicate: return "load_funds.add_card.error.duplicate"
            case .dateOfBirthInvalid: return "auth.verify_birthday.error.invalid_age"
            case .cardTypeNotSupported: return "load_funds.add_card.error.card_type"
            case .invalidCardNumber: return "load_funds.add_card.error.number"
            case .invalidCVV: return "load_funds.add_card.error.cvv"
            case .invalidExpirationDate: return "load_funds.add_card.error.expiration"
            case .invalidPostalCode: return "load_funds.add_card.error.postal_code"
            case .geographyNotSupported: return "load_funds.add_card.error.address"
            case .recipientNotFound: return "p2p_transfer.search_recipient.not_found"
            case .cannotDeletePreferredPaymentSource: return "load_funds.remove_card.error.preferred"
            case .loadFundsDailyLimitExceeded: return "load_funds.add_money.error_amount_exceeded"
            case .transferMoneyToYourself: return "p2p_transfer.error.self_transfer"
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

    @available(*, unavailable)
    public required init(coder _: NSCoder) {
        fatalError("Not implemented")
    }

    open func unknownSessionError() -> Bool {
        return code == ErrorCodes.unknownSessionError.rawValue
    }

    open func invalidSessionError() -> Bool {
        return code == ErrorCodes.invalidSession.rawValue
    }

    open func sessionExpiredError() -> Bool {
        return code == ErrorCodes.sessionExpired.rawValue
    }

    open func serverMaintenance() -> Bool {
        return code == ErrorCodes.serverMaintenance.rawValue
    }

    open func networkNotAvailable() -> Bool {
        return code == ErrorCodes.networkNotAvailable.rawValue
    }

    public final func sdkDeprecated() -> Bool {
        return code == ErrorCodes.sdkDeprecated.rawValue
    }

    public var isKYCNotPassedError: Bool {
        return code == ErrorCodes.kycNotPassed.rawValue
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

    public var isSessionAuthError: Bool {
        code == ErrorCodes.sessionAuthenticationFailure.rawValue
    }

    public var isEmptySession: Bool {
        code == ErrorCodes.emptySession.rawValue
    }
}

public extension NSError {
    @objc var eventInfo: [String: Any] {
        var retVal: [String: Any] = [
            "code": code as Any,
            "message": localizedDescription as Any
        ]
        if let failure = localizedFailureReason {
            retVal["reason"] = failure as Any
        }
        return retVal
    }
}

public extension BackendError {
    override var eventInfo: [String: Any] {
        var retVal: [String: Any] = super.eventInfo
        if let rawCode = rawCode {
            retVal["raw_code"] = rawCode as Any
        }
        return retVal
    }
}

public extension JSON {
    var backendError: BackendError? {
        if let errorCode = self["code"].int,
           let code = BackendError.ErrorCodes(rawValue: errorCode) {
            return BackendError(code: code, reason: self["message"].string)
        } else if let rawCode = self["code"].int {
            return BackendError(code: .undefinedError, rawCode: rawCode, reason: self["message"].string)
        }
        return nil
    }
}
