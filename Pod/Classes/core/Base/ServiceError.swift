//
//  GenericError.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 25/01/16.
//  Copyright © 2018 Apto. All rights reserved.
//

import Foundation

public let kServiceErrorDomain = "com.aptopayments.sdk.service"

public final class ServiceError: NSError {

  public enum ErrorCodes: Int {
    case internalIncosistencyError
    case jsonError
    case notInitialized
    case wrongSessionState
    case invalidAddress
    case incompleteApplicationData
    case invalidRequestData
    case aborted

    var descriptionKey: String {
      switch self {
      case .internalIncosistencyError:  return "error.service.internalIncosistency"
      case .jsonError:                  return "error.service.jsonError"
      case .notInitialized:             return "error.service.notInitialized"
      case .wrongSessionState:          return "error.service.wrongSessionState"
      case .invalidAddress:             return "error.service.invalidAddress"
      case .incompleteApplicationData:  return "error.service.incompleteApplicationData"
      case .aborted:                    return "error.service.aborted"
      case .invalidRequestData:         return "error.service.invalidRequestData"
      }
    }
  }

  public var isAbortedError: Bool {
    return code == ErrorCodes.aborted.rawValue
  }

  public init(code: ErrorCodes, reason: String? = nil) {
    var userInfo = [NSLocalizedDescriptionKey: NSLocalizedString(code.descriptionKey, comment: "")]
    if let reason = reason {
      userInfo[NSLocalizedFailureReasonErrorKey] = reason
    }
    super.init(domain: kServiceErrorDomain, code: code.rawValue, userInfo: userInfo)
  }

  public required init(coder aDecoder: NSCoder) {
    fatalError("Not implemented")
  }
}
