//
//  DataCollectorAddressStep.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 06/03/16.
//
//

import Bond
import ReactiveKit

class AddressStep: DataCollectorBaseStep, DataCollectorStepProtocol {
  var title = "address-collector.title".podLocalized()
  private var disposeBag = DisposeBag()
  private let requiredData: RequiredDataPointList
  private let userData: DataPointList
  private let address: Address
  private let allowedCountries: [Country]
  private let addressManager: AddressManager
  private var aptUnitField: FormRowTextInputView?

  init(requiredData: RequiredDataPointList,
       userData: DataPointList,
       uiConfig: ShiftUIConfig,
       googleGeocodingApiKey: String?) {
    self.requiredData = requiredData
    self.userData = userData
    self.address = userData.addressDataPoint
    self.addressManager = AddressManager(apiKey: googleGeocodingApiKey)
    if let country = userData.currentCountry() {
      self.allowedCountries = [country]
    }
    else if let dateDataPoint = requiredData.getRequiredDataPointOf(type: .address),
            let config = dateDataPoint.configuration as? AllowedCountriesConfiguration,
            !config.allowedCountries.isEmpty {
      self.allowedCountries = config.allowedCountries
    }
    else {
      self.allowedCountries = [Country.defaultCountry]
    }
    super.init(uiConfig: uiConfig)
  }

  override func setupRows() -> [FormRowView] {
    return [
      FormBuilder.separatorRow(height: 32),
      createAddressField(),
      createAptUnitField()
    ]
  }

  private func createAddressField() -> FormRowAddressView {
    let placeholder = "address-collector.address.placeholder".podLocalized()
    let addressField = FormBuilder.addressInputRowWith(label: "address-collector.address".podLocalized(),
                                                       placeholder: placeholder,
                                                       value: "",
                                                       accessibilityLabel: "Address Input Field",
                                                       addressManager: addressManager,
                                                       allowedCountries: allowedCountries,
                                                       uiConfig: uiConfig)
    addressField.address.observeNext { [unowned self] address in
      self.address.address.next(address?.address.value)
      self.address.apUnit.next(address?.apUnit.value)
      self.address.country.next(address?.country.value)
      self.address.city.next(address?.city.value)
      self.address.region.next(address?.region.value)
      self.address.zip.next(address?.zip.value)
    }.dispose(in: disposeBag)
    addressField.valid.observeNext { [unowned self] valid in
      self.aptUnitField?.isHidden = !valid
    }.dispose(in: disposeBag)
    validatableRows.append(addressField)
    return addressField
  }

  private func createAptUnitField() -> FormRowTextInputView {
    let aptUnitField = FormBuilder.standardTextInputRowWith(label: "address-collector.apt-unit".podLocalized(),
                                                            placeholder: "Apt 456",
                                                            value: "",
                                                            uiConfig: uiConfig)
    address.apUnit.bidirectionalBind(to: aptUnitField.bndValue)
    self.aptUnitField = aptUnitField
    aptUnitField.isHidden = true
    return aptUnitField
  }
}
