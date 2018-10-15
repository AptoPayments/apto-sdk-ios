//
//  AuthModuleConfig.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 13/12/2017.
//

@objc open class AuthModuleConfig: NSObject {
  public let defaultCountryCode: Int
  public let primaryAuthCredential: DataPointType
  public let secondaryAuthCredential: DataPointType
  public let allowedCountries: [Country]

  public init(defaultCountryCode: Int = 1,
              primaryAuthCredential: DataPointType,
              secondaryAuthCredential: DataPointType,
              allowedCountries: [Country]) {
    self.defaultCountryCode = defaultCountryCode
    self.primaryAuthCredential = primaryAuthCredential
    self.secondaryAuthCredential = secondaryAuthCredential
    self.allowedCountries = allowedCountries
  }

  public convenience init(projectConfiguration: ProjectConfiguration) {
    self.init(primaryAuthCredential: projectConfiguration.primaryAuthCredential,
              secondaryAuthCredential: projectConfiguration.secondaryAuthCredential,
              allowedCountries: projectConfiguration.allowedCountries)
  }
}
