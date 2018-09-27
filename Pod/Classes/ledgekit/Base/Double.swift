//
//  Double.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 04/03/16.
//
//

import Foundation

extension Double {
  func format(_ f: String) -> String {
    return String(format: "%\(f)f", self)
  }
}
