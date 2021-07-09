//
//  ApplePayIAPInputData.swift
//  AptoSDK
//
//  Created by Fabio Cuomo on 19/4/21.
//

import Foundation

public struct ApplePayIAPInputData {
    let certificates: [String]
    let nonce: String
    let nonceSignature: String
}

public struct ApplePayIAPInputDataMapper {
    public static func toJSON(_ data: ApplePayIAPInputData) -> [String: AnyObject] {
        [
            "data":
                ([
                    "certificates": data.certificates as AnyObject,
                    "nonce": data.nonce as AnyObject,
                    "nonce_signature": data.nonceSignature as AnyObject
                ]) as AnyObject
        ]
    }
}
