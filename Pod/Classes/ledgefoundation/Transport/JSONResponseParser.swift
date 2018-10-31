//
//  JSONResponseSerializer.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 29/02/16.
//
//

import Foundation
import SwiftyJSON
import LinkKit

extension JSON {

  public var linkObject: Any? {

    let type = self["type"]
    guard type.error == nil else {
      return nil
    }
    switch type {
    case "list":
      guard let jsonList = self.list else {
        return nil
      }
      guard jsonList.count > 0 else {
        let retVal: [Any] = []
        return retVal
      }
      return jsonList.compactMap { json -> Any? in
        return json.linkObject
      }
    case "access_token":
      return self.accessToken
    case "loan_purpose":
      return self.loanPurpose
    case "income_type":
      return self.incomeType
    case "salary_frequency":
      return self.salaryFrequency
    case "housing_type":
      return self.housingType
    case "time_at_address_option":
      return self.timeAtAddressOption
    case "credit_score_option":
      return self.creditScoreOption
    case "loan_product":
      return self.loanProduct
    case "content":
      return self.content
    case "context_configuration":
      return self.contextConfiguration
    case "team_configuration":
      return self.teamConfiguration
    case "project_configuration":
      return self.projectConfiguration
    case "link_configuration":
      return self.linkConfiguration
    case "card_configuration":
      return self.cardConfiguration
    case "card_product":
      return self.cardProduct
    case "team":
      return self.team
    case "project":
      return self.project
    case "term":
      return self.term
    case "offer_request":
      return self.offerRequest
    case "offer":
      return self.offer
    case "application":
      return self.application
    case "application_summary":
      return self.applicationSummary
    case "bank_account":
      return self.bankAccount
    case "card":
      return self.card
    case "funding_source":
      return self.fundingSource
    case "money":
      return self.amount
    case "custodian":
      return self.custodian
    case "oauth_attempt":
      return self.oauthAttempt
    case "transaction":
      return self.transaction
    case "settlement":
      return self.transactionSettlement
    case "transaction_adjustment":
      return self.transactionAdjustment
    case "user":
      return self.user
    case "email":
      return self.email
    case "phone":
      return self.phone
    case "name":
      return self.name
    case "address":
      return self.address
    case "birthdate":
      return self.birthDate
    case "id_document":
      return self.idDocument
    case "income_source":
      return self.income_source
    case "housing":
      return self.housing
    case "payday_loan":
      return self.paydayLoan
    case "member_of_armed_forces":
      return self.memberOfArmedForces
    case "time_at_address":
      return self.timeAtAddress
    case "income":
      return self.income
    case "credit_score":
      return self.creditScore
    case "required_datapoint":
      return self.requiredDatapoint
    case "product":
      return self.product
    case "action":
      return self.workflowAction
    case "action_generic_message_config":
      return self.showGenericMessageWorkflowActionConfiguration
    case "call_to_action":
      return self.callToAction
    case "action_collect_user_data_config":
      return self.collectUserDataActionConfiguration
    case "action_disclaimer_config":
      return self.disclaimerActionConfiguration
    case "bank_oauth_config":
      return self.bankOauthConfig
    case "merchant":
      return self.merchant
    case "store":
      return self.store
    case "mcc":
      return self.mcc
    case "phone_datapoint_configuration":
      return self.allowedCountriesRequiredDataPointConfig
    case "address_datapoint_configuration":
      return self.allowedCountriesRequiredDataPointConfig
    case "id_document_datapoint_configuration":
      return self.allowedIdDocumentTypesRequiredDataPointConfig
    case "ivr":
      return self.ivr
    case "physical_activation_result":
      return self.physicalCardActivationResult
    case "allowed_balance_type":
      return self.allowedBalanceType
    case "select_balance_store_configuration":
      return self.selectBalanceStoreActionConfiguration
    default:
      return nil
    }

  }

  var list: [JSON]? {
    let list = self["data"]
    guard list.error == nil else {
      return nil
    }
    return list.array
  }

