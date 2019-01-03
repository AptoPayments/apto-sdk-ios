//
//  String.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 26/08/16.
//
//

import Foundation

public extension String {
  func podLocalized() -> String {
    if let retVal = StringLocalizationStorage.shared.localizedString(for: self) {
      return retVal
    }
    return self.podLocalized(ShiftPlatform.classForCoder())
  }
}
