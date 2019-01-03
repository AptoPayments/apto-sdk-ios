//
//  UserDataCollectorConfig.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 14/10/2016.
//
//

import Foundation

@objc open class UserDataCollectorConfig: NSObject {
  open var mode: UserDataCollectorFinalStepMode
  open var backButtonMode: UIViewControllerLeftButtonMode
  open var skipSteps: Bool
  open var allowUserLogin: Bool
  open var strictAddressValidation: Bool
  open var googleGeocodingAPIKey: String?
  open var defaultCountryCode: Int = 1
  open var userRequiredData: RequiredDataPointList
  open var incomeTypes: [IncomeType]
  open var housingTypes: [HousingType]
  open var salaryFrequencies: [SalaryFrequency]
  open var timeAtAddressOptions: [TimeAtAddressOption]
  open var availableCreditScoreOptions: [CreditScoreOption]
  open var disclaimers: [Content]
  open var primaryAuthCredential: DataPointType
  open var secondaryAuthCredential: DataPointType
  open var grossIncomeRange: AmountRangeConfiguration

  public init(mode: UserDataCollectorFinalStepMode,
              backButtonMode: UIViewControllerLeftButtonMode,
              skipSteps: Bool,
              allowUserLogin: Bool,
              strictAddressValidation: Bool,
              googleGeocodingAPIKey: String,
              userRequiredData: RequiredDataPointList,
              incomeTypes: [IncomeType],
              housingTypes: [HousingType],
              salaryFrequencies: [SalaryFrequency],
              timeAtAddressOptions: [TimeAtAddressOption],
              creditScoreOptions: [CreditScoreOption],
              disclaimers: [Content],
              primaryAuthCredential: DataPointType,
              secondaryAuthCredential: DataPointType,
              grossIncomeRange: AmountRangeConfiguration) {
    self.mode = mode
    self.backButtonMode = backButtonMode
    self.skipSteps = skipSteps
    self.allowUserLogin = allowUserLogin
    self.strictAddressValidation = strictAddressValidation
    self.googleGeocodingAPIKey = googleGeocodingAPIKey
    self.userRequiredData = userRequiredData
    self.incomeTypes = incomeTypes
    self.housingTypes = housingTypes
    self.salaryFrequencies = salaryFrequencies
    self.timeAtAddressOptions = timeAtAddressOptions
    self.availableCreditScoreOptions = creditScoreOptions
    self.disclaimers = disclaimers
    self.primaryAuthCredential = primaryAuthCredential
    self.secondaryAuthCredential = secondaryAuthCredential
    self.grossIncomeRange = grossIncomeRange
  }

  public convenience init(contextConfiguration: ContextConfiguration,
                          mode: UserDataCollectorFinalStepMode,
                          backButtonMode: UIViewControllerLeftButtonMode,
                          userRequiredData: RequiredDataPointList,
                          disclaimers: [Content]) {
    self.init(mode: mode,
              backButtonMode: backButtonMode,
              skipSteps: contextConfiguration.projectConfiguration.skipSteps,
              allowUserLogin: contextConfiguration.projectConfiguration.allowUserLogin,
              strictAddressValidation: contextConfiguration.projectConfiguration.strictAddressValidation,
              googleGeocodingAPIKey: contextConfiguration.projectConfiguration.googleGeocodingAPIKey,
              userRequiredData: userRequiredData,
              incomeTypes: contextConfiguration.projectConfiguration.incomeTypes,
              housingTypes: contextConfiguration.projectConfiguration.housingTypes,
              salaryFrequencies: contextConfiguration.projectConfiguration.salaryFrequencies,
              timeAtAddressOptions: contextConfiguration.projectConfiguration.timeAtAddressOptions,
              creditScoreOptions: contextConfiguration.projectConfiguration.creditScoreOptions,
              disclaimers: disclaimers,
              primaryAuthCredential: contextConfiguration.projectConfiguration.primaryAuthCredential,
              secondaryAuthCredential: contextConfiguration.projectConfiguration.secondaryAuthCredential,
              grossIncomeRange: contextConfiguration.projectConfiguration.grossIncomeRange)
  }
}
