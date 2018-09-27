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
  let title = "phone-collector.title".podLocalized()

  init(userData: DataPointList, uiConfig: ShiftUIConfig) {
    self.userData = userData
    super.init(uiConfig: uiConfig)
  }

  override func setupRows() -> [FormRowView] {
    var retVal: [FormRowView] = []
    retVal.append(FormRowSeparatorView(backgroundColor: UIColor.clear, height: 124))

    let phoneDataPoint = userData.phoneDataPoint
    let phoneField = FormBuilder.phoneRowWith(label: "phone-collector.phone".podLocalized(),
                                              failReasonMessage: "phone-collector.phone.warning.empty".podLocalized(),
                                              lastFormField: true,
                                              accessibilityLabel: "Phone Number Input Field",
                                              uiConfig: uiConfig)
    phoneField.textField.keyboardType = .phonePad
    phoneField.showSplitter = false
    let phoneFormat = PhoneHelper.sharedHelper().formatPhoneWith(nationalNumber: phoneDataPoint.phoneNumber.value)
    phoneField.bndValue.next(phoneFormat)
    phoneField.bndValue.observeNext { text in
      if let formattedPhone = PhoneHelper.sharedHelper().parsePhoneWith(countryCode: phoneDataPoint.countryCode.value,
                                                                        nationalNumber: text) {
        phoneDataPoint.phoneNumber.next(formattedPhone.phoneNumber.value)
      }
    }.dispose(in: disposeBag)
    retVal.append(phoneField)
    validatableRows.append(phoneField)

    return retVal
  }
}
