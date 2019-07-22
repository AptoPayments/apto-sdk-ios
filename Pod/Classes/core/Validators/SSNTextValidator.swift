//
//  SSNTextValidator.swift
//  AptoCoreSDK
//
//  Created by Takeichi Kanzaki on 15/07/2019.
//

import Foundation

public class SSNTextValidator: PatternTextValidator {
  static let unknownValidSSN = "   -  -    "

  init(failReasonMessage: String) {
    super.init(validPatterns: ["^\\d{3}-\\d{2}-\\d{4}$", "^   -  -    $"], failReasonMessage: failReasonMessage)
  }
}
