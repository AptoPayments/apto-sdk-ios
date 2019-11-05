//
//  DocumentVerification.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 29/05/2018.
//

import UIKit

public enum DocumentAuthenticity {
  case unknown
  case notapplicable
  case authentic
  case forged
  case indecisive
  case notcompleted
  case notrelevant
  case notrequested

  static func documentAuthenticityFrom(description: String?) -> DocumentAuthenticity? {
    guard let description = description else {
      return nil
    }
    if description.uppercased() == "UNKNOWN" {
      return .unknown
    }
    else if description.uppercased() == "NOTAPPLICABLE" {
      return .notapplicable
    }
    else if description.uppercased() == "AUTHENTIC" {
      return .authentic
    }
    else if description.uppercased() == "FORGED" {
      return .forged
    }
    else if description.uppercased() == "INDECISIVE" {
      return .indecisive
    }
    else if description.uppercased() == "NOTCOMPLETED" {
      return .notcompleted
    }
    else if description.uppercased() == "NOTRELEVANT" {
      return .notrelevant
    }
    else if description.uppercased() == "NOTREQUESTED" {
      return .notrequested
    }
    else {
      return nil
    }
  }

  public func description() -> String {
    switch self {
    case .unknown: return "Unknown"
    case .notapplicable: return "Not applicable"
    case .authentic: return "Authentic"
    case .forged: return "Document Forged"
    case .indecisive: return "Can't decide forgery"
    case .notcompleted: return "Not completed"
    case .notrelevant: return "Not relevant"
    case .notrequested: return "Not requested"
    }
  }
}

public enum DocumentCompletionStatus {
  case unknown
  case unrecognizabledocument
  case imagelowquality
  case ok // swiftlint:disable:this identifier_name
  case pagestreatedasseparatedocuments
  case requestrejected
  static func documentCompletionStatusFrom(description: String?) -> DocumentCompletionStatus? {
    guard let description = description else {
      return nil
    }
    if description.uppercased() == "UNKNOWN" {
      return .unknown
    }
    else if description.uppercased() == "UNRECOGNIZABLEDOCUMENT" {
      return .unrecognizabledocument
    }
    else if description.uppercased() == "IMAGELOWQUALITY" {
      return .imagelowquality
    }
    else if description.uppercased() == "OK" {
      return .ok
    }
    else if description.uppercased() == "PAGESTREATEDASSEPARATEDOCUMENTS" {
      return .pagestreatedasseparatedocuments
    }
    else if description.uppercased() == "REQUESTREJECTED" {
      return .requestrejected
    }
    else {
      return nil
    }
  }
  func description() -> String {
    switch self {
    case .unknown: return "Unknown"
    case .unrecognizabledocument: return "Unrecognizable document"
    case .imagelowquality: return "Low quality image"
    case .ok: return "ok"
    case .pagestreatedasseparatedocuments: return "Pages treated as separate documents"
    case .requestrejected: return "Request Rejected"
    }
  }
}

public enum FaceComparisonResult {
  case unknown
  case faceMatch
  case faceNotMatch
  case indecisive
  case techError
  case noPhotoIndoc
  case biggerSize
  case smallerSize
  case internalError
  case noLicense

  // swiftlint:disable:next cyclomatic_complexity
  static func faceComparisonResultFrom(description: String?) -> FaceComparisonResult? {
    guard let description = description else {
      return nil
    }
    if description.uppercased() == "UNKNOWN" {
      return .unknown
    }
    else if description.uppercased() == "FACE_MATCH" {
      return .faceMatch
    }
    else if description.uppercased() == "FACE_NOT_MATCH" {
      return .faceNotMatch
    }
    else if description.uppercased() == "INDECISIVE" {
      return .indecisive
    }
    else if description.uppercased() == "TECH_ERROR" {
      return .techError
    }
    else if description.uppercased() == "NO_PHOTO_IN_DOC" {
      return .noPhotoIndoc
    }
    else if description.uppercased() == "BIGGER_SIZE" {
      return .biggerSize
    }
    else if description.uppercased() == "SMALLER_SIZE" {
      return .smallerSize
    }
    else if description.uppercased() == "INTERNAL_ERROR" {
      return .internalError
    }
    else if description.uppercased() == "NO_LICENSE" {
      return .noLicense
    }
    else {
      return nil
    }
  }

  public func description() -> String {
    switch self {
    case .unknown: return "Unknown"
    case .faceMatch: return "Face Match"
    case .faceNotMatch: return "Face doesn't match"
    case .indecisive: return "Can't decide Face Matching"
    case .techError: return "Tech error"
    case .noPhotoIndoc: return "No selfie sent"
    case .biggerSize: return "Need bigger picture"
    case .smallerSize: return "Need smaller picture"
    case .internalError: return "Internal error"
    case .noLicense: return "No license"
    }
  }
}

open class DocumentVerification: Verification {
  open var verificationResult: DocumentVerificationResult?

  public init(verificationId: String,
              verificationType: DataPointType,
              status: VerificationStatus,
              secret: String? = nil,
              secondaryCredential: Verification? = nil,
              verificationResult: DocumentVerificationResult? = nil) {
    self.verificationResult = verificationResult
    super.init(verificationId: verificationId,
               verificationType: verificationType,
               status: status,
               secret: secret,
               secondaryCredential: secondaryCredential)
  }

  @objc override func copyWithZone(_ zone: NSZone?) -> AnyObject {
    return DocumentVerification(verificationId: verificationId, verificationType: verificationType, status: status,
                                secret: secret, secondaryCredential: secondaryCredential)
  }
}

open class DocumentVerificationResult: NSObject {
  open var faceComparisonResult: FaceComparisonResult
  open var docAuthenticity: DocumentAuthenticity
  open var docCompletionStatus: DocumentCompletionStatus
  open var faceSimilarityRatio: Float
  open var userData: DataPointList?

  public init(faceComparisonResult: FaceComparisonResult,
              docAuthenticity: DocumentAuthenticity,
              docCompletionStatus: DocumentCompletionStatus,
              faceSimilarityRatio: Float,
              userData: DataPointList?) {
    self.faceComparisonResult = faceComparisonResult
    self.docAuthenticity = docAuthenticity
    self.docCompletionStatus = docCompletionStatus
    self.faceSimilarityRatio = faceSimilarityRatio
    self.userData = userData
  }

  @objc func copyWithZone(_ zone: NSZone?) -> AnyObject {
    return DocumentVerificationResult(faceComparisonResult: faceComparisonResult,
                                      docAuthenticity: docAuthenticity,
                                      docCompletionStatus: docCompletionStatus,
                                      faceSimilarityRatio: faceSimilarityRatio,
                                      userData: userData?.copyWithZone(zone) as? DataPointList)
  }
}
