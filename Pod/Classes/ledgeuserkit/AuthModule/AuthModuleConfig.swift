//
//  AuthModuleConfig.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 13/12/2017.
//

import UIKit


@objc open class AuthModuleConfig: NSObject {
  open var defaultCountryCode: Int = 1
  open var primaryAuthCredential: DataPointType
  open var secondaryAuthCredential: DataPointType
  public init(primaryAuthCredential: DataPointType,
              secondaryAuthCredential: DataPointType) {
    self.primaryAuthCredential = primaryAuthCredential
    self.secondaryAuthCredential = secondaryAuthCredential
  }
  public convenience init (projectConfiguration: ProjectConfiguration) {
    self.init(primaryAuthCredential: projectConfiguration.primaryAuthCredential,
              secondaryAuthCredential: projectConfiguration.secondaryAuthCredential)
  }
}
