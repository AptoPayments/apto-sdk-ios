//
//  DataCollectorAddressStep.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 06/03/16.
//
//

import Bond
import ReactiveKit

class HomeStep: DataCollectorBaseStep, DataCollectorStepProtocol {
  var title = "home-collector.title".podLocalized()
  private var housingTypeField: FormRowValuePickerView! // swiftlint:disable:this implicitly_unwrapped_optional
  private var zipField: FormRowTextInputView! // swiftlint:disable:this implicitly_unwrapped_optional
  private var checkZipOperation: CheckZipOperation?
  private let requiredData: RequiredDataPointList
  private let userData: DataPointList
  private let availableHousingTypes: [HousingType]
  private let googleGeocodingAPIKey: String?
  private let showZip: Bool
  private let showHousingType: Bool

  init(requiredData: RequiredDataPointList,
       userData: DataPointList,
       availableHousingTypes: [HousingType],
       uiConfig: ShiftUIConfig,
       googleGeocodingAPIKey: String?) {
    self.userData = userData
    self.requiredData = requiredData
    self.availableHousingTypes = availableHousingTypes
    self.googleGeocodingAPIKey = googleGeocodingAPIKey
    self.showZip = self.requiredData.getRequiredDataPointOf(type: .address) != nil
    self.showHousingType = self.requiredData.getRequiredDataPointOf(type: .housing) != nil
    super.init(uiConfig: uiConfig)
  }

  override func setupRows() -> [FormRowView] {
    var retVal: [FormRowView] = []
    retVal.append(FormBuilder.separatorRow(height: 124))

    if showZip {
      setUpZipField()
      let addressDataPoint = userData.addressDataPoint
      addressDataPoint.zip.bidirectionalBind(to: zipField.bndValue)
      _ = zipField.becomeFirstResponder()
      retVal.append(zipField)
    }

    if showHousingType {
      setUpHousingField()
      if !showZip {
        _ = housingTypeField.becomeFirstResponder()
      }
      retVal.append(housingTypeField)
    }

    return retVal
  }

  // TODO: Create a FormRowZipView with all the zip code validation logic embedded

  override func setupStepValidation() {
    if showZip {
      let validZip = Observable(false)
      _ = zipField.valid.distinct().observeNext { [weak self] valid in
          if self?.checkZipOperation != nil {
            self?.checkZipOperation?.cancel()
          }
          if valid {
            guard self?.googleGeocodingAPIKey != nil else {
              validZip.next(true)
              return
            }
            guard let addressDataPoint = self?.userData.addressDataPoint else {
              validZip.next(true)
              return
            }
            guard let zip = self?.zipField.bndValue.value else {
              validZip.next(true)
              return
            }
            self?.checkZipOperation = CheckZipOperation(address: addressDataPoint,
                                                        zip: zip,
                                                        googleGeocodingAPIKey: self?.googleGeocodingAPIKey)
            self?.checkZipOperation?.execute { _ in
              validZip.next(true)
            }
          }
          else {
            validZip.next(false)
          }
      }

      if showHousingType {
        combineLatest(housingTypeField.valid, validZip).map { (validHousingType, validZip) -> Bool in
            return validHousingType && validZip
          }.distinct().bind(to: self.valid)
      }
      else {
        validZip.bind(to: self.valid)
      }
    }
    else if showHousingType {
      housingTypeField.valid.bind(to: self.valid)
    }
  }

  private func setUpZipField() {
    let validator = ZipCodeValidator(failReasonMessage: "home-collector.zip-code.warning.invalid".podLocalized())
    self.zipField = FormBuilder.formattedTextInputRowWith(label: "home-collector.zip-code".podLocalized(),
                                                          placeholder: "90210",
                                                          format: "*****-****",
                                                          keyboardType: .numberPad,
                                                          value: "",
                                                          accessibilityLabel: "ZIP Input Field",
                                                          validator: validator,
                                                          hiddenText: false,
                                                          lastFormField: !showHousingType,
                                                          uiConfig: uiConfig)
  }

  private func setUpHousingField() {
    let values: [FormValuePickerValue] = self.availableHousingTypes.map { housingType in
      // swiftlint:disable:next force_unwrapping
      return FormValuePickerValue(id: String(housingType.housingTypeId), text: housingType.description!)
    }
    let placeholder = "home-collector.residence.placeholder".podLocalized()
    let validator = NonEmptyTextValidator(failReasonMessage: "home-collector.residence.warning.empty".podLocalized())
    self.housingTypeField = FormBuilder.valuePickerRowWith(label: "home-collector.residence".podLocalized(),
                                                           placeholder: placeholder,
                                                           value: "",
                                                           values: values,
                                                           accessibilityLabel: "Home Type Picker",
                                                           validator: validator,
                                                           uiConfig: uiConfig)
    housingTypeField.showSplitter = false
    let housingDataPoint = userData.housingDataPoint
    if let housingTypeId = housingDataPoint.housingType.value?.housingTypeId {
      housingTypeField.bndValue.next(String(housingTypeId))
    }
    else {
      housingTypeField.bndValue.next(nil)
    }
    _ = housingTypeField.bndValue.observeNext { housingType in
      guard let housingType = housingType, let housingTypeId = Int(housingType) else {
        housingDataPoint.housingType.next(nil)
        return
      }
      housingDataPoint.housingType.next(HousingType(housingTypeId: housingTypeId))
    }
  }
}

class CheckZipOperation {
  var cancelOperation = false
  let address: Address
  let zip: String?
  let googleGeocodingAPIKey: String?

  init(address: Address, zip: String?, googleGeocodingAPIKey: String?) {
    self.zip = zip
    self.address = address
    self.googleGeocodingAPIKey = googleGeocodingAPIKey
  }

  func execute(_ callback: @escaping Result<Bool, NSError>.Callback) {
    let delayTime = DispatchTime.now() + Double(Int64(1.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
    DispatchQueue.global(qos: DispatchQoS.QoSClass.default).asyncAfter(deadline: delayTime) { [weak self] in
      if self?.cancelOperation == true {
        return
      }
      let addressObj = Address()
      addressObj.country.next(Country(isoCode: "US", name: "United States"))
      addressObj.zip.next(self?.zip)
      let addressManager = AddressManager.defaultManager(apiKey: self?.googleGeocodingAPIKey)
      addressManager.validate(address: addressObj) { [weak self] result in
          if self?.cancelOperation == true {
            return
          }
          DispatchQueue.main.async { [weak self] in
            switch result {
            case .success(let address):
              if address.isValidZipCode() {
                if let city = address.locality {
                  self?.address.city.next(city)
                }
                if let state = AddressManager.defaultManager().getStateBy("US",
                                                                          name: address.administrativeAreaLevel1) {
                  self?.address.stateCode.next(state.isoCode)
                }
                else {
                  self?.address.stateCode.next(nil)
                }
                callback(.success(true))
              }
              else {
                callback(.success(false))
              }
            case .failure(let error):
              callback(.failure(error))
            }
          }
        }
    }
  }

  func cancel() {
    self.cancelOperation = true
  }
}
