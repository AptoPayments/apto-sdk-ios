//
//  DataCollectorBirthdaySSNStep.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 06/03/16.
//
//

import Bond
import ReactiveKit
import SnapKit

class BirthdaySSNStep: DataCollectorBaseStep, DataCollectorStepProtocol {
  var title = "collect_user_data.dob.title".podLocalized()
  fileprivate let linkHandler: LinkHandler?
  fileprivate let mode: UserDataCollectorFinalStepMode
  fileprivate let disclaimers: [Content]
  fileprivate var birthdayField: FormRowDatePickerView! // swiftlint:disable:this implicitly_unwrapped_optional
  fileprivate var numberField: FormRowTextInputView! // swiftlint:disable:this implicitly_unwrapped_optional
  private var countryField: FormRowCountryPickerView?
  private var documentTypeField: FormRowIdDocumentTypePickerView?

  private let disposeBag = DisposeBag()
  private let userData: DataPointList
  private let requiredData: RequiredDataPointList
  private let secondaryCredentialType: DataPointType
  private var showBirthdate = true
  private var showIdDocument = true
  private var showOptionalIdDocument = false
  private let allowedDocuments: [Country: [IdDocumentType]]
  private lazy var allowedCountries: [Country] = {
    return Array(allowedDocuments.keys)
  }()

  init(requiredData: RequiredDataPointList,
       secondaryCredentialType: DataPointType,
       userData: DataPointList,
       mode: UserDataCollectorFinalStepMode,
       disclaimers: [Content],
       uiConfig: ShiftUIConfig,
       linkHandler: LinkHandler?) {
    self.userData = userData
    self.requiredData = requiredData
    self.linkHandler = linkHandler
    self.mode = mode
    self.disclaimers = disclaimers
    self.secondaryCredentialType = secondaryCredentialType
    if let dataPoint = requiredData.getRequiredDataPointOf(type: .idDocument),
       let config = dataPoint.configuration as? AllowedIdDocumentTypesConfiguration,
       !config.allowedDocumentTypes.isEmpty {
      self.allowedDocuments = config.allowedDocumentTypes
    }
    else {
      self.allowedDocuments = [Country.defaultCountry: [IdDocumentType.ssn]]
    }
    super.init(uiConfig: uiConfig)
  }

  override func setupRows() -> [FormRowView] {
    calculateFieldsVisibility()

    return [
      FormRowSeparatorView(backgroundColor: UIColor.clear, height: CGFloat(48)),
      createBirthdayField(),
      createCountryPickerField(),
      createDocumentTypePickerField(),
      createNumberField(),
      setUpOptionalIdDocument(),
      FormRowSeparatorView(backgroundColor: UIColor.clear, height: CGFloat(72)),
      createDisclosureLabel(),
      FormRowSeparatorView(backgroundColor: UIColor.clear, height: CGFloat(20)),
    ].compactMap { return $0 }
  }

  fileprivate func calculateFieldsVisibility() {
    // Calculate if the Id Document Fields should be shown
    if let showSSNRequiredDataPoint = requiredData.getRequiredDataPointOf(type: .idDocument) {
      showIdDocument = true
      showOptionalIdDocument = showSSNRequiredDataPoint.optional
    }
    else {
      showIdDocument = false
      showOptionalIdDocument = false
    }
    showBirthdate = requiredData.getRequiredDataPointOf(type: .birthDate) != nil
  }
}

private extension BirthdaySSNStep {
  func createBirthdayField() -> FormRowDatePickerView? {
    guard showBirthdate == true else { return nil }

    let birthDateDataPoint = userData.birthDateDataPoint
    let failReason = "birthday-collector.birthday.warning.minimum-age".podLocalized()
    let dateValidator = MaximumDateValidator(maximumDate: Date().add(-18, units: .year)!,
                                             failReasonMessage: failReason)
    birthdayField = FormBuilder.datePickerRowWith(label: "collect_user_data.dob.dob.title".podLocalized(),
                                                  placeholder: "collect_user_data.dob.dob.placeholder".podLocalized(),
                                                  format: .dateOnly,
                                                  value: birthDateDataPoint.date.value,
                                                  accessibilityLabel: "Birthdate Input Field",
                                                  validator: dateValidator,
                                                  firstFormField: true,
                                                  uiConfig: uiConfig)
    birthDateDataPoint.date.bidirectionalBind(to: birthdayField.bndDate).dispose(in: disposeBag)
    validatableRows.append(birthdayField)
    return birthdayField
  }

  func createCountryPickerField() -> FormRowCountryPickerView? {
    guard showIdDocument == true else { return nil }

    let idDocumentDataPoint = userData.IdDocumentDataPoint
    guard allowedCountries.count > 1 else {
      idDocumentDataPoint.country.next(allowedCountries.first)
      return nil
    }

    let countryField = FormBuilder.countryPickerRow(label: "collect_user_data.dob.doc_country.title".podLocalized(),
                                                    allowedCountries: allowedCountries,
                                                    uiConfig: uiConfig)
    countryField.bndValue.observeNext { [unowned self] country in
      idDocumentDataPoint.country.next(country)
      guard let allowedDocumentTypes = self.allowedDocuments[country] else {
        fatalError("No document types configured for country \(country.name)")
      }
      self.documentTypeField?.allowedDocumentTypes = allowedDocumentTypes
    }.dispose(in: disposeBag)
    self.countryField = countryField
    return countryField
  }

