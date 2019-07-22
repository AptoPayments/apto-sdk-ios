//
// OAuthSaveUserDataResult.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 19/03/2019.
//

import SwiftyJSON

public struct OAuthSaveUserDataResult {
  enum ResultType: String {
    case valid
    case invalid
  }

  public var isSuccess: Bool {
    return result == .valid
  }

  let result: ResultType
  public let userData: DataPointList?
}

extension OAuthSaveUserDataResult.ResultType {
  init?(string: String?) {
    guard let string = string, let value = OAuthSaveUserDataResult.ResultType(rawValue: string) else {
      return nil
    }
    self = value
  }
}

public struct OAuthUserData {
  public let userData: DataPointList?
}

extension JSON {
  var oauthSaveUserDataResult: OAuthSaveUserDataResult? {
    guard let result = OAuthSaveUserDataResult.ResultType(string: self["result"].string) else {
      ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError,
                                                            reason: "Can't parse OAuthSaveUserDataResult \(self)"))
      return nil
    }

    let userData = dataPointList(from: self["user_data"]["data"])
    return OAuthSaveUserDataResult(result: result, userData: userData)
  }

  var oauthUserData: OAuthUserData? {
    guard let userData = dataPointList(from: self["user_data"]["data"]) else {
      ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError,
                                                            reason: "Can't parse OAuthSaveUserDataResult \(self)"))
      return nil
    }
    return OAuthUserData(userData: userData)
  }

  private func dataPointList(from json: JSON) -> DataPointList? {
    let dataPointList = DataPointList()
    if let dataPointFields = json.array {
      dataPointFields.compactMap {
        return $0.linkObject as? DataPoint
      }.forEach {
        dataPointList.add(dataPoint: $0)
      }
    }
    return !dataPointList.isEmpty ? dataPointList : nil
  }
}
