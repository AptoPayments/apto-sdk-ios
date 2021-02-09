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
}
