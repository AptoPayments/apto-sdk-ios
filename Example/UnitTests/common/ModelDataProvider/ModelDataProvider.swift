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
    return WorkflowAction(actionId: nil,
                          name: nil,
                          order: nil,
                          status: nil,
                          actionType: .showGenericMessage,
                          configuration: nil)
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
                           cardBackgroundColor: "ffffff",
                           logoUrl: nil)
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
                                branding: projectBranding)
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
    _ = list.getForcingDataPointOf(type:.ssn, defaultValue:SSN())

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
                             kyc: .passed,
                             panToken: "pan_token",
                             cvvToken: "cvv_token",
                             verified: true)

  lazy var externalOauthModuleConfig = ExternalOAuthModuleConfig(title: "title")

  lazy var custodian = Custodian(custodianType: .coinbase, name: "Coinbase")

  lazy var oauthCredential = OauthCredential(oauthToken: "auth", refreshToken: "refresh")

  lazy var oauthAttempt = OauthAttempt(id: "attempt_id",
                                       status: .passed,
                                       url: URL(string: "https://shiftpayments.com"),
                                       credentials: oauthCredential)
}
