//
//  VerificationSerializer.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 27/09/2016.
//
//

import Foundation

extension Verification: JSONSerializable {
    public func jsonSerialize() -> [String: AnyObject] {
        var data = [String: AnyObject]()
        data["verification_id"] = verificationId as AnyObject
        data["secret"] = secret as AnyObject? ?? NSNull()
        data["verification_type"] = (verificationType == .email ? "email"
            : verificationType == .phoneNumber ? "phone"
            : verificationType == .birthDate ? "birthdate" : "") as AnyObject
        return data
    }
}
