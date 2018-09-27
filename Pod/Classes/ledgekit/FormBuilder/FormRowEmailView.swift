//
//  FormRowEmailView.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 10/02/16.
//
//

import UIKit

class FormRowEmailView: FormRowTextInputView {
  init(label: UILabel?,
       labelWidth: CGFloat?,
       textField: UITextField,
       failReasonMessage: String,
       uiConfig: ShiftUIConfig) {
    super.init(label: label,
               labelWidth: labelWidth,
               textField: textField,
               validator: EmailValidator(failReasonMessage: failReasonMessage),
               uiConfig: uiConfig)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

class EmailValidator: DataValidator<String> {
  init(failReasonMessage: String) {
    super.init(failReasonMessage: failReasonMessage) { value -> ValidationResult in
      // swiftlint:disable:next line_length
      let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
      let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
      if emailTest.evaluate(with: value) {
        return .pass
      }
      else {
        return .fail(reason: failReasonMessage)
      }
    }
  }
}
