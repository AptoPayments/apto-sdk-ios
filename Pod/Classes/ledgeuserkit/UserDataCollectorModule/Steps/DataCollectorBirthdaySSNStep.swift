//
//  DataCollectorBirthdaySSNStep.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 06/03/16.
//
//

import Bond
import SnapKit

class BirthdaySSNStep: DataCollectorBaseStep, DataCollectorStepProtocol {
  var title = "birthday-collector.title".podLocalized()
  var callToActionTapHandler: () -> Void
  fileprivate let linkHandler: LinkHandler?
  fileprivate let mode: UserDataCollectorFinalStepMode
  fileprivate let callToAction: CallToAction
  fileprivate let disclaimers: [Content]
  fileprivate let shiftSession: ShiftSession
  fileprivate let subTitle: String
  fileprivate var birthdayField: FormRowDatePickerView! // swiftlint:disable:this implicitly_unwrapped_optional
  fileprivate var ssnField: FormRowTextInputView! // swiftlint:disable:this implicitly_unwrapped_optional
  fileprivate var getOffersButton: FormRowButtonView?
  fileprivate var callToActionButton: FormRowButtonView?

  private let userData: DataPointList
  private let requiredData: RequiredDataPointList
  private let secondaryCredentialType: DataPointType
  private var showBirthdate = true
  private var showSSN = true
  private var showOptionalSSN = false

  init(requiredData: RequiredDataPointList,
       secondaryCredentialType: DataPointType,
       userData: DataPointList,
       mode: UserDataCollectorFinalStepMode,
       disclaimers: [Content],
       uiConfig: ShiftUIConfig,
       shiftSession: ShiftSession,
       screenTitle: String,
       subTitle: String,
       callToAction: CallToAction,
       linkHandler: LinkHandler?) {
    self.userData = userData
    self.requiredData = requiredData
    self.callToActionTapHandler = {}
    self.linkHandler = linkHandler
    self.mode = mode
    self.callToAction = callToAction
    self.disclaimers = disclaimers
    self.shiftSession = shiftSession
    self.subTitle = subTitle
    self.secondaryCredentialType = secondaryCredentialType
    super.init(uiConfig: uiConfig)
    if mode == .updateUser {
      self.title = "birthday-collector.button.update-profile".podLocalized()
    }
    else {
      self.title = screenTitle
    }
  }

  override func setupRows() -> [FormRowView] {
    var retVal: [FormRowView] = []
    retVal.append(FormRowSeparatorView(backgroundColor: UIColor.clear, height: 48))

    calculateFieldsVisibility()

    if showBirthdate {
      let birthDateDataPoint = userData.birthDateDataPoint
      createBirthdayField(birthDateDataPoint: birthDateDataPoint)
      birthDateDataPoint.date.bidirectionalBind(to: birthdayField.bndDate)
      retVal.append(birthdayField)
      validatableRows.append(birthdayField)
      _ = birthdayField.becomeFirstResponder()
    }

    if showSSN {
      var initiallyReadOnly = false
      if mode == .updateUser {
        initiallyReadOnly = true
      }

      let SSNDataPoint = userData.SSNDataPoint
      createSSNField(initiallyReadOnly: initiallyReadOnly)
      SSNDataPoint.ssn.bidirectionalBind(to: ssnField.bndValue)
      retVal.append(ssnField)
      validatableRows.append(ssnField)

      if !showBirthdate {
        _ = ssnField.becomeFirstResponder()
      }

      if self.showOptionalSSN {
        let ssnNotSpecified = setUpOptionalSSN(SSNDataPoint: SSNDataPoint)
        retVal.append(ssnNotSpecified)
      }
    }
    retVal.append(FormRowSeparatorView(backgroundColor: UIColor.clear, height: 72))
    let callToActionButton = createCallToActionButton()
    retVal.append(callToActionButton)
    let privateInfoLabel = createInfoLabel()
    retVal.append(privateInfoLabel)

    // Filter non text-only disclaimers
    let disclosureText = createDisclosureText()
    if let richText = disclosureText, richText.string != "" {
      let disclosureLabel = createDisclosureLabel(richText: richText)
      retVal.append(disclosureLabel)
    }

    return retVal
  }

  fileprivate func handleCallToActionButtonClick() {
    if self.ssnField != nil {
      _ = self.ssnField.resignFirstResponder()
    }
    if self.birthdayField != nil {
      _ = self.birthdayField.resignFirstResponder()
    }
    self.callToActionTapHandler()
  }

  override func setupStepValidation() {
    super.setupStepValidation()

    _ = self.valid.observeNext { [weak self] valid in
      self?.callToActionButton?.isEnabled = valid
      if valid {
        self?.callToActionButton?.button.backgroundColor = self?.uiConfig.uiPrimaryColor
      }
      else {
        self?.callToActionButton?.button.backgroundColor = self?.uiConfig.uiPrimaryColorDisabled
      }
    }
  }

  fileprivate func calculateFieldsVisibility() {
    // Calculate if the SSN Field should be shown
    if let showSSNRequiredDataPoint = requiredData.getRequiredDataPointOf(type: .ssn) {
      showSSN = true
      showOptionalSSN = showSSNRequiredDataPoint.optional
    }
    else {
      showSSN = false
      showOptionalSSN = false
    }
    showBirthdate = requiredData.getRequiredDataPointOf(type: .birthDate) != nil
  }
}

