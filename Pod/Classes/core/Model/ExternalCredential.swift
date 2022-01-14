//
//  ExternalCredential.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 05/03/2018.
//

import UIKit

public enum ExternalCredential {
    case oauth(OauthCredential)
    case externalOauth(ExternalOauthCredential)
    case none
}

extension ExternalCredential: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if container.contains(.oauth) {
            let credential = try container.decode(OauthCredential.self, forKey: .oauth)
            self = .oauth(credential)
        } else {
            self = .none
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .oauth(credentials):
            try container.encode(credentials, forKey: .oauth)
        case let .externalOauth(externalCredentials):
            try container.encode(externalCredentials, forKey: .externalOauth)
        case .none:
            break
        }
    }

    private enum CodingKeys: String, CodingKey {
        case oauth
        case externalOauth
    }
}

public class OauthCredential: NSObject, Codable {
    public let oauthTokenId: String
    public let userData: DataPointList?

    init(oauthTokenId: String, userData: DataPointList? = nil) {
        self.oauthTokenId = oauthTokenId
        self.userData = userData
        super.init()
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        oauthTokenId = try container.decode(String.self, forKey: .oauthTokenId)
        userData = nil
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(oauthTokenId, forKey: .oauthTokenId)
    }

    private enum CodingKeys: String, CodingKey {
        case oauthTokenId
    }
}

public class ExternalOauthCredential: NSObject, Codable {
    public let oauthToken: String
    public let refreshToken: String

    public init(oauthToken: String, refreshToken: String) {
        self.oauthToken = oauthToken
        self.refreshToken = refreshToken
    }
}
