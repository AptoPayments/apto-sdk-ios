//
//  FormPhoneRowView.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 10/02/16.
//

import UIKit

class FormRowPhoneView: FormRowTextInputView {
  var cursorPosition: Int?

  init(label: UILabel?,
       labelWidth: CGFloat?,
       textField: UITextField,
       failReasonMessage: String,
       firstFormField: Bool,
       lastFormField: Bool,
       uiConfig: ShiftUIConfig) {
    super.init(label: label,
               labelWidth: labelWidth,
               textField: textField,
               firstFormField:firstFormField,
               lastFormField: lastFormField,
               validator: PhoneNumberValidator(failReasonMessage: failReasonMessage),
               uiConfig: uiConfig)
    let _ = bndValue.observeNext { text in
      let formattedPhone = PhoneHelper.sharedHelper().formatPhoneWith(nationalNumber: textField.text)
      textField.text = formattedPhone
      if let cursorPosition = self.cursorPosition {
        textField.positionCursor(atIndex: cursorPosition)
        self.cursorPosition = nil
      }
    }
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func textField(_ textField: UITextField,
                          shouldChangeCharactersIn range: NSRange,
                          replacementString string: String) -> Bool {
    if string.isEmpty {
      // Delete character
      if var rawFinalString = textField.text {
        let idx = rawFinalString.index(rawFinalString.startIndex, offsetBy: range.location)
        rawFinalString.remove(at: idx)
        let maskedPositionCursor = calculateFinalCursorPosition(text: rawFinalString, range: range)
        cursorPosition = maskedPositionCursor
      }
    }
    else {
      // Add character
      if let text = textField.text {
        let rawFinalString = text.insert(string, ind: range.location)
        let maskedPositionCursor = calculateFinalCursorPosition(text: rawFinalString, range: range)
        cursorPosition = maskedPositionCursor + 1
      }
    }
    return super.textField(textField, shouldChangeCharactersIn: range, replacementString: string)
  }

  fileprivate func calculateFinalCursorPosition(text: String, range: NSRange) -> Int {
    // Calculate the position of the cursor in the unmasked string
    let unmaskedPositionCursor = unmaskedCursorPosition(value: text, range: range)
    // Calculate the final string (masked)
    let maskedFinalString = PhoneHelper.sharedHelper().formatPhoneWith(nationalNumber: text)
    // Calculate the position of the cursor in the masked string
    return maskedCursorPosition(maskedValue: maskedFinalString,
                                unmaskedPosition: unmaskedPositionCursor)
  }

  fileprivate func unmaskedCursorPosition(value: String?, range: NSRange) -> Int {
    guard let value = value else {
      return 0
    }
    let nonDigitCharacterCount = value.countCharactersNotIn(characterSet: CharacterSet.decimalDigits,
                                                            untilIndex: range.location - 1)
    return range.location - nonDigitCharacterCount
  }

  fileprivate func maskedCursorPosition(maskedValue: String, unmaskedPosition: Int) -> Int {
    let nonDigitCharacterCount = maskedValue.countCharactersNotIn(characterSet: CharacterSet.decimalDigits,
                                                                  untilIndex: unmaskedPosition)
    return unmaskedPosition + nonDigitCharacterCount
  }

}

class PhoneNumberValidator: DataValidator<String> {
  init(failReasonMessage: String) {
    super.init(failReasonMessage: failReasonMessage) { value -> ValidationResult in
      let validPhone = PhoneHelper.sharedHelper().validatePhoneWith(nationalNumber: value)
      return validPhone ? .pass : .fail(reason: failReasonMessage)
    }
  }
}