  var accessToken: AccessToken? {
    guard let
      token = self["user_token"].string
      else {
        ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError, reason: "Can't parse accessToken \(self)"))
        return nil
    }
    return AccessToken(token: token, primaryCredential: nil, secondaryCredential: nil)
  }

  var loanPurpose: LoanPurpose? {
    guard let
      description = self["description"].string,
      let loanPurposeId = self["loan_purpose_id"].int
      else {
        ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError, reason: "Can't parse loanPurpose \(self)"))
        return nil
    }
    return LoanPurpose(loanPurposeId:loanPurposeId, description:description)
  }

  var housing: Housing? {
    guard let
      housingTypeId = self["housing_type_id"].int
      else {
        ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError, reason: "Can't parse housing \(self)"))
        return nil
    }
    let verified = self["verified"].bool
    return Housing(housingType: HousingType(housingTypeId:housingTypeId), verified: verified)
  }

  var income: Income? {
    guard let
      netMonthlyIncome = self["net_monthly_income"].int,
      let grossAnnualIncome = self["gross_annual_income"].int
      else {
        ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError, reason: "Can't parse income \(self)"))
        return nil
    }
    let verified = self["verified"].bool
    return Income(netMonthlyIncome: netMonthlyIncome, grossAnnualIncome:grossAnnualIncome, verified: verified)
  }

  var creditScore: CreditScore? {
    guard let
      creditRange = self["credit_range"].int
      else {
        ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError, reason: "Can't parse credit score \(self)"))
        return nil
    }
    let verified = self["verified"].bool
    return CreditScore(creditRange: creditRange, verified: verified)
  }

  var paydayLoan: PaydayLoan? {
    guard let
      usedPaydayLoan = self["payday_loan"].bool
      else {
        ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError, reason: "Can't parse payday loan \(self)"))
        return nil
    }
    let verified = self["verified"].bool
    return PaydayLoan(usedPaydayLoan: usedPaydayLoan, verified: verified)
  }

  var memberOfArmedForces: MemberOfArmedForces? {
    guard let
      memberOfArmedForces = self["member_of_armed_forces"].bool
      else {
        ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError, reason: "Can't parse member of armed forces \(self)"))
        return nil
    }
    let verified = self["verified"].bool
    return MemberOfArmedForces(memberOfArmedForces: memberOfArmedForces, verified: verified)
  }

  var timeAtAddress: TimeAtAddress? {
    guard let
      timeAtAddress = self["time_at_address_id"].int
      else {
        ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError, reason: "Can't parse time at address \(self)"))
        return nil
    }
    let verified = self["verified"].bool
    return TimeAtAddress(timeAtAddress: TimeAtAddressOption(timeAtAddressId:timeAtAddress), verified: verified)
  }

  var requiredDatapoint: RequiredDataPoint? {
    guard let dataPointType = DataPointType.from(typeName: self["datapoint_type"].string),
          let verificationRequired = self["verification_required"].bool,
          let optional = self["not_specified_allowed"].bool else {
      ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError,
                                                            reason: "Can't parse required datapoint \(self)"))
      return nil
    }
    let dataPointConfiguration = self["datapoint_configuration"].linkObject as? RequiredDataPointConfigProtocol
    return RequiredDataPoint(type: dataPointType,
                             verificationRequired: verificationRequired,
                             optional: optional,
                             configuration: dataPointConfiguration)
  }

  var income_source: IncomeSource? {
    guard let
      salaryFrequencyId = self["salary_frequency_id"].int,
      let incomeTypeId = self["income_type_id"].int
      else {
        ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError, reason: "Can't parse income source \(self)"))
        return nil
    }
    let verified = self["verified"].bool
    let salaryFrequency = SalaryFrequency(salaryFrequencyId: salaryFrequencyId)
    let incomeType = IncomeType(incomeTypeId: incomeTypeId)
    return IncomeSource(salaryFrequency: salaryFrequency, incomeType:incomeType, verified: verified)
  }

  var incomeType: IncomeType? {
    guard let
      description = self["description"].string,
      let incomeTypeId = self["income_type_id"].int
      else {
        ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError, reason: "Can't parse income \(self)"))
        return nil
    }
    return IncomeType(incomeTypeId:incomeTypeId, description:description)
  }

  var salaryFrequency: SalaryFrequency? {
    guard let
      description = self["description"].string,
      let salaryFrequencyId = self["salary_frequency_id"].int
      else {
        ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError, reason: "Can't parse salary frequency \(self)"))
        return nil
    }
    return SalaryFrequency(salaryFrequencyId:salaryFrequencyId, description:description)
  }

  var housingType: HousingType? {
    guard let
      description = self["description"].string,
      let housingTypeId = self["housing_type_id"].int
      else {
        ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError, reason: "Can't parse housing Type \(self)"))
        return nil
    }
    return HousingType(housingTypeId:housingTypeId, description:description)
  }

  var timeAtAddressOption: TimeAtAddressOption? {
    guard let
      description = self["description"].string,
      let timeAtAddressId = self["time_at_address_id"].int
      else {
        ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError, reason: "Can't parse time at address \(self)"))
        return nil
    }
    return TimeAtAddressOption(timeAtAddressId:timeAtAddressId, description:description)
  }

  var creditScoreOption: CreditScoreOption? {
    guard let
      description = self["description"].string,
      let creditScoreId = self["credit_score_id"].int
      else {
        ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError, reason: "Can't parse credit score \(self)"))
        return nil
    }
    return CreditScoreOption(creditScoreId:creditScoreId, description:description)
  }

  var loanProduct: LoanProduct? {
    guard let
      loanProductId = self["id"].string,
      let productName = self["product_name"].string
      else {
        ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError, reason: "Can't parse loan product \(self)"))
        return nil
    }
    let prequalificationDisclaimer = self["pre_qualification_disclaimer"].content
    let offerDisclaimer = self["offer_disclaimer"].content
    let applicationDisclaimer = self["application_disclaimer"].content
    let esignDisclaimer = self["esign_disclaimer"].content
    let esignConsentDisclaimer = self["esign_consent_disclaimer"].content

    return LoanProduct(loanProductId: loanProductId, productName: productName, prequalificationDisclaimer: prequalificationDisclaimer, offerDisclaimer:offerDisclaimer, applicationDisclaimer: applicationDisclaimer, esignDisclaimer: esignDisclaimer, esignConsentDisclaimer: esignConsentDisclaimer)
  }

  var content: Content? {
    guard let
      format = self["format"].string,
      let value = self["value"].string
      else {
        ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError, reason: "Can't parse content \(self)"))
        return nil
    }
    if format == "plain_text" {
      return .plainText(value)
    }
    else if format == "markdown" {
      return .markdown(value)
    }
    else if format == "external_url" {
      if let url = URL(string: value) {
        return .externalURL(url)
      }
    }
    return nil
  }

  var contextConfiguration: ContextConfiguration? {
    guard let
      projectConfiguration = self["project"].projectConfiguration,
      let teamConfiguration = self["team"].teamConfiguration
      else {
        ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError, reason: "Can't parse context configuration \(self)"))
        return nil
    }
    return ContextConfiguration(teamConfiguration:teamConfiguration, projectConfiguration:projectConfiguration)
  }

  var teamConfiguration: TeamConfiguration? {
    guard let
      name = self["name"].string
      else {
        ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError, reason: "Can't parse team configuration \(self)"))
        return nil
    }

    let logoUrl = self["logo_url"].string

    return TeamConfiguration(logoUrl:logoUrl, name:name)
  }

  var projectBranding: ProjectBranding? {
    guard let iconPrimaryColor = self["icon_primary_color"].string,
          let iconSecondaryColor = self["icon_secondary_color"].string,
          let iconTertiaryColor = self["icon_tertiary_color"].string,
          let textPrimaryColor = self["text_primary_color"].string,
          let textSecondaryColor = self["text_secondary_color"].string,
          let textTertiaryColor = self["text_tertiary_color"].string,
          let textTopBarColor = self["text_topbar_color"].string,
          let textLinkColor = self["text_link_color"].string,
          let uiPrimaryColor = self["ui_primary_color"].string,
          let uiSecondaryColor = self["ui_secondary_color"].string,
          let uiTertiaryColor = self["ui_tertiary_color"].string,
          let uiErrorColor = self["ui_error_color"].string,
          let uiSuccessColor = self["ui_success_color"].string,
          let uiTheme = self["ui_theme"].string else {
      return nil
    }
    let logoUrl = self["logo_url"].string
    return ProjectBranding(iconPrimaryColor: iconPrimaryColor,
                           iconSecondaryColor: iconSecondaryColor,
                           iconTertiaryColor: iconTertiaryColor,
                           textPrimaryColor: textPrimaryColor,
                           textSecondaryColor: textSecondaryColor,
                           textTertiaryColor: textTertiaryColor,
                           textTopBarColor: textTopBarColor,
                           textLinkColor: textLinkColor,
                           uiPrimaryColor: uiPrimaryColor,
                           uiSecondaryColor: uiSecondaryColor,
                           uiTertiaryColor: uiTertiaryColor,
                           uiErrorColor: uiErrorColor,
                           uiSuccessColor: uiSuccessColor,
                           logoUrl: logoUrl,
                           uiTheme: uiTheme)
  }

  var allowedCountries: [Country]? {
    return self.arrayValue.map {
      return Country(isoCode: $0.stringValue)
    }
  }

  var projectConfiguration: ProjectConfiguration? {
    guard let name = self["name"].string,
          let salaryFrequencies = self["salary_frequencies"].linkObject as? [Any],
          let incomeTypes = self["income_types"].linkObject as? [Any],
          let housingTypes = self["housing_types"].linkObject as? [Any],
          let timeAtAddressOptions = self["time_at_address_values"].linkObject as? [Any],
          let creditScoreOptions = self["credit_score_values"].linkObject as? [Any],
          let grossIncomeMax = self["gross_income_max"].double,
          let grossIncomeMin = self["gross_income_min"].double,
          let grossIncomeIncrements = self["gross_income_increments"].double,
          let grossIncomeDefault = self["gross_income_default"].double,
          let language = self["language"].string,
          let welcomeScreenAction = self["welcome_screen_action"].linkObject as? WorkflowAction,
          let branding = self["project_branding"].projectBranding else {
      ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError,
                                                            reason: "Can't parse project configuration \(self)"))
      return nil
    }

    let summary = self["summary"].string
    let primaryAuthCredential = DataPointType.from(typeName:self["primary_auth_credential"].string) ?? .phoneNumber
    let secondaryAuthCredential = DataPointType.from(typeName:self["secondary_auth_credential"].string) ?? .email

    let parsedSalaryFrequencies = salaryFrequencies.compactMap { obj -> SalaryFrequency? in
      return obj as? SalaryFrequency
    }
    let parsedIncomeTypes = incomeTypes.compactMap { obj -> IncomeType? in
      return obj as? IncomeType
    }
    let parsedHousingTypes = housingTypes.compactMap { obj -> HousingType? in
      return obj as? HousingType
    }
    let parsedTimeAtAddressOptions = timeAtAddressOptions.compactMap { obj -> TimeAtAddressOption? in
      return obj as? TimeAtAddressOption
    }
    let parsedCreditScoreOptions = creditScoreOptions.compactMap { obj -> CreditScoreOption? in
      return obj as? CreditScoreOption
    }

    var products:[Product] = []
    if let _products = self["products"].linkObject as? [Any] {
      let parsedProducts = _products.compactMap { obj -> Product? in
        return obj as? Product
      }
      products = parsedProducts
    }
    let allowedCountries = self["allowed_countries"].allowedCountries

    // TODO: Receive these parameters from the server
    let allowUserLogin = true
    let skipSteps = false
    let strictAddressValidation = true
    let googleGeocodingAPIKey = "AIzaSyAj21pmvNCyCzFqYq2D3nL4FwYPCzpHwRA"
    let defaultCountryCode = 1
    let grossIncomeRange = AmountRangeConfiguration(min: grossIncomeMin,
                                                    max: grossIncomeMax,
                                                    def: grossIncomeDefault,
                                                    inc: grossIncomeIncrements)

    // Support Email Address
    let supportEmailAddress = self["support_source_address"].string

    // Set the project language
    LocalLanguage.language = language

    return ProjectConfiguration(name:name,
                                summary: summary,
                                allowUserLogin: allowUserLogin,
                                primaryAuthCredential: primaryAuthCredential,
                                secondaryAuthCredential: secondaryAuthCredential,
                                skipSteps: skipSteps,
                                strictAddressValidation: strictAddressValidation,
                                googleGeocodingAPIKey: googleGeocodingAPIKey,
                                defaultCountryCode: defaultCountryCode,
                                products: products,
                                incomeTypes: parsedIncomeTypes,
                                housingTypes: parsedHousingTypes,
                                salaryFrequencies: parsedSalaryFrequencies,
                                timeAtAddressOptions: parsedTimeAtAddressOptions,
                                creditScoreOptions: parsedCreditScoreOptions,
                                grossIncomeRange: grossIncomeRange,
                                welcomeScreenAction: welcomeScreenAction,
                                supportEmailAddress: supportEmailAddress,
                                branding: branding,
                                allowedCountries: allowedCountries)
  }

  var linkConfiguration: LinkConfiguration? {
    guard let
      loanAmountMin = self["loan_amount_min"].double,
      let loanAmountMax = self["loan_amount_max"].double,
      let loanAmountIncrements = self["loan_amount_increments"].double,
      let loanAmountDefault = self["loan_amount_default"].double,
      let posMode = self["pos_mode"].bool,
      let skipLoanAmount = self["skip_loan_amount"].bool,
      let skipLoanPurpose = self["skip_loan_purpose"].bool,
      let offerListStyle = self["offer_list_style"].string,
      let loanPurposes = self["loan_purposes"].linkObject as? [Any],
      let loanProducts = self["loan_products"].linkObject as? [Any],
      let userRequiredData = self["user_required_data"].linkObject as? [Any]
      else {
        ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError, reason: "Can't parse link configuration \(self)"))
        return nil
    }

    let parsedLoanPurposes = loanPurposes.compactMap { obj -> LoanPurpose? in
      return obj as? LoanPurpose
    }
    let parsedLoanProducts = loanProducts.compactMap { obj -> LoanProduct? in
      return obj as? LoanProduct
    }
    let parsedUserRequiredData = userRequiredData.compactMap { obj -> RequiredDataPoint? in
      return obj as? RequiredDataPoint
    }

    let userRequiredDataList = RequiredDataPointList()
    for requiredDataPoint in parsedUserRequiredData {
      userRequiredDataList.add(requiredDataPoint: requiredDataPoint)
    }

    var parsedOfferListStyle = OfferListStyle.list
    switch offerListStyle {
    case "list": parsedOfferListStyle = .list
    case "carousel": parsedOfferListStyle = .carousel
    default: break
    }

    let loanAmountRange = AmountRangeConfiguration(min: loanAmountMin,
                                                   max: loanAmountMax,
                                                   def: loanAmountDefault,
                                                   inc: loanAmountIncrements)

    return LinkConfiguration(loanAmountRange: loanAmountRange,
                             offerListStyle:parsedOfferListStyle,
                             posMode:posMode,
                             loanPurposes:parsedLoanPurposes,
                             loanProducts: parsedLoanProducts,
                             skipLoanAmount: skipLoanAmount,
                             skipLoanPurpose: skipLoanPurpose,
                             userRequiredData:userRequiredDataList)

  }

  var bankOauthConfig: BankOauthConfiguration? {
    guard let
      rawEnvironment = self["environment"].string,
      let rawProduct = self["product"].string,
      let publicApiKey = self["public_api_key"].string
      else {
        ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError, reason: "Can't parse bank oauth config \(self)"))
        return nil
    }

    var environment: PLKEnvironment
    var product: PLKProduct

    switch rawEnvironment {
    case "development":
      environment = .development
    case "sandbox":
      environment = .sandbox
    case "production":
      environment = .production
    case "tartan":
      environment = .tartan
    default:
      environment = .development
    }

    switch rawProduct {
    case "auth":
      product = .auth
    case "connect":
      product = .connect
    case "identity":
      product = .identity
    case "income":
      product = .income
    case "info":
      product = .info
    default:
      product = .auth
    }

    return BankOauthConfiguration(environment: environment, product: product, publicApiKey: publicApiKey)
  }

  var cardConfiguration: ShiftCardConfiguration? {
    guard let cardProduct = self["card_product"].cardProduct else {
      ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError,
                                                            reason: "Can't parse card config \(self)"))
      return nil
    }

    return ShiftCardConfiguration(cardProduct: cardProduct)
  }

  var cardProduct: ShiftCardProduct? {
    guard
      let id = self["id"].string,
      let teamId = self["team_id"].string,
      let name = self["name"].string,
      let rawStatus = self["status"].string, let status = ShiftCardProductStatus(rawValue: rawStatus),
      let shared = self["shared"].bool,
      let disclaimerAction = self["disclaimer_action"].workflowAction,
      let cardIssuer = self["card_issuer"].string else {
        ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError,
                                                              reason: "Can't parse card product \(self)"))
        return nil
    }

    // Optional properties
    let summary = self["name"].string
    let website = self["website"].string
    let cardholderAgreement = self["cardholder_agreement"].content
    let privacyPolicy = self["privacy_policy"].content
    let termsAndConditions = self["terms_of_service"].content
    let faq = self["faq"].content

    return ShiftCardProduct(id: id,
                            teamId: teamId,
                            name: name,
                            summary: summary,
                            website: website,
                            cardholderAgreement: cardholderAgreement,
                            privacyPolicy: privacyPolicy,
                            termsAndConditions: termsAndConditions,
                            faq: faq,
                            status: status,
                            shared: shared,
                            disclaimerAction: disclaimerAction,
                            cardIssuer: cardIssuer)
  }

  var cardApplication: CardApplication? {
    guard
      let id = self["id"].string,
      let rawStatus = self["status"].string,
      let status = CardApplicationStatus(rawValue: rawStatus),
      let createTime = self["create_time"].double,
      let applicationDate = Date.timeFromJSONAPIFormat(createTime),
      let nextAction = self["next_action"].workflowAction,
      let workflowObjectId = self["workflow_object_id"].string else {
        ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError,
                                                              reason: "Can't parse card application \(self)"))
        return nil
    }

    return CardApplication(id: id,
                           status: status,
                           applicationDate:
                           applicationDate,
                           workflowObjectId: workflowObjectId,
                           nextAction: nextAction)
  }

  var team: Team? {
    guard let
      name = self["name"].string,
      let teamId = self["team_id"].string
      else {
        ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError, reason: "Can't parse team \(self)"))
        return nil
    }
    return Team(teamId: teamId, name: name)
  }

  var project: Project? {
    guard let
      name = self["name"].string,
      let projectId = self["project_id"].string
      else {
        ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError, reason: "Can't parse project \(self)"))
        return nil
    }
    return Project(team: nil, projectId: projectId, name: name)
  }

  var product: Product? {
    guard let
      key = self["key"].string
      else {
        ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError, reason: "Can't parse product \(self)"))
        return nil
    }
    switch key {
    case "link": return .link
    default: return nil
    }
  }

  var lender: Lender? {
    guard let
      name = self["lender_name"].string
      else {
        ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError, reason: "Can't parse lender \(self)"))
        return nil
    }

    let bigIconUrl = self["large_image"].string
    let smallIconUrl = self["small_image"].string
    let about = self["about"].string

    return Lender(
      name:name,
      smallIconUrl:(smallIconUrl != nil) ? URL(string:smallIconUrl!) : nil,
      bigIconUrl:(bigIconUrl != nil) ? URL(string:bigIconUrl!) : nil,
      about:about
    )
  }

  var offerRequest: OfferRequest? {
    let rawOffers = self["offers"].linkObject
    guard let
      offerRequestId = self["offer_request_id"].string,
      let offers = rawOffers as? [Any]
      else {
        ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError, reason: "Can't parse offer request \(self)"))
        return nil
    }
    let parsedOffers = offers.compactMap { obj -> LoanOffer? in
      return obj as? LoanOffer
    }
    return OfferRequest(id:offerRequestId, offers: parsedOffers)
  }

  var offer: LoanOffer? {
    guard let
      applicationMethod = self["application_method"].string,
      let lender = self["lender"].lender,
      let offerId = self["id"].string,
      let loanProductId = self["loan_product"].string
      else {
        ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError, reason: "Can't parse loan offer \(self)"))
        return nil
    }

    let showApplicationSummary = self["show_application_summary"].bool ?? false
    let requiresFundingAccount = self["requiresFundingAccount"].bool ?? true
    let customMessage = self["offer_details"].string
    let currency = self["currency"].string
    let interestRate = self["interest_rate"].double
    let paymentCount = self["payment_count"].int
    let paymentAmount = self["payment_amount"].double
    let term = self["term"].term
    let loanAmount = self["loan_amount"].double

    return LoanOffer(
      id:offerId,
      loanProductId: loanProductId,
      lender:lender,
      loanAmount: (loanAmount != nil) ? Amount(value:loanAmount!, currency:currency) : nil,
      term: term,
      paymentAmount: (loanAmount != nil) ? Amount(value:paymentAmount, currency:currency) : nil,
      paymentCount: paymentCount,
      interestRate: interestRate,
      expirationDate: Date.dateFromJSONAPIFormat(self["expiration_date"].string),
      applicationMethod:applicationMethod == "api" ? .api : .url,
      customMessage:customMessage,
      showApplicationSummary:showApplicationSummary,
      requiresFundingAccount:requiresFundingAccount)
  }

  var term: Term? {
    guard let
      duration = self["duration"].int,
      let unit = self["unit"].int
      else {
        ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError, reason: "Can't parse team \(self)"))
        return nil
    }
    return Term(unit:(unit == 1 ? .week : .month), duration: duration)
  }

  var application: Any? {
    if self["application_type"].string == "card" {
      return self.cardApplication
    }
    return self.loanApplication
  }

  var loanApplication: LoanApplication? {
    guard let
      applicationId = self["id"].string,
      let offer = self["offer"].offer,
      let rawStatus = self["status"].string,
      let rawCreateTime = self["create_time"].double,
      let nextAction = self["next_action"].workflowAction
      else {
        ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError, reason: "Can't parse application \(self)"))
        return nil
    }

    guard let
      status = ApplicationStatus(rawValue: rawStatus),
      let applicationDate = Date.timeFromJSONAPIFormat(rawCreateTime) else
    {
      ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError, reason: "Can't parse application status or date \(self)"))
      return nil
    }

    let application = LoanApplication(
      id:applicationId,
      offer:offer,
      status:status,
      applicationDate: applicationDate,
      nextAction:nextAction
    )

    if let fundingAccount = self["funding_account"].linkObject as? FinancialAccount {
      application.fundingAccount = fundingAccount
    }

    if let repaymentAccount = self["repayment_account"].linkObject as? FinancialAccount {
      application.repaymentAccount = repaymentAccount
    }

    return application

  }

  var applicationSummary: LoanApplicationSummary? {
    guard let
      applicationId = self["application_id"].string,
      let rawStatus = self["state"].string,
      let rawCreateTime = self["timestamp"].string,
      let projectName = self["project_name"].string,
      let status = ApplicationStatus(rawValue: rawStatus.uppercased()),
      let applicationDate = Date.timeFromISO8601(rawCreateTime)
      else {
        ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError, reason: "Can't parse application summary \(self)"))
        return nil
    }

    let projectSummary = self["project_summary"].string
    let projectLogo = self["project_logo"].string
    let loanAmount = self["loan_amount"].double

    let applicationSummary = LoanApplicationSummary(
      id:applicationId,
      status:status,
      projectName: projectName,
      projectSummary: projectSummary,
      projectLogo: (projectLogo != nil) ? URL(string:projectLogo!) : nil,
      loanAmount: (loanAmount != nil) ? Amount(value:loanAmount, currency:"USD") : nil,
      createTime: applicationDate
    )

    return applicationSummary

  }

  var user: ShiftUser? {
    guard let userId = self["user_id"].string
      else {
        ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError, reason: "Can't parse user \(self)"))
        return nil
    }

    let dataPoints: DataPointList = DataPointList()
    if let userData = self["user_data"].linkObject as? [Any] {
      let parsedDataPoints = userData.compactMap { obj -> DataPoint? in
        return obj as? DataPoint
      }
      for dataPoint in parsedDataPoints {
        dataPoints.add(dataPoint: dataPoint)
      }
    }

    let accessToken = self.accessToken

    let retVal = ShiftUser(userId: userId,
                           accessToken: accessToken)
    retVal.userData = dataPoints
    return retVal
  }

  var address: Address? {
    let address = self["street_one"].string
    let city = self["locality"].string
    let region = self["region"].string
    let postalCode = self["postal_code"].string
    let apt = self["street_two"].string
    let verified = self["verified"].bool
    let country: Country?
    if let countryCode = self["country"].string {
      country = Country(isoCode: countryCode)
    }
    else {
      country = nil
    }
    return Address(address: address,
                   apUnit: apt,
                   country: country,
                   city: city,
                   region: region,
                   zip: postalCode,
                   verified: verified)
  }

  var verification: Verification? {
    guard let
      verificationId = self["verification_id"].string,
      let status = self["status"].string,
      let verificationType = self["verification_type"].string
      else {
        ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError, reason: "Can't parse verification \(self)"))
        return nil
    }
    let secret = self["secret"].string
    let retVal = Verification(verificationId:verificationId,
                              verificationType: verificationType == "birthdate" ? .birthDate : verificationType == "phone" ? .phoneNumber : .email,
                              status: status=="pending" ? .pending: status=="passed" ? .passed : .failed,
                              secret:secret)
    if let secondaryVerification = self["secondary_credential"].verification {
      retVal.secondaryCredential = secondaryVerification
    }

    if (self["verification_result"].dictionary != nil) {
      retVal.documentVerificationResult = self["verification_result"].documentVerificationResult
    }

    return retVal
  }

  var documentVerificationResult: DocumentVerificationResult? {
    guard let
      rawFaceComparisonResult = self["face_comparison_result"].string,
      let faceComparisonResult = FaceComparisonResult.faceComparisonResultFrom(description: rawFaceComparisonResult),
      let rawDocAuthenticity = self["doc_authenticity"].string,
      let docAuthenticity = DocumentAuthenticity.documentAuthenticityFrom(description: rawDocAuthenticity),
      let faceSimilarityRatio = self["face_similarity_ratio"].float,
      let rawDocCompletionStatus = self["doc_completion_status"].string,
      let docCompletionStatus = DocumentCompletionStatus.documentCompletionStatusFrom(description: rawDocCompletionStatus)
      else {
        ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError, reason: "Can't parse Document Verification Result \(self)"))
        return nil
    }

    let dataPoints: DataPointList = DataPointList()
    if let userData = self["user_data"].linkObject as? [Any] {
      let parsedDataPoints = userData.compactMap { obj -> DataPoint? in
        return obj as? DataPoint
      }
      for dataPoint in parsedDataPoints {
        dataPoints.add(dataPoint: dataPoint)
      }
    }

    return DocumentVerificationResult(faceComparisonResult: faceComparisonResult,
                                      docAuthenticity: docAuthenticity,
                                      docCompletionStatus: docCompletionStatus,
                                      faceSimilarityRatio: faceSimilarityRatio,
                                      userData: dataPoints)
  }

  var phone: PhoneNumber? {
    guard let countryCode = Int(self["country_code"].string) ?? self["country_code"].int,
          let phoneNumber = self["phone_number"].string else {
      ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError,
                                                            reason: "Can't parse phone number \(self)"))
      return nil
    }
    let verified = self["verified"].bool
    return PhoneNumber(countryCode: countryCode, phoneNumber: phoneNumber, verified: verified)
  }

  var email: Email? {
    guard let notSpecified = self["not_specified"].bool else {
      ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError,
                                                            reason: "Can't parse email \(self)"))
      return nil
    }
    let verified = self["verified"].bool
    if notSpecified {
      return Email(email: nil, verified: verified, notSpecified: notSpecified)
    }
    else {
      guard let email = self["email"].string else {
        ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError,
                                                              reason: "Can't parse email \(self)"))
        return nil
      }
      return Email(email: email, verified: verified, notSpecified: false)
    }
  }

  var name: PersonalName? {
    guard let
      firstName = self["first_name"].string,
      let lastName = self["last_name"].string
      else {
        ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError, reason: "Can't parse personal name \(self)"))
        return nil
    }
    let verified = self["verified"].bool
    return PersonalName(firstName: firstName, lastName: lastName, verified:verified)
  }

  var idDocument: IdDocument? {
    let documentType = IdDocumentType.from(string: self["doc_type"].string)
    let value = self["value"].string ?? SSNTextValidator.unknownValidSSN
    let country: Country?
    if let countryCode = self["country"].string {
      country = Country(isoCode: countryCode)
    }
    else {
      country = nil
    }
    let notSpecified = self["not_specified"].bool
    return IdDocument(documentType: documentType,
                      value: value,
                      country: country,
                      verified: false,
                      notSpecified: notSpecified)
  }

  var birthDate: BirthDate? {
    guard let
      date = Date.dateFromJSONAPIFormat(self["date"].string)
      else {
        ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError, reason: "Can't parse birthdate \(self)"))
        return nil
    }
    let verified = self["verified"].bool
    return BirthDate(date: date, verified:verified)
  }

  var store: Store? {
    let storeId = self["id"].string
    let storeKey = self["key"].string
    let name = self["name"].string
    let address = self["address"].address
    let merchant = self["merchant"].merchant
    let latitude = self["location"]["latitude"].double
    let longitude = self["location"]["longitude"].double

    return Store(
      id: storeId,
      storeKey: storeKey,
      name: name,
      latitude: latitude,
      longitude: longitude,
      address: address,
      merchant:merchant)
  }

  var merchant: Merchant? {
    let merchantId = self["id"].string
    let merchantKey = self["key"].string
    let mcc = self["mcc"].linkObject as? MCC
    let name = self["name"].string

    return Merchant(
      id: merchantId,
      merchantKey: merchantKey,
      name: name,
      mcc: mcc)
  }

  var mcc: MCC? {
    guard
      let name = self["name"].string,
      let rawIcon = self["icon"].string,
      let icon = MCCIcon(rawValue: rawIcon)
      else {
        ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError, reason: "Can't parse mcc entity \(self)"))
        return nil
    }
    return MCC(
      code: nil,
      name: name,
      icon: icon)
  }

  var bankAccount: BankAccount? {
    guard let
      id = self["account_id"].string,
      let bankName = self["bank_name"].string,
      let lastFourDigits = self["last_four"].string
      else {
        ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError, reason: "Can't parse bank account \(self)"))
        return nil
    }
    let verified = self["verified"].bool
    return BankAccount(accountId: id, bankName: bankName, lastFourDigits: lastFourDigits, state: .active, verified:verified)
  }

  var card: Card? {
    guard let
      id = self["account_id"].string,
      let state = self["state"].string,
      let lastFourDigits = self["last_four"].string,
      let expiration = self["expiration"].string
      else {
        ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError, reason: "Can't parse card \(self)"))
        return nil
    }
    guard let cState = FinancialAccountState.stateFrom(description: state) else {
      return nil
    }

    let verified = self["verified"].bool
    let cardIssuer = self["card_issuer"].string
    let cardNetwork = self["card_network"].string
    let cardBrand = self["card_brand"].string
    let issuer = CardIssuer.issuerFrom(description: cardIssuer)
    let spendableToday = self["spendable_today"].amount
    let nativeSpendableToday = self["native_spendable_today"].amount
    let physicalCardActivationRequired = self["physical_card_activation_required"].bool
    let cardFeatures = self["features"].cardFeatures
    let cardStyle = self["card_style"].cardStyle

    let card = Card(accountId: id,
                    cardNetwork: CardNetwork.cardNetworkFrom(description: cardNetwork),
                    cardIssuer: issuer,
                    cardBrand: cardBrand,
                    state: cState,
                    lastFourDigits: lastFourDigits,
                    expiration: expiration,
                    spendableToday: spendableToday,
                    nativeSpendableToday: nativeSpendableToday,
                    kyc: self.kyc,
                    physicalCardActivationRequired: physicalCardActivationRequired,
                    features: cardFeatures,
                    cardStyle: cardStyle,
                    verified:verified)

    if let pan = self["pan"].string {
      card.pan = pan
    }
    if let cvv = self["cvv"].string {
      card.cvv = cvv
    }

    return card
  }

  var transaction: Transaction? {

    guard let
      transactionId = self["id"].string,
      let rawCreatedAt = self["created_at"].double
      else {
        ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError, reason: "Can't parse transaction \(self)"))
        return nil
    }

    let createdAt: Date = Date(timeIntervalSince1970: rawCreatedAt)
    let externalTransactionId = self["external_id"].string
    let cardNetwork = CardNetwork.cardNetworkFrom(description: self["network"].string)
    let state = TransactionState.transactionStateFrom(description: self["state"].string)
    let transactionType = TransactionType.from(typeName: self["transaction_type"].string)
    let transationDescription = self["description"].string
    let lastMessage = self["last_message"].string
    let declineReason = self["decline_reason"].string
    let ecommerce = self["ecommerce"].bool
    let international = self["international"].bool
    let cardPresent = self["card_present"].bool
    let emv = self["emv"].bool
    let merchant = self["merchant"].linkObject as? Merchant
    let store = self["store"].linkObject as? Store
    let localAmount = self["local_amount"].linkObject as? Amount
    let billingAmount = self["billing_amount"].linkObject as? Amount
    let holdAmount = self["hold_amount"].linkObject as? Amount
    let cashbackAmount = self["cashback_amount"].linkObject as? Amount
    let feeAmount = self["fee_amount"].linkObject as? Amount
    let nativeBalance = self["native_balance"].linkObject as? Amount

    let settlement = self["settlement"].linkObject as? TransactionSettlement
    let adjustments = self["adjustments"].linkObject as? [TransactionAdjustment]

    let transaction = Transaction(transactionId: transactionId,
                                  transactionType: transactionType,
                                  createdAt: createdAt,
                                  externalTransactionId: externalTransactionId,
                                  transactionDescription: transationDescription,
                                  lastMessage: lastMessage,
                                  declineReason: declineReason,
                                  merchant: merchant,
                                  store: store,
                                  localAmount: localAmount,
                                  billingAmount: billingAmount,
                                  holdAmount: holdAmount,
                                  cashbackAmount: cashbackAmount,
                                  feeAmount: feeAmount,
                                  nativeBalance: nativeBalance,
                                  settlement: settlement,
                                  ecommerce: ecommerce,
                                  international: international,
                                  cardPresent: cardPresent,
                                  emv: emv,
                                  cardNetwork: cardNetwork,
                                  state: state,
                                  adjustments: adjustments)

    return transaction
  }

  var transactionSettlement: TransactionSettlement? {
    guard
      let rawCreatedAt = self["date"].double
      else {
        ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError, reason: "Can't parse transactionSettlement \(self)"))
        return nil
    }

    let createdAt: Date = Date(timeIntervalSince1970: rawCreatedAt)
    let amount = self["amount"].linkObject as? Amount
    return TransactionSettlement(createdAt: createdAt, amount: amount)
  }

  var transactionAdjustment: TransactionAdjustment? {

    let id = self["id"].string
    let rawCreatedAt = self["created_at"].double
    let createdAt: Date? = rawCreatedAt != nil ? Date(timeIntervalSince1970: rawCreatedAt!) : nil
    let externalId = self["external_id"].string
    let type = TransactionAdjustmentType.from(typeName: self["adjustment_type"].string)
    let localAmount = self["local_amount"].linkObject as? Amount
    let nativeAmount = self["native_amount"].linkObject as? Amount
    let fundingSourceName = self["funding_source_name"].string
    let exchangeRate = self["exchange_rate"].double

    return TransactionAdjustment(id: id,
                                 externalId: externalId,
                                 createdAt: createdAt,
                                 localAmount: localAmount,
                                 nativeAmount: nativeAmount,
                                 exchangeRate: exchangeRate,
                                 type: type,
                                 fundingSourceName: fundingSourceName)

  }

  var fundingSource: FundingSource? {
    guard let fundingSourceId = self["id"].string,
          let rawFundingSourceType = self["funding_source_type"].string,
          let rawState = self["state"].string, let state = FundingSourceState(rawValue: rawState) else {
      ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError,
                                                            reason: "Can't parse funding source \(self)"))
      return nil
    }

    var fsType: FundingSourceType? = nil
    if rawFundingSourceType == "custodian_wallet" {
      fsType = .custodianWallet
    }
    guard let fundingSourceType = fsType else {
      ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError,
                                                            reason: "Can't parse funding source type \(self)"))
      return nil
    }

    var balance: Amount? = nil
    if self["balance"].dictionary != nil {
      balance = self["balance"].linkObject as? Amount
    }

    var amountSpendable: Amount? = nil
    if self["amount_spendable"].dictionary != nil {
      amountSpendable = self["amount_spendable"].linkObject as? Amount
    }

    var amountHeld: Amount? = nil
    if self["amount_held"].dictionary != nil {
      amountHeld = self["amount_held"].linkObject as? Amount
    }

    switch fundingSourceType {
    case .custodianWallet:
      guard let nativeBalance = self["details"]["balance"].linkObject as? Amount,
            let custodian = self["details"]["custodian"].linkObject as? Custodian else {
        ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError,
                                                              reason: "Can't parse custodian wallet \(self)"))
        return nil
      }

      return CustodianWallet(fundingSourceId: fundingSourceId,
                             nativeBalance: nativeBalance,
                             usdBalance: balance,
                             usdAmountSpendable: amountSpendable,
                             usdAmountHold: amountHeld,
                             state: state,
                             custodian: custodian)
    }
  }

  var kyc: KYCState? {
    if let rawKYCState = self["kyc_status"].string {
      return KYCState.stateFrom(description: rawKYCState)
    }
    return nil
  }

  var custodian: Custodian? {
    guard let rawCustodianType = self["custodian_type"].string,
          let name = self["name"].string,
          let custodianType = CustodianType(rawValue: rawCustodianType) else {
      ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError,
                                                            reason: "Can't parse custodian \(self)"))
      return nil
    }

    return Custodian(custodianType: custodianType, name: name)
  }

  var oauthAttempt: OauthAttempt? {
    guard let id = self["id"].string,
          let rawStatus = self["status"].string,
          let status = OauthAttempt.Status(rawValue: rawStatus) else {
      ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError,
                                                            reason: "Can't parse oauth attempt \(self)"))
      return nil
    }

    var url: URL? = nil
    if let urlString = self["url"].string {
      url = URL(string:urlString)
    }
    var credentials: OauthCredential? = nil
    if let accessToken = self["tokens"]["access"].string, let refreshToken = self["tokens"]["refresh"].string {
      let dataPointList = DataPointList()
      if let dataPointFields = self["user_data"]["data"].array {
        dataPointFields.compactMap {
          return $0.linkObject as? DataPoint
        }.forEach {
          dataPointList.add(dataPoint: $0)
        }
      }
      let userData = !dataPointList.isEmpty ? dataPointList : nil
      credentials = OauthCredential(oauthToken: accessToken, refreshToken: refreshToken, userData: userData)
    }

    return OauthAttempt(id: id, status: status, url: url, credentials: credentials)
  }

  var amount: Amount? {
    guard let
      currency = self["currency"].string,
      let amount = self["amount"].double
      else {
        ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError, reason: "Can't parse amount \(self)"))
        return nil
    }
    return Amount(value: amount, currency: currency)
  }

  fileprivate func unify(requiredActions:[RequiredAction]) -> [RequiredAction] {
    var documents: [RequiredDocument] = []
    var retVal = requiredActions.compactMap { (action:RequiredAction) -> RequiredAction? in
      switch action {
      case .uploadDoc(let requiredDocuments):
        documents.append(contentsOf: requiredDocuments)
        return nil
      default:
        return action
      }
    }
    if documents.count > 0 {
      retVal.append(.uploadDoc(documents))
    }
    return retVal
  }

}
