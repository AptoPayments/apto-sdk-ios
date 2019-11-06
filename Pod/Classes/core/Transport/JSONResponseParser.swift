//
//  JSONResponseSerializer.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 29/02/16.
//
//

import Foundation
import SwiftyJSON

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
      guard !jsonList.isEmpty else {
        let retVal: [Any] = []
        return retVal
      }
      return jsonList.compactMap { json -> Any? in
        return json.linkObject
      }
    case "access_token":
      return self.accessToken
    case "content":
      return self.content
    case "context_configuration":
      return self.contextConfiguration
    case "team_configuration":
      return self.teamConfiguration
    case "project_configuration":
      return self.projectConfiguration
    case "card_product":
      return self.cardProduct
    case "application":
      return self.application
    case "card":
      return self.card
    case "card_details":
      return self.cardDetails
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
    case "action_issue_card_config":
      return self.issueCardActionConfiguration
    case "category_spending":
      return self.categorySpending
    case "monthly_spending":
      return self.monthlySpending
    case "monthly_statement_report":
      return self.monthlyStatementReport
    case "month":
      return self.month
    case "monthly_statements_period":
      return self.monthlyStatementsPeriod
    case "action_waitlist_config":
      return self.waitListActionConfiguration
    case "notification_preferences":
      return self.notificationPreferences
    case "notification_group":
      return self.notificationGroup
    case "card_product_summary":
      return self.cardProductSummary
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
    guard let token = self["user_token"].string else {
      ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError,
                                                            reason: "Can't parse accessToken \(self)"))
      return nil
    }
    return AccessToken(token: token, primaryCredential: nil, secondaryCredential: nil)
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

  var content: Content? {
    guard let format = self["format"].string else {
      ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError,
                                                            reason: "Can't parse content \(self)"))
      return nil
    }
    if format == "native_content" {
      let content = self["value"].nativeContent
      return .nativeContent(content)
    }
    guard let value = self["value"].string else {
      ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError,
                                                            reason: "Can't parse content \(self)"))
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

  var nativeContent: NativeContent {
    let asset = self["asset"].string
    let backgroundImage = self["background_image"].string
    let backgroundColor = self["background_color"].string
    return NativeContent(asset: asset, backgroundImage: backgroundImage, backgroundColor: backgroundColor)
  }

  var contextConfiguration: ContextConfiguration? {
    guard let projectConfiguration = self["project"].projectConfiguration,
          let teamConfiguration = self["team"].teamConfiguration else {
      ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError,
                                                            reason: "Can't parse context configuration \(self)"))
      return nil
    }
    return ContextConfiguration(teamConfiguration: teamConfiguration, projectConfiguration: projectConfiguration)
  }

  var teamConfiguration: TeamConfiguration? {
    guard let name = self["name"].string else {
      ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError,
                                                            reason: "Can't parse team configuration \(self)"))
      return nil
    }

    let logoUrl = self["logo_url"].string
    return TeamConfiguration(logoUrl: logoUrl, name: name)
  }

  var projectBranding: ProjectBranding? {
    guard let iconPrimaryColor = self["icon_primary_color"].string,
          let iconSecondaryColor = self["icon_secondary_color"].string,
          let iconTertiaryColor = self["icon_tertiary_color"].string,
          let textPrimaryColor = self["text_primary_color"].string,
          let textSecondaryColor = self["text_secondary_color"].string,
          let textTertiaryColor = self["text_tertiary_color"].string,
          let textTopBarPrimaryColor = self["text_topbar_primary_color"].string,
          let textTopBarSecondaryColor = self["text_topbar_secondary_color"].string,
          let textLinkColor = self["text_link_color"].string,
          let textLinkUnderlined = self["text_link_underlined"].bool,
          let textButtonColor = self["text_button_color"].string,
          let buttonCornerRadius = self["button_corner_radius"].float,
          let uiPrimaryColor = self["ui_primary_color"].string,
          let uiSecondaryColor = self["ui_secondary_color"].string,
          let uiTertiaryColor = self["ui_tertiary_color"].string,
          let uiErrorColor = self["ui_error_color"].string,
          let uiSuccessColor = self["ui_success_color"].string,
          let uiBackgroundPrimaryColor = self["ui_bg_primary_color"].string,
          let uiBackgroundSecondaryColor = self["ui_bg_secondary_color"].string,
          let uiNavigationBarPrimaryColor = self["ui_nav_primary_color"].string,
          let uiNavigationBarSecondaryColor = self["ui_nav_secondary_color"].string,
          let uiBackgroundOverlayColor = self["ui_bg_overlay_color"].string,
          let textMessageColor = self["text_message_color"].string,
          let badgeBackgroundPositiveColor = self["badge_bg_positive_color"].string,
          let badgeBackgroundNegativeColor = self["badge_bg_negative_color"].string,
          let showToastTitle = self["show_toast_title"].bool,
          let transactionDetailsCollapsable = self["txn_details_collapsable"].bool,
          let disclaimerBackgroundColor = self["disclaimer_background_color"].string,
          let uiStatusBarStyle = self["ui_status_bar_style"].string,
          let uiTheme = self["ui_theme"].string else {
      return nil
    }
    let logoUrl = self["logo_url"].string
    return ProjectBranding(uiBackgroundPrimaryColor: uiBackgroundPrimaryColor,
                           uiBackgroundSecondaryColor: uiBackgroundSecondaryColor,
                           iconPrimaryColor: iconPrimaryColor,
                           iconSecondaryColor: iconSecondaryColor,
                           iconTertiaryColor: iconTertiaryColor,
                           textPrimaryColor: textPrimaryColor,
                           textSecondaryColor: textSecondaryColor,
                           textTertiaryColor: textTertiaryColor,
                           textTopBarPrimaryColor: textTopBarPrimaryColor,
                           textTopBarSecondaryColor: textTopBarSecondaryColor,
                           textLinkColor: textLinkColor,
                           textLinkUnderlined: textLinkUnderlined,
                           textButtonColor: textButtonColor,
                           buttonCornerRadius: buttonCornerRadius,
                           uiPrimaryColor: uiPrimaryColor,
                           uiSecondaryColor: uiSecondaryColor,
                           uiTertiaryColor: uiTertiaryColor,
                           uiErrorColor: uiErrorColor,
                           uiSuccessColor: uiSuccessColor,
                           uiNavigationPrimaryColor: uiNavigationBarPrimaryColor,
                           uiNavigationSecondaryColor: uiNavigationBarSecondaryColor,
                           uiBackgroundOverlayColor: uiBackgroundOverlayColor,
                           textMessageColor: textMessageColor,
                           badgeBackgroundPositiveColor: badgeBackgroundPositiveColor,
                           badgeBackgroundNegativeColor: badgeBackgroundNegativeColor,
                           showToastTitle: showToastTitle,
                           transactionDetailsCollapsable: transactionDetailsCollapsable,
                           disclaimerBackgroundColor: disclaimerBackgroundColor,
                           uiStatusBarStyle: uiStatusBarStyle,
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
          let language = self["language"].string,
          let welcomeScreenAction = self["welcome_screen_action"].linkObject as? WorkflowAction,
          let branding = self["project_branding"].projectBranding else {
      ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError,
                                                            reason: "Can't parse project configuration \(self)"))
      return nil
    }

    let summary = self["summary"].string
    let primaryAuthCredential = DataPointType.from(typeName: self["primary_auth_credential"].string) ?? .phoneNumber
    let secondaryAuthCredential = DataPointType.from(typeName: self["secondary_auth_credential"].string) ?? .email

    var products: [Product] = []
    if let returnedProducts = self["products"].linkObject as? [Any] {
      let parsedProducts = returnedProducts.compactMap { obj -> Product? in
        return obj as? Product
      }
      products = parsedProducts
    }
    let allowedCountries = self["allowed_countries"].allowedCountries

    // TODO: Receive these parameters from the server
    let allowUserLogin = true
    let skipSteps = false
    let strictAddressValidation = true
    let defaultCountryCode = 1

    // Support Email Address
    let supportEmailAddress = self["support_source_address"].string

    // Set the project language
    LocalLanguage.language = language

    // Read the copies
    if let copies = self["labels"].dictionaryObject as? [String: String] {
      StringLocalizationStorage.shared.append(copies)
    }

    // Read tracker
    let isTrackerActive = self["tracker_active"].bool
    let trackerAccessToken = self["tracker_access_token"].string

    return ProjectConfiguration(name: name,
                                summary: summary,
                                allowUserLogin: allowUserLogin,
                                primaryAuthCredential: primaryAuthCredential,
                                secondaryAuthCredential: secondaryAuthCredential,
                                skipSteps: skipSteps,
                                strictAddressValidation: strictAddressValidation,
                                defaultCountryCode: defaultCountryCode,
                                products: products,
                                welcomeScreenAction: welcomeScreenAction,
                                supportEmailAddress: supportEmailAddress,
                                branding: branding,
                                allowedCountries: allowedCountries,
                                isTrackerActive: isTrackerActive,
                                trackerAccessToken: trackerAccessToken)
  }

  var cardProduct: CardProduct? {
    guard let id = self["id"].string, let teamId = self["team_id"].string, let name = self["name"].string,
          let rawStatus = self["status"].string, let status = CardProductStatus(rawValue: rawStatus),
          let shared = self["shared"].bool, let disclaimerAction = self["disclaimer_action"].workflowAction,
          let cardIssuer = self["card_issuer"].string else {
      ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError,
                                                            reason: "Can't parse card product \(self)"))
      return nil
    }

    // Copies
    if let copies = self["labels"].dictionaryObject as? [String: String] {
      StringLocalizationStorage.shared.append(copies)
    }

    // Optional properties
    let summary = self["name"].string
    let website = self["website"].string
    let cardholderAgreement = self["cardholder_agreement"].content
    let privacyPolicy = self["privacy_policy"].content
    let termsAndConditions = self["terms_of_service"].content
    let faq = self["faq"].content
    let waitListBackgroundImage = self["wait_list_background_image"].string
    let waitListBackgroundColor = self["wait_list_background_color"].string
    let waitListAsset = self["wait_list_asset"].string

    return CardProduct(id: id,
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
                       cardIssuer: cardIssuer,
                       waitListBackgroundImage: waitListBackgroundImage,
                       waitListBackgroundColor: waitListBackgroundColor,
                       waitListAsset: waitListAsset)
  }

  var cardApplication: CardApplication? {
    guard let id = self["id"].string, let rawStatus = self["status"].string,
          let status = CardApplicationStatus(rawValue: rawStatus), let createTime = self["create_time"].double,
          let applicationDate = Date.timeFromJSONAPIFormat(createTime),
          let nextAction = self["next_action"].workflowAction,
          let workflowObjectId = self["workflow_object_id"].string else {
      ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError,
                                                              reason: "Can't parse card application \(self)"))
      return nil
    }

    return CardApplication(id: id,
                           status: status,
                           applicationDate: applicationDate,
                           workflowObjectId: workflowObjectId,
                           nextAction: nextAction)
  }

  var product: Product? {
    guard let key = self["key"].string else {
      ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError,
                                                            reason: "Can't parse product \(self)"))
      return nil
    }
    switch key {
    case "link": return .link
    default: return nil
    }
  }

  var application: Any? {
    guard self["application_type"].string == "card" else {
      return nil
    }
    return self.cardApplication
  }

  var user: ShiftUser? {
    guard let userId = self["user_id"].string else {
      ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError,
                                                            reason: "Can't parse user \(self)"))
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
    guard let verificationId = self["verification_id"].string, let status = self["status"].string,
          let verificationType = self["verification_type"].string else {
      ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError,
                                                            reason: "Can't parse verification \(self)"))
      return nil
    }
    let secret = self["secret"].string
    let type: DataPointType = verificationType == "birthdate" ? .birthDate
                                                              : verificationType == "phone" ? .phoneNumber : .email
    let retVal = Verification(verificationId: verificationId,
                              verificationType: type,
                              status: status == "pending" ? .pending: status == "passed" ? .passed : .failed,
                              secret: secret)
    if let secondaryVerification = self["secondary_credential"].verification {
      retVal.secondaryCredential = secondaryVerification
    }

    if self["verification_result"].dictionary != nil {
      retVal.documentVerificationResult = self["verification_result"].documentVerificationResult
    }

    return retVal
  }

  var documentVerificationResult: DocumentVerificationResult? {
    // swiftlint:disable line_length
    guard let rawFaceComparisonResult = self["face_comparison_result"].string,
          let faceComparisonResult = FaceComparisonResult.faceComparisonResultFrom(description: rawFaceComparisonResult),
          let rawDocAuthenticity = self["doc_authenticity"].string,
          let docAuthenticity = DocumentAuthenticity.documentAuthenticityFrom(description: rawDocAuthenticity),
          let faceSimilarityRatio = self["face_similarity_ratio"].float,
          let rawDocCompletionStatus = self["doc_completion_status"].string,
          let docCompletionStatus = DocumentCompletionStatus.documentCompletionStatusFrom(description: rawDocCompletionStatus)
      else {
        ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError,
                                                              reason: "Can't parse Document Verification Result \(self)"))
        return nil
    }
    // swiftlint:enable line_length

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
    let number = PhoneNumber(countryCode: countryCode, phoneNumber: phoneNumber, verified: verified)
    number.verification = self["verification"].verification
    return number
  }

  var email: Email? {
    guard let notSpecified = self["not_specified"].bool else {
      ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError,
                                                            reason: "Can't parse email \(self)"))
      return nil
    }
    let verified = self["verified"].bool
    let emailAddress: Email
    if notSpecified {
      emailAddress = Email(email: nil, verified: verified, notSpecified: notSpecified)
    }
    else {
      guard let email = self["email"].string else {
        ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError,
                                                              reason: "Can't parse email \(self)"))
        return nil
      }
      emailAddress = Email(email: email, verified: verified, notSpecified: false)
    }
    emailAddress.verification = self["verification"].verification
    return emailAddress
  }

  var name: PersonalName? {
    guard let firstName = self["first_name"].string, let lastName = self["last_name"].string else {
      ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError,
                                                            reason: "Can't parse personal name \(self)"))
      return nil
    }
    let verified = self["verified"].bool
    return PersonalName(firstName: firstName, lastName: lastName, verified: verified)
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
    guard let date = Date.dateFromJSONAPIFormat(self["date"].string) else {
      ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError,
                                                            reason: "Can't parse birthdate \(self)"))
      return nil
    }
    let verified = self["verified"].bool
    let birthdate = BirthDate(date: date, verified: verified)
    birthdate.verification = self["verification"].verification
    return birthdate
  }

  var store: Store? {
    let storeId = self["id"].string
    let storeKey = self["key"].string
    let name = self["name"].string
    let address = self["address"].address
    let merchant = self["merchant"].merchant
    let latitude = self["location"]["latitude"].double
    let longitude = self["location"]["longitude"].double

    return Store(id: storeId, storeKey: storeKey, name: name, latitude: latitude, longitude: longitude,
                 address: address, merchant: merchant)
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
    guard let name = self["name"].string, let rawIcon = self["icon"].string,
          let icon = MCCIcon(rawValue: rawIcon) else {
      ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError,
                                                            reason: "Can't parse mcc entity \(self)"))
      return nil
    }
    return MCC(code: nil, name: name, icon: icon)
  }

  var card: Card? {
    guard let id = self["account_id"].string, let state = self["state"].string,
          let lastFourDigits = self["last_four"].string else {
      ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError,
                                                            reason: "Can't parse card \(self)"))
      return nil
    }
    guard let cState = FinancialAccountState.stateFrom(description: state) else {
      return nil
    }

    let cardProductId = self["card_product_id"].string
    let verified = self["verified"].bool
    let cardIssuer = self["card_issuer"].string
    let cardNetwork = self["card_network"].string
    let cardBrand = self["card_brand"].string
    let issuer = CardIssuer.issuerFrom(description: cardIssuer)
    let spendableToday = self["spendable_today"].amount
    let nativeSpendableToday = self["native_spendable_today"].amount
    let totalBalance = self["total_balance"].amount
    let nativeTotalBalance = self["native_total_balance"].amount
    var orderedStatus: OrderedStatus = .notApplicable
    if let rawOrderedStatus = self["ordered_status"].string {
      orderedStatus = OrderedStatus(rawValue: rawOrderedStatus) ?? .notApplicable
    }
    let cardFeatures = self["features"].cardFeatures
    let cardStyle = self["card_style"].cardStyle
    let firstName = self["cardholder_first_name"].string ?? ""
    let lastName = self["cardholder_last_name"].string ?? ""
    let nameOnCard = self["name_on_card"].string
    let cardholder = nameOnCard ?? (firstName + " " + lastName)
    let isInWaitList = self["wait_list"].bool

    return Card(accountId: id,
                cardProductId: cardProductId,
                cardNetwork: CardNetwork.cardNetworkFrom(description: cardNetwork),
                cardIssuer: issuer,
                cardBrand: cardBrand,
                state: cState,
                cardHolder: cardholder,
                lastFourDigits: lastFourDigits,
                spendableToday: spendableToday,
                nativeSpendableToday: nativeSpendableToday,
                totalBalance: totalBalance,
                nativeTotalBalance: nativeTotalBalance,
                kyc: self.kyc,
                orderedStatus: orderedStatus,
                features: cardFeatures,
                cardStyle: cardStyle,
                verified: verified,
                isInWaitList: isInWaitList)
  }

  var cardDetails: CardDetails? {
    guard let expiration = self["expiration"].string,
          let pan = self["pan"].string,
          let cvv = self["cvv"].string else {
      ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError,
                                                            reason: "Can't parse card details \(self)"))
      return nil
    }

    return CardDetails(expiration: expiration, pan: pan, cvv: cvv)
  }

  var transaction: Transaction? {
    guard let transactionId = self["id"].string, let rawCreatedAt = self["created_at"].double else {
      ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError,
                                                            reason: "Can't parse transaction \(self)"))
      return nil
    }

    let createdAt: Date = Date(timeIntervalSince1970: rawCreatedAt)
    let cardNetwork = CardNetwork.cardNetworkFrom(description: self["network"].string)
    let state = TransactionState.transactionStateFrom(description: self["state"].string)
    let transactionType = TransactionType.from(typeName: self["transaction_type"].string)
    let transationDescription = self["description"].string
    let lastMessage = self["last_message"].string
    let declineCode = TransactionDeclineCode.from(string: self["decline_code"].string)
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
    let fundingSourceName = self["funding_source_name"].string

    let transaction = Transaction(transactionId: transactionId,
                                  transactionType: transactionType,
                                  createdAt: createdAt,
                                  transactionDescription: transationDescription,
                                  lastMessage: lastMessage,
                                  declineCode: declineCode,
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
                                  adjustments: adjustments,
                                  fundingSourceName: fundingSourceName)

    return transaction
  }

  var transactionSettlement: TransactionSettlement? {
    guard let rawCreatedAt = self["date"].double else {
      ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError,
                                                            reason: "Can't parse transactionSettlement \(self)"))
      return nil
    }

    let createdAt: Date = Date(timeIntervalSince1970: rawCreatedAt)
    let amount = self["amount"].linkObject as? Amount
    return TransactionSettlement(createdAt: createdAt, amount: amount)
  }

  var transactionAdjustment: TransactionAdjustment? {
    let id = self["id"].string
    let rawCreatedAt = self["created_at"].double
    // swiftlint:disable:next force_unwrapping
    let createdAt: Date? = rawCreatedAt != nil ? Date(timeIntervalSince1970: rawCreatedAt!) : nil
    let externalId = self["external_id"].string
    let type = TransactionAdjustmentType.from(typeName: self["adjustment_type"].string)
    let localAmount = self["local_amount"].linkObject as? Amount
    let nativeAmount = self["native_amount"].linkObject as? Amount
    let fundingSourceName = self["funding_source_name"].string
    let exchangeRate = self["exchange_rate"].double
    let fee = self["fee"].amount

    return TransactionAdjustment(id: id,
                                 externalId: externalId,
                                 createdAt: createdAt,
                                 localAmount: localAmount,
                                 nativeAmount: nativeAmount,
                                 exchangeRate: exchangeRate,
                                 type: type,
                                 fundingSourceName: fundingSourceName,
                                 fee: fee)
  }

  var fundingSource: FundingSource? {
    guard let fundingSourceId = self["id"].string,
          let rawFundingSourceType = self["funding_source_type"].string,
          let rawState = self["state"].string, let state = FundingSourceState(rawValue: rawState) else {
      ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError,
                                                            reason: "Can't parse funding source \(self)"))
      return nil
    }

    var fsType: FundingSourceType?
    if rawFundingSourceType == "custodian_wallet" {
      fsType = .custodianWallet
    }
    guard let fundingSourceType = fsType else {
      ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError,
                                                            reason: "Can't parse funding source type \(self)"))
      return nil
    }

    var balance: Amount?
    if self["balance"].dictionary != nil {
      balance = self["balance"].linkObject as? Amount
    }

    var amountSpendable: Amount?
    if self["amount_spendable"].dictionary != nil {
      amountSpendable = self["amount_spendable"].linkObject as? Amount
    }

    var amountHeld: Amount?
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
    guard let custodianType = self["custodian_type"].string,
          let name = self["name"].string else {
      ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError,
                                                            reason: "Can't parse custodian \(self)"))
      return nil
    }

    return Custodian(custodianType: custodianType, name: name)
  }

  var oauthAttempt: OauthAttempt? {
    guard let id = self["id"].string, let rawStatus = self["status"].string,
          let status = OauthAttempt.Status(rawValue: rawStatus) else {
      ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError,
                                                            reason: "Can't parse oauth attempt \(self)"))
      return nil
    }

    var url: URL?
    if let urlString = self["url"].string {
      url = URL(string: urlString)
    }
    var credentials: OauthCredential?
    if let accessTokenId = self["oauth_token_id"].string {
      let dataPointList = DataPointList()
      if let dataPointFields = self["user_data"]["data"].array {
        dataPointFields.compactMap {
          return $0.linkObject as? DataPoint
        }.forEach {
          dataPointList.add(dataPoint: $0)
        }
      }
      let userData = !dataPointList.isEmpty ? dataPointList : nil
      credentials = OauthCredential(oauthTokenId: accessTokenId, userData: userData)
    }

    let error = self["error"].string
    let errorMessage = self["error_message"].string

    return OauthAttempt(id: id,
                        status: status,
                        url: url,
                        credentials: credentials,
                        error: error,
                        errorMessage: errorMessage)
  }

  var amount: Amount? {
    guard let
      currency = self["currency"].string?.uppercased(),
      let amount = self["amount"].double
      else {
        ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError,
                                                              reason: "Can't parse amount \(self)"))
        return nil
    }
    return Amount(value: amount, currency: currency)
  }
}
