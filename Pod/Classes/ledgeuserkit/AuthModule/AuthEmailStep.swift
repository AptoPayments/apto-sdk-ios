//
//  AuthEmailStep.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 02/26/18.
//
//

import Bond

class AuthEmailStep: DataCollectorBaseStep, DataCollectorStepProtocol {
  private let userData: DataPointList
  let title = "email-collector.title".podLocalized()

  init(userData: DataPointList, uiConfig: ShiftUIConfig) {
    self.userData = userData
    super.init(uiConfig: uiConfig)
  }

  override func setupRows() -> [FormRowView] {
    var retVal: [FormRowView] = []
    retVal.append(FormRowSeparatorView(backgroundColor: UIColor.clear, height: 124))

    let emailDataPoint = userData.emailDataPoint
    let emailField = FormBuilder.emailRowWith(label: "email-collector.email".podLocalized(),
                                              placeholder: "email-collector.placeholder".podLocalized(),
                                              value: emailDataPoint.email.value,
                                              failReasonMessage: "email-collector.email.warning.empty".podLocalized(),
                                              uiConfig: uiConfig)
    emailField.textField.keyboardType = .emailAddress
    emailField.textField.adjustsFontSizeToFitWidth = true
    emailField.showSplitter = false
    _ = emailField.bndValue.observeNext { text in
      emailDataPoint.email.next(text)
    }
    retVal.append(emailField)
    validatableRows.append(emailField)

    return retVal
  }
}
