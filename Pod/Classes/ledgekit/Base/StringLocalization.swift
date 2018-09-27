//
//  String.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 26/08/16.
//
//

import Foundation

public extension String {
  func podLocalized() -> String {
    return self.podLocalized(ShiftPlatform.classForCoder())
  }
}
