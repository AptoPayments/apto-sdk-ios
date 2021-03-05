//
//  AgreementRequestBody.swift
//  AptoSDK
//
//  Created by Fabio Cuomo on 22/1/21.
//

import Foundation

public enum UserActionType: String {
    case accepted = "ACCEPTED"
    case declined = "DECLINED"
}

public struct AgreementRequest {
    public let key: [String]
    public let userAction: UserActionType
    
    public init(key: [String], userAction: UserActionType) {
        self.key = key
        self.userAction = userAction
    }
    
    public func toJSON() -> [String: AnyObject] {
        [
            "agreements_keys": key as AnyObject,
            "user_action": userAction.rawValue as AnyObject
        ]
    }
}
