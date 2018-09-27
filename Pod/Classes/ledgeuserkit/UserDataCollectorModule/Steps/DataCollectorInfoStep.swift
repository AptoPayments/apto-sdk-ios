//
//  DataCollectorInfoStep.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 06/03/16.
//
//

import Bond

class InfoStep: DataCollectorBaseStep, DataCollectorStepProtocol {
  var title = "info-collector.title".podLocalized()

  private let requiredData: RequiredDataPointList
  private let userData: DataPointList
  private let primaryCredentialType: DataPointType
  private var showName = false
  private var showEmail = false
  private var showPhone = false
  private var showOptionalEmail = false

  init(requiredData: RequiredDataPointList,
       userData: DataPointList,
       primaryCredentialType: DataPointType,
       uiConfig: ShiftUIConfig) {
    self.requiredData = requiredData
    self.userData = userData
    self.primaryCredentialType = primaryCredentialType
    super.init(uiConfig: uiConfig)
  }

  override func setupRows() -> [FormRowView] {
    var retVal: [FormRowView] = []
    retVal.append(FormRowSeparatorView(backgroundColor: UIColor.clear, height: 48))

    calculateFieldsVisibility()

    if showName {
      setUpNameFields(retVal: &retVal)
    }
    if showEmail {
      setUpEmailField(retVal: &retVal)
    }
    if showPhone {
      setUpPhoneField(retVal: &retVal)
    }
    return retVal
  }

  private func calculateFieldsVisibility() {
    // Calculate if the name Fields must be shown
    showName = self.requiredData.getRequiredDataPointOf(type: .personalName) != nil
    // Calculate if the email fields must be shown
    if let emailRequiredDataPoint = requiredData.getRequiredDataPointOf(type: .email) {
      showEmail = primaryCredentialType != .email // If email is the primary credential, we already asked for it
      showOptionalEmail = emailRequiredDataPoint.optional
    }
    else {
      showEmail = false
      showOptionalEmail = false
    }
    // Calculate if the phone fields must be shown
    if requiredData.getRequiredDataPointOf(type: .phoneNumber) != nil {
      showPhone = primaryCredentialType != .phoneNumber // If phone is the primary credential, we already asked it
    }
    else {
      showPhone = false
    }
  }
}

// MARK: - Setup UI fields
private extension InfoStep {
  func setUpNameFields(retVal: inout [FormRowView]) {
    let firstNameField = createFirstNameField()
    let lastNameField = createLastNameField()
    let nameDataPoint = userData.nameDataPoint
    nameDataPoint.firstName.bidirectionalBind(to: firstNameField.bndValue)
    nameDataPoint.lastName.bidirectionalBind(to: lastNameField.bndValue)
    retVal.append(firstNameField)
    retVal.append(lastNameField)
    validatableRows.append(firstNameField)
    validatableRows.append(lastNameField)

    _ = firstNameField.becomeFirstResponder()
  }

  func createFirstNameField() -> FormRowTextInputView {
    let validator = NonEmptyTextValidator(failReasonMessage: "info-collector.first-name.warning.empty".podLocalized())
    let firstNameField = FormBuilder.standardTextInputRowWith(label: "info-collector.first-name".podLocalized(),
                                                              placeholder: "John",
                                                              value: "",
                                                              accessibilityLabel: "First Name Input Field",
                                                              validator: validator,
                                                              firstFormField: true,
                                                              uiConfig: uiConfig)
    firstNameField.textField.autocapitalizationType = .sentences
    return firstNameField
  }

  func createLastNameField() -> FormRowTextInputView {
    let validator = NonEmptyTextValidator(failReasonMessage: "info-collector.last-name.warning.empty".podLocalized())
    let lastNameField = FormBuilder.standardTextInputRowWith(label: "info-collector.last-name".podLocalized(),
                                                             placeholder: "Smith",
                                                             value: "",
                                                             accessibilityLabel: "Last Name Input Field",
                                                             validator: validator,
                                                             uiConfig: uiConfig)
    lastNameField.textField.autocapitalizationType = .sentences
    return lastNameField
  }

