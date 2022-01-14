//
//  AccessToken.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 10/02/16.
//
//

import Foundation

public struct AccessToken {
    public let token: String
    public let expires: TimeInterval?
    public let scope: String?
    public let primaryCredential: DataPointType?
    public let secondaryCredential: DataPointType?

    init(token: String, primaryCredential: DataPointType?, secondaryCredential: DataPointType?,
         expires: TimeInterval? = nil, scope: String? = nil)
    {
        self.token = token
        self.primaryCredential = primaryCredential
        self.secondaryCredential = secondaryCredential
        self.expires = expires
        self.scope = scope
    }
}
