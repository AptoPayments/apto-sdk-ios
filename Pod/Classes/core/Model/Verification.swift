//
//  Verification.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 27/09/2016.
//
//

import Foundation

public enum VerificationStatus {
  case pending
  case passed
  case failed
}

open class Verification: NSObject {
  open var verificationId: String
  open var secret: String?
  open var status: VerificationStatus
  open var verificationType: DataPointType
  open var secondaryCredential: Verification?
  open var documentVerificationResult: DocumentVerificationResult?
  public init(verificationId:String, verificationType: DataPointType, status:VerificationStatus, secret:String? = nil, secondaryCredential: Verification? = nil) {
    self.verificationId = verificationId
    self.verificationType = verificationType
    self.secret = secret
    self.status = status
    self.secondaryCredential = secondaryCredential
  }
  open func verified() -> Bool {
    return self.status == .passed
  }
  @objc func copyWithZone(_ zone: NSZone?) -> AnyObject {
    return Verification(verificationId: verificationId, verificationType: verificationType, status: status, secret: secret, secondaryCredential: secondaryCredential)
  }
}

func ==(lhs: Verification, rhs: Verification) -> Bool {
  return lhs.verificationId == rhs.verificationId
    && lhs.status == rhs.status
    && lhs.verificationType == rhs.verificationType
    && ((lhs.secret == nil && rhs.secret == nil) || (lhs.secret != nil && rhs.secret != nil && lhs.secret! == rhs.secret!))
    && ((lhs.secondaryCredential == nil && rhs.secondaryCredential == nil) || (lhs.secondaryCredential != nil && rhs.secondaryCredential != nil && lhs.secondaryCredential! == rhs.secondaryCredential!))
}

func ==(lhs: [Verification], rhs: [Verification]) -> Bool
{
  guard lhs.count == rhs.count else { return false }
  var i1 = lhs.makeIterator()
  var i2 = rhs.makeIterator()
  var isEqual = true
  while let e1 = i1.next(), let e2 = i2.next(), isEqual
  {
    isEqual = e1 == e2
  }
  return isEqual
}
