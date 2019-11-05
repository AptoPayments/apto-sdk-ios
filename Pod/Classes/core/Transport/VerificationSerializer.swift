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
    data["verification_id"]     = self.verificationId as AnyObject
    data["secret"] = self.secret as AnyObject? ?? NSNull()
    data["verification_type"] = (self.verificationType == .email ? "email"
                                   : self.verificationType == .phoneNumber ? "phone"
                                   : self.verificationType == .birthDate ? "birthdate" : "") as AnyObject
    return data
  }
}
