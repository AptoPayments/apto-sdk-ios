//
//  ModelDataProvider.swift
//  ShiftSDK
//
//  Created by Takeichi Kanzaki on 14/06/2018.
//
//

import UIKit
@testable import ShiftSDK

class ModelDataProvider {
  static let provider: ModelDataProvider = ModelDataProvider()
  private init() {
  }

  lazy var user = ShiftUser(userId: "userId", accessToken: AccessToken(token: "AccessToken",
                                                                       primaryCredential: .email,
                                                                       secondaryCredential: .phoneNumber))

  lazy var teamConfig = TeamConfiguration(logoUrl: nil, name: "Test team")

  lazy var amountRangeConfiguration = AmountRangeConfiguration(min: 0, max: 1000, def: 100, inc: 100)

  lazy var workflowAction: WorkflowAction = {
    let configuration = SelectBalanceStoreActionConfiguration(allowedBalanceTypes: [coinbaseBalanceType])
    return WorkflowAction(actionId: nil,
                          name: nil,
                          order: nil,
                          status: nil,
                          actionType: .selectBalanceStore,
                          configuration: configuration)
  }()

  lazy var projectBranding: ProjectBranding = {
    return ProjectBranding(iconPrimaryColor: "ffffff",
                           iconSecondaryColor: "ffffff",
                           iconTertiaryColor: "ffffff",
                           textPrimaryColor: "ffffff",
                           textSecondaryColor: "ffffff",
                           textTertiaryColor: "ffffff",
                           textTopBarColor: "ffffff",
                           textLinkColor: "ffffff",
                           uiPrimaryColor: "ffffff",
                           uiSecondaryColor: "ffffff",
                           uiTertiaryColor: "ffffff",
                           uiErrorColor: "ffffff",
                           uiSuccessColor: "ffffff",
                           logoUrl: nil,
                           uiTheme: "theme_1")
  }()

  lazy var projectConfiguration: ProjectConfiguration = {
    return ProjectConfiguration(name: "Test project",
                                summary: nil,
                                allowUserLogin: true,
                                primaryAuthCredential: .email,
                                secondaryAuthCredential: .phoneNumber,
                                skipSteps: true,
                                strictAddressValidation: false,
                                googleGeocodingAPIKey: "",
                                defaultCountryCode: 1,
                                products: [.link],
                                incomeTypes: [IncomeType(incomeTypeId: 1)],
                                housingTypes: [HousingType(housingTypeId: 1)],
                                salaryFrequencies: [SalaryFrequency(salaryFrequencyId: 1)],
                                timeAtAddressOptions: [TimeAtAddressOption(timeAtAddressId: 1)],
                                creditScoreOptions: [CreditScoreOption(creditScoreId: 1)],
                                grossIncomeRange: amountRangeConfiguration,
                                welcomeScreenAction: workflowAction,
                                supportEmailAddress: nil,
                                branding: projectBranding,
                                allowedCountries: [Country(isoCode: "US", name: "United States")])
  }()

  lazy var uiConfig: ShiftUIConfig = ShiftUIConfig(projectConfiguration: projectConfiguration)

  lazy var phoneDataPoint: DataPoint = DataPoint(type: .phoneNumber, verified: true, notSpecified: false)
  lazy var emailDataPoint: DataPoint = DataPoint(type: .email, verified: true, notSpecified: false)

  lazy var phoneNumberDataPointList: DataPointList = {
    let list = DataPointList()
    _ = list.getForcingDataPointOf(type: .phoneNumber, defaultValue: PhoneNumber())

    return list
  }()
  lazy var emailDataPointList: DataPointList = {
    let list = DataPointList()
    _ = list.getForcingDataPointOf(type: .email, defaultValue: Email())

    return list
  }()
  lazy var birthDateDataPointList: DataPointList = {
    let list = DataPointList()
    _ = list.getForcingDataPointOf(type: .birthDate, defaultValue: BirthDate())

    return list
  }()
  lazy var ssnDataPointList: DataPointList = {
    let list = DataPointList()
    _ = list.getForcingDataPointOf(type: .idDocument, defaultValue: IdDocument())

    return list
  }()

  lazy var cardApplication: CardApplication = CardApplication(id: "id",
                                                              status: .created,
                                                              applicationDate: Date(),
                                                              workflowObjectId: "workflow_id",
                                                              nextAction: workflowAction)

  lazy var card: Card = Card(accountId: "card_id",
                             cardNetwork: .other,
                             cardIssuer: .shift,
                             cardBrand: "Shift",
                             state: .active,
                             cardHolder: "Holder Name",
                             pan: "PAN",
                             cvv: "333",
                             lastFourDigits: "7890",
                             expiration: "03/99",
                             spendableToday: Amount(value: 12.34, currency: "GBP"),
                             nativeSpendableToday: Amount(value: 0.034, currency: "BTC"),
                             kyc: .passed,
                             physicalCardActivationRequired: false,
                             panToken: "pan_token",
                             cvvToken: "cvv_token",
                             verified: true)

  lazy var cardWithIVR: Card = {
    let phoneNumber = PhoneNumber(countryCode: 1, phoneNumber: "2342303796")
    let ivr = IVR(status: .enabled, phone: phoneNumber)
    let features = CardFeatures(ivr: ivr, changePin: .disabled, allowedBalanceTypes: [coinbaseBalanceType])
    let card = Card(accountId: "card_id",
                    cardNetwork: .other,
                    cardIssuer: .shift,
                    cardBrand: "Shift",
                    state: .active,
                    cardHolder: "Holder Name",
                    pan: "PAN",
                    cvv: "333",
                    lastFourDigits: "7890",
                    expiration: "03/99",
                    spendableToday: Amount(value: 12.34, currency: "GBP"),
                    nativeSpendableToday: Amount(value: 0.034, currency: "BTC"),
                    kyc: .passed,
                    physicalCardActivationRequired: false,
                    features: features,
                    panToken: "pan_token",
                    cvvToken: "cvv_token",
                    verified: true)
    return card
  }()

  lazy var externalOauthModuleConfig = ExternalOAuthModuleConfig(title: "title",
                                                                 allowedBalanceTypes: [coinbaseBalanceType])

  lazy var custodian = Custodian(custodianType: .coinbase, name: "Coinbase")

  lazy var oauthCredential = OauthCredential(oauthToken: "auth", refreshToken: "refresh")

  lazy var oauthAttempt = OauthAttempt(id: "attempt_id",
                                       status: .passed,
                                       url: URL(string: "https://shiftpayments.com"),
                                       credentials: oauthCredential)

  lazy var usa = Country(isoCode: "US", name: "United States")

  lazy var coinbaseBalanceType = AllowedBalanceType(type: .coinbase, baseUri: "baseUri")
}
