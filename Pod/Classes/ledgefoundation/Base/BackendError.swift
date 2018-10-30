//
//  BackendError.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 11/08/16.
//
//

import SwiftyJSON

public let kBackendErrorDomain = "com.ledge.ledgelink.backend"

open class BackendError: NSError {
  let rawCode: Int?
  public enum ErrorCodes: Int {
    case undefinedError = -1
    case serviceUnavailable
    case incorrectParameters
    case birthDateVerificationFailed
    case emailVerificationFailed
    case phoneVerificationFailed
    case sessionExpired = 3031
    case invalidSession = 3032
    case emptySession = 3033
    case agentSessionExpired = 3040
    case agentInvalidSession = 3041
    case agentEmptySession = 3042
    case loginErrorInvalidCredentials = 900028
    case loginErrorUnverifiedDatapoints = 900032
    case shiftCardActivateError = 900173
    case shiftCardEnableError = 900174
    case shiftCardDisableError = 900175
    case primaryFundingSourceNotFound = 90197
    case shiftActivatePhysicalCardError = 90206
    case wrongPhysicalCardActivationCode = 90207
    case tooManyPhysicalCardActivationAttempts = 90208
    case physicalCardAlreadyActivated = 90209
    case physicalCardActivationNotSupported = 90210
    case invalidPhysicalCardActivationCode = 90211
    case sdkDeprecated = 415
    case other = 1005
    case serverMaintenance = -1004
    case networkNotAvailable = -1009

    var descriptionKey: String {
      switch self {
      case .undefinedError: return "error.transport.undefined"
      case .serviceUnavailable: return "error.transport.serviceUnavailable"
      case .incorrectParameters: return "error.transport.incorrectParameters"
      case .birthDateVerificationFailed: return "error.transport.verifyBirthDate"
      case .emailVerificationFailed: return "error.transport.emailNotVerified"
      case .phoneVerificationFailed: return "error.transport.verifyPhone.incorrectPin"
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
      }
    }
  }

  public init(code: ErrorCodes,
              rawCode: Int? = nil,
              reason: String? = nil) {
    let errorCode = rawCode != nil ? " (\(rawCode!))" : ""
    var userInfo = [NSLocalizedDescriptionKey: code.descriptionKey.podLocalized()
      .replace(["<<ERROR_CODE>>" : errorCode])]
    if let reason = reason {
      userInfo[NSLocalizedFailureReasonErrorKey] = reason
    }
    self.rawCode = rawCode
    super.init(domain: kBackendErrorDomain, code: code.rawValue, userInfo: userInfo)
  }

  public required init(coder aDecoder: NSCoder) {
    fatalError("Not implemented")
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
