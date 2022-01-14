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

    public init(verificationId: String, verificationType: DataPointType, status: VerificationStatus,
                secret: String? = nil, secondaryCredential: Verification? = nil)
    {
        self.verificationId = verificationId
        self.verificationType = verificationType
        self.secret = secret
        self.status = status
        self.secondaryCredential = secondaryCredential
    }

    open func verified() -> Bool {
        return status == .passed
    }

    @objc func copyWithZone(_: NSZone?) -> AnyObject {
        return Verification(verificationId: verificationId, verificationType: verificationType, status: status,
                            secret: secret, secondaryCredential: secondaryCredential)
    }

    override public func isEqual(_ object: Any?) -> Bool {
        if let obj = object as? Verification {
            return obj.verificationId == verificationId &&
                obj.secret == secret &&
                obj.status == status &&
                obj.verificationType == verificationType &&
                obj.secondaryCredential == secondaryCredential &&
                obj.documentVerificationResult == documentVerificationResult
        } else {
            return false
        }
    }
}

// swiftlint:disable:next operator_whitespace
func == (lhs: Verification, rhs: Verification) -> Bool {
    // swiftlint:disable force_unwrapping
    return lhs.verificationId == rhs.verificationId
        && lhs.status == rhs.status
        && lhs.verificationType == rhs.verificationType
        && ((lhs.secret == nil && rhs.secret == nil)
            || (lhs.secret != nil && rhs.secret != nil && lhs.secret! == rhs.secret!))
        && ((lhs.secondaryCredential == nil && rhs.secondaryCredential == nil) || (lhs.secondaryCredential != nil
                && rhs.secondaryCredential != nil && lhs.secondaryCredential! == rhs.secondaryCredential!))
    // swiftlint:enable force_unwrapping
}

// swiftlint:disable:next operator_whitespace
func == (lhs: [Verification], rhs: [Verification]) -> Bool {
    guard lhs.count == rhs.count else { return false }
    var lhsIterator = lhs.makeIterator()
    var rhsIterator = rhs.makeIterator()
    var isEqual = true
    while let lhsItem = lhsIterator.next(), let rhsItem = rhsIterator.next(), isEqual {
        isEqual = lhsItem == rhsItem
    }
    return isEqual
}
