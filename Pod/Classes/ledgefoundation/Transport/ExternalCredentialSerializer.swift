//
//  ExternalCredentialSerializer.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 05/03/2018.
//

import Foundation

extension ExternalCredential {
  
  public func jsonSerialize() -> [String: AnyObject] {
    var data: [String: AnyObject] = [:]
    data["type"]              = "credential" as AnyObject
    switch (self) {
    case .oauth(let oauthCredential):
      data["credential_type"] = "oauth" as AnyObject
      data["access_token"]    = oauthCredential.oauthToken as AnyObject
      data["refresh_token"]   = oauthCredential.refreshToken as AnyObject
    case .none:
      break
    }
    return data
  }
  
  public func jsonSerializeForAddFundingSource() -> [String: AnyObject] {
    var data: [String: AnyObject] = [:]
    data["type"]              = "credential" as AnyObject
    switch (self) {
    case .oauth(let oauthCredential):
      data["credential_type"] = "oauth" as AnyObject
      data["oauth_token"]    = oauthCredential.oauthToken as AnyObject
      data["refresh_token"]   = oauthCredential.refreshToken as AnyObject
    case .none:
      break
    }
    return data
  }
  
}