  func setUpEmailField(retVal: inout [FormRowView]) {
    let emailField = createEmailField()
    let emailDataPoint = userData.emailDataPoint
    emailDataPoint.email.bidirectionalBind(to: emailField.bndValue)
    retVal.append(emailField)
    validatableRows.append(emailField)
    if showOptionalEmail {
      setUpOptionalEmailField(emailDataPoint: emailDataPoint, emailField: emailField, retVal: &retVal)
    }
    if !showName {
      _ = emailField.becomeFirstResponder()
    }
  }

  func createEmailField() -> FormRowTextInputView {
    let validator = EmailValidator(failReasonMessage: "info-collector.email.warning.empty".podLocalized())
    let emailField = FormBuilder.standardTextInputRowWith(label: "info-collector.email".podLocalized(),
                                                          placeholder: "john@smith.com", value: "",
                                                          accessibilityLabel: "Email Input Field",
                                                          validator: validator,
                                                          uiConfig: uiConfig)
    emailField.textField.keyboardType = .emailAddress
    emailField.showSplitter = false
    emailField.textField.adjustsFontSizeToFitWidth = true
    return emailField
  }

  func setUpOptionalEmailField(emailDataPoint: Email, emailField: FormRowTextInputView, retVal: inout [FormRowView]) {
    let emailNotSpecified = FormBuilder.checkboxRowWith(
      text: "info-collector.email.not-specified.title".podLocalized(),
      uiConfig: uiConfig)
    emailNotSpecified.backgroundColor = UIColor.white
    emailNotSpecified.checkIcon.tintColor = uiConfig.tintColor
    rows.append(emailNotSpecified)
    if let notSpecified = emailDataPoint.notSpecified {
      emailNotSpecified.bndValue.next(notSpecified)
      emailField.bndValue.next(nil)
      self.validatableRows = self.validatableRows.compactMap { ($0 == emailField) ? nil: $0 }
      self.setupStepValidation()
    }
    _ = emailNotSpecified.bndValue.observeNext { checked in
      emailDataPoint.notSpecified = checked
      emailField.isEnabled = !checked
      if checked {
        emailField.bndValue.next(nil)
        self.validatableRows = self.validatableRows.compactMap { ($0 == emailField) ? nil: $0 }
      }
      else {
        self.validatableRows.append(emailField)
        emailField.validate {_ in }
      }
      self.setupStepValidation()
    }
    retVal.append(emailNotSpecified)
  }

  func setUpPhoneField(retVal: inout [FormRowView]) {
    let phoneField = createPhoneField()
    retVal.append(phoneField)
    validatableRows.append(phoneField)
    if !showName && !showEmail {
      _ = phoneField.becomeFirstResponder()
    }
  }

  func createPhoneField() -> FormRowPhoneView {
    let phoneField = FormBuilder.phoneRowWith(label: "phone-collector.phone".podLocalized(),
                                              failReasonMessage: "phone-collector.phone.warning.empty".podLocalized(),
                                              lastFormField: true,
                                              accessibilityLabel: "Phone Number Input Field",
                                              uiConfig: uiConfig)
    phoneField.textField.keyboardType = .phonePad
    phoneField.showSplitter = false
    let phoneDataPoint = userData.phoneDataPoint
    // TODO: Assign US as the country code.
    if phoneDataPoint.countryCode.value == -1 {
      phoneDataPoint.countryCode.next(1)
    }
    let phoneHelper = PhoneHelper.sharedHelper()
    phoneField.bndValue.next(phoneHelper.formatPhoneWith(nationalNumber: phoneDataPoint.phoneNumber.value))
    _ = phoneField.bndValue.observeNext { text in
      if let formattedPhone = phoneHelper.parsePhoneWith(countryCode: phoneDataPoint.countryCode.value,
                                                         nationalNumber: text) {
        phoneDataPoint.phoneNumber.next(formattedPhone.phoneNumber.value)
      }
    }
    return phoneField
  }
}
