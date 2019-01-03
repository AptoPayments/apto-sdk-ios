//
//  ProjectConfiguration.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 13/01/2017.
//
//

import Foundation
import LinkKit

open class ContextConfiguration {
  public let teamConfiguration: TeamConfiguration
  public let projectConfiguration: ProjectConfiguration

  init(teamConfiguration: TeamConfiguration, projectConfiguration: ProjectConfiguration) {
    self.teamConfiguration = teamConfiguration
    self.projectConfiguration = projectConfiguration
  }
}

open class TeamConfiguration {
  public let logoUrl: String?
  public let name: String

  init(logoUrl: String?, name: String) {
    self.logoUrl = logoUrl
    self.name = name
  }
}

public struct ProjectBranding {
  public let uiBackgroundPrimaryColor: String
  public let uiBackgroundSecondaryColor: String
  public let iconPrimaryColor: String
  public let iconSecondaryColor: String
  public let iconTertiaryColor: String
  public let textPrimaryColor: String
  public let textSecondaryColor: String
  public let textTertiaryColor: String
  public let textTopBarColor: String
  public let textLinkColor: String
  public let uiPrimaryColor: String
  public let uiSecondaryColor: String
  public let uiTertiaryColor: String
  public let uiErrorColor: String
  public let uiSuccessColor: String
  public let uiNavigationPrimaryColor: String
  public let uiNavigationSecondaryColor: String
  public let textMessageColor: String
  public let uiStatusBarStyle: String
  public let logoUrl: String?
  public let uiTheme: String
}

open class ProjectConfiguration {
  public let name: String
  public let summary: String?
  public let allowUserLogin: Bool
  public let skipSteps: Bool
  public let strictAddressValidation: Bool
  public let incomeTypes: [IncomeType]
  public let housingTypes: [HousingType]
  public let salaryFrequencies: [SalaryFrequency]
  public let timeAtAddressOptions: [TimeAtAddressOption]
  public let creditScoreOptions: [CreditScoreOption]
  public let grossIncomeRange: AmountRangeConfiguration
  public let primaryAuthCredential: DataPointType
  public let secondaryAuthCredential: DataPointType
  public let supportEmailAddress: String?
  public let branding: ProjectBranding
  public let allowedCountries: [Country]
  let welcomeScreenAction: WorkflowAction
  let googleGeocodingAPIKey: String
  let defaultCountryCode: Int
  let products: [Product]

  init(name: String,
       summary: String?,
       allowUserLogin: Bool,
       primaryAuthCredential: DataPointType,
       secondaryAuthCredential: DataPointType,
       skipSteps: Bool,
       strictAddressValidation: Bool,
       googleGeocodingAPIKey: String,
       defaultCountryCode: Int,
       products: [Product],
       incomeTypes: [IncomeType],
       housingTypes: [HousingType],
       salaryFrequencies: [SalaryFrequency],
       timeAtAddressOptions: [TimeAtAddressOption],
       creditScoreOptions: [CreditScoreOption],
       grossIncomeRange: AmountRangeConfiguration,
       welcomeScreenAction: WorkflowAction,
       supportEmailAddress: String?,
       branding: ProjectBranding,
       allowedCountries: [Country]?) {
    self.name = name
    self.summary = summary
    self.allowUserLogin = allowUserLogin
    self.primaryAuthCredential = primaryAuthCredential
    self.secondaryAuthCredential = secondaryAuthCredential
    self.skipSteps = skipSteps
    self.strictAddressValidation = strictAddressValidation
    self.googleGeocodingAPIKey = googleGeocodingAPIKey
    self.defaultCountryCode = defaultCountryCode
    self.products = products
    self.incomeTypes = incomeTypes
    self.housingTypes = housingTypes
    self.salaryFrequencies = salaryFrequencies
    self.timeAtAddressOptions = timeAtAddressOptions
    self.creditScoreOptions = creditScoreOptions
    self.grossIncomeRange = grossIncomeRange
    self.welcomeScreenAction = welcomeScreenAction
    self.supportEmailAddress = supportEmailAddress
    self.branding = branding
    if let allowedCountries = allowedCountries, !allowedCountries.isEmpty {
      self.allowedCountries = allowedCountries
    }
    else {
      self.allowedCountries = [Country.defaultCountry]
    }
  }
}

public struct AmountRangeConfiguration {
  let min: Double
  let max: Double
  let def: Double
  let inc: Double
}

open class BankOauthConfiguration {
  public let environment: PLKEnvironment
  public let product: PLKProduct
  public let publicApiKey: String

  init(environment: PLKEnvironment, product: PLKProduct, publicApiKey: String) {
    self.environment = environment
    self.product = product
    self.publicApiKey = publicApiKey
  }
}