  func createDocumentTypePickerField() -> FormRowIdDocumentTypePickerView? {
    guard showIdDocument == true else { return nil }

    let idDocumentDataPoint = userData.IdDocumentDataPoint
    let currentCountry = idDocumentDataPoint.country.value ?? allowedCountries[0]
    guard let allowedDocumentTypes = allowedDocuments[currentCountry],
          !allowedDocuments.isEmpty else {
      fatalError("No document types configured for country \(currentCountry.name)")
    }
    guard allowedCountries.count > 1 || allowedDocumentTypes.count > 1 else {
      idDocumentDataPoint.documentType.next(allowedDocumentTypes[0])
      return nil
    }
    let label = "collect_user_data.dob.doc_type.title".podLocalized()
    let documentTypeField = FormBuilder.idDocumentTypePickerRow(label: label,
                                                                allowedDocumentTypes: allowedDocumentTypes,
                                                                uiConfig: uiConfig)
    documentTypeField.bndValue.observeNext { documentType in
      idDocumentDataPoint.documentType.next(documentType)
    }.dispose(in: disposeBag)
    self.documentTypeField = documentTypeField
    return documentTypeField
  }

  func createNumberField() -> FormRowTextInputView? {
    guard showIdDocument == true else { return nil }

    let idDocumentDataPoint = userData.IdDocumentDataPoint
    let initiallyReadOnly = mode == .updateUser
    let validator = NonEmptyTextValidator(failReasonMessage: "birthday-collector.id-document.invalid".podLocalized())
    let placeholder = "collect_user_data.dob.doc_id.placeholder".podLocalized()
    var label = "collect_user_data.dob.doc_id.title".podLocalized()
    let currentCountry = idDocumentDataPoint.country.value ?? allowedCountries[0]
    if let allowedDocumentTypes = allowedDocuments[currentCountry],
       (allowedCountries.count == 1 && allowedDocumentTypes.count == 1) {
      label.append(" (\(allowedDocumentTypes[0].localizedDescription))")
    }
    numberField = FormBuilder.standardTextInputRowWith(label: label,
                                                       placeholder: placeholder,
                                                       value: "",
                                                       accessibilityLabel: "Id document Input Field",
                                                       validator: validator,
                                                       initiallyReadonly: initiallyReadOnly,
                                                       uiConfig: uiConfig)
    idDocumentDataPoint.value.bidirectionalBind(to: numberField.bndValue)
    validatableRows.append(numberField)

    return numberField
  }

  func setUpOptionalIdDocument() -> FormRowCheckView? {
    guard showOptionalIdDocument == true else { return nil }
    let idDocumentDataPoint = userData.IdDocumentDataPoint
    let text = "collect_user_data.dob.doc_id.not-specified.title".podLocalized()
    let label = ComponentCatalog.formListLabelWith(text: text,
                                                   uiConfig: uiConfig)
    let documentNotSpecified = FormRowCheckView(label: label, height: 20)
    documentNotSpecified.checkIcon.tintColor = uiConfig.uiPrimaryColor
    rows.append(documentNotSpecified)
    if let notSpecified = idDocumentDataPoint.notSpecified {
      documentNotSpecified.bndValue.next(notSpecified)
      numberField.bndValue.next(nil)
      self.validatableRows = self.validatableRows.compactMap { ($0 == self.numberField) ? nil : $0 }
      self.setupStepValidation()
    }
    documentNotSpecified.bndValue.observeNext { checked in
      idDocumentDataPoint.notSpecified = checked
      idDocumentDataPoint.country.next(nil)
      idDocumentDataPoint.value.next(nil)
      idDocumentDataPoint.documentType.next(nil)
      self.numberField.isEnabled = !checked
      self.countryField?.isEnabled = !checked
      self.documentTypeField?.isEnabled = !checked
      if checked {
        self.numberField.bndValue.next(nil)
        self.validatableRows = self.validatableRows.compactMap {
          ($0 == self.numberField || $0 == self.countryField || $0 == self.documentTypeField) ? nil : $0
        }
      }
      else {
        self.validatableRows.append(self.numberField)
        if let countryField = self.countryField {
          self.validatableRows.append(countryField)
        }
        if let documentTypeField = self.documentTypeField {
          self.validatableRows.append(documentTypeField)
        }
      }
      self.setupStepValidation()
    }.dispose(in: disposeBag)
    return documentNotSpecified
  }

  func createDisclosureLabel() -> FormRowRichTextLabelView? {
    // Filter non text-only disclaimers
    guard let richText = createDisclosureText(), !richText.string.isEmpty else {
      return nil
    }
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

  func createDisclosureText() -> NSAttributedString? {
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
}
