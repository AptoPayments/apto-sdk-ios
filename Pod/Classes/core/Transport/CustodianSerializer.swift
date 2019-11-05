//
// CustodianSerializer.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 26/07/2019.
//

import Foundation

extension Custodian {
  var asJson: [String: AnyObject] {
    if let credentials = self.externalCredentials, case let .oauth(oauthCredentials) = credentials {
      return oauthCredentials.asJson
    }
    var data: [String: AnyObject] = [
      "type": "custodian" as AnyObject,
      "custodian_type": custodianType as AnyObject
    ]
    if let credentials = self.externalCredentials {
      data["credential"] = credentials.asJson as AnyObject
    }
    return ["balance_store": data as AnyObject]
  }
}

extension ExternalCredential {
  var asJson: [String: AnyObject] {
    switch self {
    case .none:
      return [:]
    case .oauth(let oauthCredential):
      return oauthCredential.asJson
    case .externalOauth(let externalOauthCredential):
      return externalOauthCredential.asJson
    }
  }
}

extension OauthCredential {
  var asJson: [String: AnyObject] {
    return ["oauth_token_id": oauthTokenId as AnyObject]
  }
}

extension ExternalOauthCredential {
  var asJson: [String: AnyObject] {
    return [
      "type": "credential" as AnyObject,
      "credential_type": "oauth" as AnyObject,
      "access_token": oauthToken as AnyObject,
      "refresh_token": refreshToken as AnyObject
    ]
  }
}