private extension BirthdaySSNStep {
  private func createBirthdayField(birthDateDataPoint: BirthDate) {
    let failReason = "birthday-collector.birthday.warning.minimum-age".podLocalized()
    let dateValidator = MaximumDateValidator(maximumDate: Date().add(-18, units: .year)!,
                                             failReasonMessage: failReason)
    birthdayField = FormBuilder.datePickerRowWith(label: "birthday-collector.birthday".podLocalized(),
                                                  placeholder: "birthday-collector.birthday.placeholder".podLocalized(),
                                                  format: .dateOnly,
                                                  value: birthDateDataPoint.date.value,
                                                  accessibilityLabel: "Birthdate Input Field",
                                                  validator: dateValidator,
                                                  firstFormField: true,
                                                  uiConfig: uiConfig)
  }

  private func createSSNField(initiallyReadOnly: Bool) {
    let ssnValidator = SSNTextValidator(failReasonMessage: "birthday-collector.ssn.warning.invalid-ssn".podLocalized())
    ssnField = FormBuilder.formattedTextInputRowWith(label: "birthday-collector.ssn".podLocalized(),
                                                     placeholder: "XXX-XX-XXXX",
                                                     format: "***-**-****",
                                                     keyboardType: .numberPad,
                                                     value: "",
                                                     accessibilityLabel: "SSN Input Field",
                                                     validator: ssnValidator,
                                                     hiddenText: true,
                                                     initiallyReadOnly: initiallyReadOnly,
                                                     lastFormField: true,
                                                     uiConfig: uiConfig)
    ssnField.textField.keyboardType = .numberPad
    ssnField.showSplitter = false
  }

  private func setUpOptionalSSN(SSNDataPoint: SSN) -> FormRowCheckView {
    let label = ComponentCatalog.formListLabelWith(text: "birthday-collector.ssn.not-specified.title".podLocalized(),
                                                   uiConfig: uiConfig)
    let ssnNotSpecified = FormRowCheckView(label: label, height: 20)
    ssnNotSpecified.checkIcon.tintColor = uiConfig.uiPrimaryColor
    rows.append(ssnNotSpecified)
    if let notSpecified = SSNDataPoint.notSpecified {
      ssnNotSpecified.bndValue.next(notSpecified)
      ssnField.bndValue.next(nil)
      self.validatableRows = self.validatableRows.compactMap { ($0 == self.ssnField) ? nil : $0 }
      self.setupStepValidation()
    }
    _ = ssnNotSpecified.bndValue.observeNext { checked in
      SSNDataPoint.notSpecified = checked
      self.ssnField.isEnabled = !checked
      if checked {
        self.ssnField.bndValue.next(nil)
        self.validatableRows = self.validatableRows.compactMap { ($0 == self.ssnField) ? nil : $0 }
      }
      else {
        self.validatableRows.append(self.ssnField)
      }
      self.setupStepValidation()
    }
    return ssnNotSpecified
  }

  private func createCallToActionButton() -> FormRowButtonView {
    let callToActionButton = FormBuilder.buttonRowWith(title: callToAction.title,
                                                       tapHandler: handleCallToActionButtonClick,
                                                       uiConfig: uiConfig)
    self.callToActionButton = callToActionButton
    return callToActionButton
  }

  private func createInfoLabel() -> FormRowLabelView {
    let privateInfoLabel = FormBuilder.itemDescriptionRowWith(
      text: "birthday-collector.information-private".podLocalized(),
      uiConfig: uiConfig)
    privateInfoLabel.label.font = uiConfig.instructionsFont
    privateInfoLabel.label.textColor = uiConfig.textTertiaryColor
    privateInfoLabel.label.numberOfLines = 0
    privateInfoLabel.label.snp.updateConstraints { make in
      make.left.right.equalToSuperview().inset(60)
    }
    return privateInfoLabel
  }

  private func createDisclosureText() -> NSAttributedString? {
    let textPrequalificationDisclaimers = disclaimers.filter { $0 != nil ? $0!.isPlainText : false }
    let disclosureText = textPrequalificationDisclaimers.reduce(nil) { (src, disclaimer) -> NSAttributedString? in
      let optDisclosureString = disclaimer.attributedString(font: uiConfig.fonth6,
                                                            color: uiConfig.noteTextColor,
                                                            linkColor: uiConfig.tintColor)
      guard let disclosureString = optDisclosureString else {
        return src
      }
      guard src != nil else {
        return disclosureString
      }
      let retVal = NSMutableAttributedString(string: "\n\n")
      retVal.append(disclosureString)
      return retVal
    }
    return disclosureText
  }

  private func createDisclosureLabel(richText: NSAttributedString) -> FormRowRichTextLabelView {
    let text = "\n\n" + "birthday-collector.disclosures".podLocalized() + "\n\n"
    let titledDisclosures = NSMutableAttributedString.createFrom(string: text,
                                                                 font: uiConfig.fonth6,
                                                                 color: uiConfig.noteTextColor)
    titledDisclosures.append(richText)
    let disclosureLabel = FormBuilder.richTextNoteRowWith(text: titledDisclosures,
                                                          textAlignment: .left,
                                                          position: .top,
                                                          uiConfig: uiConfig,
                                                          linkHandler: self.linkHandler)
    disclosureLabel.label.numberOfLines = 0
    return disclosureLabel
  }
}
