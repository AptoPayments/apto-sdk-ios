//
//  DataCollectorPhoneStep.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 09/26/17.
//
//

import Bond
import ReactiveKit

class AuthPhoneStep: DataCollectorBaseStep, DataCollectorStepProtocol {
  private let disposeBag = DisposeBag()
  private let userData: DataPointList
  private let allowedCountries: [Country]
  let title = "phone-collector.title".podLocalized()

  init(userData: DataPointList, allowedCountries: [Country], uiConfig: ShiftUIConfig) {
    self.userData = userData
    self.allowedCountries = allowedCountries
    super.init(uiConfig: uiConfig)
  }

  override func setupRows() -> [FormRowView] {
    var retVal: [FormRowView] = []
    retVal.append(FormRowSeparatorView(backgroundColor: UIColor.clear, height: 124))

    let phoneDataPoint = userData.phoneDataPoint
    let phoneField = FormBuilder.phoneTextFieldRow(label: "phone-collector.phone".podLocalized(),
                                                   allowedCountries: allowedCountries,
                                                   placeholder: "phone-collector.phone.placeholder".podLocalized(),
                                                   value: nil,
                                                   accessibilityLabel: "Phone Number Input Field",
                                                   uiConfig: uiConfig)
    phoneField.bndValue.observeNext { phoneNumber in
      if let countryCode = phoneNumber?.countryCode {
        phoneDataPoint.countryCode.next(countryCode)
      }
      if let formattedPhone = PhoneHelper.sharedHelper().parsePhoneWith(countryCode: phoneNumber?.countryCode,
                                                                        nationalNumber: phoneNumber?.phoneNumber) {
        phoneDataPoint.phoneNumber.next(formattedPhone.phoneNumber.value)
      }
    }.dispose(in: disposeBag)
    retVal.append(phoneField)
    validatableRows.append(phoneField)

    return retVal
  }
}
