//
//  PhysicalCardActivationResult.swift
//  ShiftSDK
//
// Created by Takeichi Kanzaki on 23/10/2018.
//

import SwiftyJSON

enum PhysicalCardActivationResultType: String, Equatable {
  case activated
  case error
}

struct PhysicalCardActivationResult {
  let type: PhysicalCardActivationResultType
  let errorCode: Int?
  let errorMessage: String?
}

extension JSON {
  var physicalCardActivationResult: PhysicalCardActivationResult? {
    guard let rawType = self["result"].string, let resultType = PhysicalCardActivationResultType(rawValue: rawType) else {
      ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError,
                                                            reason: "Can't parse PhysicalCardActivationResult \(self)"))
      return nil
    }

    let errorCode = self["error_code"].int
    let errorMessage = self["error_message"].string

    return PhysicalCardActivationResult(type: resultType, errorCode: errorCode, errorMessage: errorMessage)
  }
}
