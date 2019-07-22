//
//  PatternTextValidator.swift
//  AptoCoreSDK
//
//  Created by Takeichi Kanzaki on 15/07/2019.
//

import Foundation

open class PatternTextValidator: DataValidator<String> {
  private let validPatterns: [String]

  public init(validPatterns: [String], failReasonMessage: String) {
    self.validPatterns = validPatterns
    super.init(failReasonMessage: failReasonMessage) { text -> ValidationResult in
      guard let text = text else {
        return .fail(reason: failReasonMessage)
      }
      for pattern in validPatterns {
        if text.range(of: pattern, options: .regularExpression) != nil {
          return .pass
        }
      }
      return .fail(reason: failReasonMessage)
    }
  }
}
