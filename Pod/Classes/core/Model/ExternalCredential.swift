//
//  ExternalCredential.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 05/03/2018.
//

import UIKit

public enum ExternalCredential {
  case oauth (OauthCredential)
  case none
}

extension ExternalCredential: Codable {
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    if container.contains(.oauth) {
      let credential = try container.decode(OauthCredential.self, forKey: .oauth)
      self = .oauth(credential)
    }
    else {
      self = .none
    }
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    switch self {
    case .oauth(let credentials):
      try container.encode(credentials, forKey: .oauth)
    case .none:
      break
    }
  }

  private enum CodingKeys: String, CodingKey {
    case oauth
  }
}

public class OauthCredential: Codable {
  public let oauthTokenId: String
  public let userData: DataPointList?

  init(oauthTokenId: String, userData: DataPointList? = nil) {
    self.oauthTokenId = oauthTokenId
    self.userData = userData
  }

  public required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.oauthTokenId = try container.decode(String.self, forKey: .oauthTokenId)
    self.userData = nil
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(oauthTokenId, forKey: .oauthTokenId)
  }

  private enum CodingKeys: String, CodingKey {
    case oauthTokenId
  }
}
