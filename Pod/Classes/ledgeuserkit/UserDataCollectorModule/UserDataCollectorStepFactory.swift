//
//  UserDataCollectorStepFactory.swift
//  Pods
//
//  Created by Takeichi Kanzaki on 31/07/2018.
//
//

class UserDataCollectorStepFactory {
  private let requiredData: RequiredDataPointList
  private let userData: DataPointList
  private let mode: UserDataCollectorFinalStepMode
  private let availableHousingTypes: [HousingType]
  private let availableSalaryFrequencies: [SalaryFrequency]
  private let availableIncomeTypes: [IncomeType]
  private let availableTimeAtAddressOptions: [TimeAtAddressOption]
  private let availableCreditScoreOptions: [CreditScoreOption]
  private let disclaimers: [Content]
  private let primaryCredentialType: DataPointType
  private let secondaryCredentialType: DataPointType
  private let googleGeocodingAPIKey: String?
  private let uiConfig: ShiftUIConfig
  private let config: UserDataCollectorConfig
  private let linkHandler: LinkHandler

  init(requiredData: RequiredDataPointList,
       userData: DataPointList,
       mode: UserDataCollectorFinalStepMode,
       availableHousingTypes: [HousingType],
       availableSalaryFrequencies: [SalaryFrequency],
       availableIncomeTypes: [IncomeType],
       availableTimeAtAddressOptions: [TimeAtAddressOption],
       availableCreditScoreOptions: [CreditScoreOption],
       disclaimers: [Content],
       primaryCredentialType: DataPointType,
       secondaryCredentialType: DataPointType,
       googleGeocodingAPIKey: String?,
       uiConfig: ShiftUIConfig,
       config: UserDataCollectorConfig,
       router: UserDataCollectorRouterProtocol) {
    self.requiredData = requiredData
    self.userData = userData
    self.mode = mode
    self.availableHousingTypes = availableHousingTypes
    self.availableSalaryFrequencies = availableSalaryFrequencies
    self.availableIncomeTypes = availableIncomeTypes
    self.availableTimeAtAddressOptions = availableTimeAtAddressOptions
    self.availableCreditScoreOptions = availableCreditScoreOptions
    self.disclaimers = disclaimers
    self.primaryCredentialType = primaryCredentialType
    self.secondaryCredentialType = secondaryCredentialType
    self.googleGeocodingAPIKey = googleGeocodingAPIKey
    self.uiConfig = uiConfig
    self.config = config
    self.linkHandler = LinkHandler(urlHandler: router)
  }

  // swiftlint:disable function_body_length
  func handler(for step: DataCollectorStep) -> DataCollectorStepProtocol {
    switch step {
    case .info:
      return InfoStep(requiredData: requiredData,
                      userData: userData,
                      primaryCredentialType: primaryCredentialType,
                      uiConfig: uiConfig)
    case .home:
      return HomeStep(requiredData: requiredData,
                      userData: userData,
                      availableHousingTypes: availableHousingTypes,
                      uiConfig: uiConfig)
    case .address:
      return AddressStep(requiredData: requiredData,
                         userData: userData,
                         uiConfig: uiConfig,
                         googleGeocodingApiKey: googleGeocodingAPIKey)
    case .timeAtAddress:
      return TimeAtAddressStep(timeAtAddressDataPoint: userData.timeAtAddressDataPoint,
                               availableTimeAtAddressOptions: availableTimeAtAddressOptions,
                               uiConfig: uiConfig)
    case .income:
      return IncomeStep(requiredData: requiredData,
                        userData: userData,
                        availableSalaryFrequencies: availableSalaryFrequencies,
                        availableIncomeTypes: availableIncomeTypes,
                        config: config,
                        uiConfig: uiConfig)
    case .monthlyIncome:
      return MonthlyIncomeStep(incomeDataPoint: userData.incomeDataPoint, uiConfig: uiConfig)
    case .paydayLoan:
      return PaydayLoanStep(paydayLoanDataPoint: userData.paydayLoanDataPoint, uiConfig: uiConfig)
    case .memberOfArmedForces:
      return MemberOfArmedForcesStep(memberOfArmedForcesDataPoint: userData.memberOfArmedForcesDataPoint,
                                     uiConfig: uiConfig)
    case .creditScore:
      return CreditScoreStep(creditScoreDataPoint: userData.creditScoreDataPoint,
                             availableCreditScoreOptions: availableCreditScoreOptions,
                             uiConfig: uiConfig)
    case .birthDaySSN:
      return BirthdaySSNStep(requiredData: requiredData,
                             secondaryCredentialType: secondaryCredentialType,
                             userData: userData,
                             mode: mode,
                             disclaimers: disclaimers,
                             uiConfig: uiConfig,
                             linkHandler: linkHandler)
    }
  }
  // swiftlint:enable function_body_length
}
