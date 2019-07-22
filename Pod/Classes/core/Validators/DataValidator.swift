//
//  DataValidator.swift
//  AptoCoreSDK
//
//  Created by Takeichi Kanzaki on 15/07/2019.
//

import Foundation

public enum ValidationResult {
  case pass
  case fail(reason:String)
}

open class DataValidator<T> {
  public let failReasonMessage: String
  public let validate: (T?) -> ValidationResult

  public init(failReasonMessage:String, validate: @escaping (T?) -> ValidationResult) {
    self.failReasonMessage = failReasonMessage
    self.validate = validate
  }
}
