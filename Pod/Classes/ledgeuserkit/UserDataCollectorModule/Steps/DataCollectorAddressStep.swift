//
//  DataCollectorAddressStep.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 06/03/16.
//
//

import Bond

class AddressStep: DataCollectorBaseStep, DataCollectorStepProtocol {
  var title = "address-collector.title".podLocalized()
  private let address: Address
  private let googleGeocodingApiKey: String?

  init(address: Address, uiConfig: ShiftUIConfig, googleGeocodingApiKey: String?) {
    self.address = address
    self.googleGeocodingApiKey = googleGeocodingApiKey
    super.init(uiConfig: uiConfig)
  }

  override func setupRows() -> [FormRowView] {
    return [
      FormBuilder.separatorRow(height: 48),
      createAddressField(),
      createAptUnitField(),
      createCityField(),
      createStateField(),
      createZipField()
    ]
  }

  private func createAddressField() -> FormRowTextInputView {
    let validator = NonEmptyTextValidator(failReasonMessage: "address-collector.address.warning.empty".podLocalized())
    let addressField = FormBuilder.standardTextInputRowWith(label: "address-collector.address".podLocalized(),
                                                            placeholder: "123 Main St.",
                                                            value: "",
                                                            accessibilityLabel: "Address Input Field",
                                                            validator: validator,
                                                            firstFormField: true,
                                                            uiConfig: uiConfig)
    address.address.bidirectionalBind(to: addressField.bndValue)
    validatableRows.append(addressField)
    return addressField
  }

  private func createAptUnitField() -> FormRowTextInputView {
    let aptUnitField = FormBuilder.standardTextInputRowWith(label: "address-collector.apt-unit".podLocalized(),
                                                            placeholder: "Apt 456",
                                                            value: "",
                                                            uiConfig: uiConfig)
    address.apUnit.bidirectionalBind(to: aptUnitField.bndValue)
    return aptUnitField
  }

  private func createCityField() -> FormRowTextInputView {
    let validator = NonEmptyTextValidator(failReasonMessage: "address-collector.city.warning.empty".podLocalized())
    let cityField = FormBuilder.standardTextInputRowWith(label: "address-collector.city".podLocalized(),
                                                         placeholder: "Smalltown",
                                                         value: "",
                                                         accessibilityLabel: "City Input Field",
                                                         validator: validator,
                                                         uiConfig: uiConfig)
    address.city.bidirectionalBind(to: cityField.bndValue)
    validatableRows.append(cityField)
    return cityField
  }

  private func createStateField() -> FormRowValuePickerView {
    let pickerValues: [FormValuePickerValue]
    if let states = AddressManager.defaultManager(apiKey: googleGeocodingApiKey).statesFor(country: "US") {
      pickerValues = states.sorted { (firstState, secondState) -> Bool in
        return firstState.name.compare(secondState.name) == ComparisonResult.orderedAscending
      }.map { state in
        return FormValuePickerValue(id: state.isoCode, text: state.name)
      }
    }
    else {
      pickerValues = []
    }
    let validator = NonEmptyTextValidator(failReasonMessage: "address-collector.state.warning.empty".podLocalized())
    let stateField = FormBuilder.valuePickerRowWith(label: "address-collector.state".podLocalized(),
                                                    placeholder: "CA",
                                                    value: "",
                                                    values: pickerValues,
                                                    accessibilityLabel: "State Input Field",
                                                    validator: validator,
                                                    uiConfig: uiConfig)
    address.stateCode.bidirectionalBind(to: stateField.bndValue)
    validatableRows.append(stateField)
    return stateField
  }

  private func createZipField() -> FormRowTextInputView {
    let validator = ZipCodeValidator(failReasonMessage: "address-collector.zip-code.warning.incorrect".podLocalized())
    let zipField = FormBuilder.formattedTextInputRowWith(label: "address-collector.zip-code".podLocalized(),
                                                         placeholder: "90210",
                                                         format: "*****-****",
                                                         keyboardType: .numberPad,
                                                         value: "",
                                                         accessibilityLabel: "ZIP Input Field",
                                                         validator: validator,
                                                         hiddenText: false,
                                                         lastFormField: true,
                                                         uiConfig: uiConfig)
    zipField.showSplitter = false
    address.zip.bidirectionalBind(to: zipField.bndValue)
    validatableRows.append(zipField)
    return zipField
  }
}
