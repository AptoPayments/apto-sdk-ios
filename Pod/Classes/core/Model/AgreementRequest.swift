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
    
    public static let agreementsACH: AgreementRequest = {
        AgreementRequest(key: ["evolve_eua", "evolve_privacy"], userAction: .accepted)
    }()
    
    public init(key: [String], userAction: UserActionType) {
        self.key = key
        self.userAction = userAction
    }
}
