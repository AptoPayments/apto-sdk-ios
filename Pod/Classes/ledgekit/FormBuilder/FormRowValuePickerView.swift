//
//  FormValuePickerRowView.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 04/02/16.
//
//

import UIKit
import Bond

@objc open class FormValuePickerValue: NSObject {
  let id: String // swiftlint:disable:this identifier_name
  let text: String

  public init(id: String, text: String) {  // swiftlint:disable:this identifier_name
    self.id = id
    self.text = text
  }
}

open class FormRowValuePickerView: FormRowTextInputView {
  open var selectedValue: String? {
    didSet {
      if let value = self.values.first(where: { $0.id == selectedValue }) {
        self.textField.text = value.text
      }
      else {
        self.textField.text = nil
      }
    }
  }

  private let values: [FormValuePickerValue]

  // MARK: - Initializers

  public init(label: UILabel?,
              labelWidth: CGFloat?,
              textField: UITextField,
              value: String?,
              values: [FormValuePickerValue],
              validator: DataValidator<String>?,
              uiConfig: ShiftUIConfig) {
    self.values = values
    self.selectedValue = value
    self.valuePicker = UIPickerView()
    super.init(label: label, labelWidth: labelWidth, textField: textField, validator: validator, uiConfig: uiConfig)
    self.valuePicker.dataSource = self
    self.valuePicker.delegate = self
    textField.inputView = self.valuePicker
    if let validator = validator {
      _ = self.bndValue.observeNext { _ in
        let delayTime = DispatchTime.now() + Double(Int64(0.01 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime) { [weak self] in
          guard let wself = self else {
            return
          }
          let validationResult = validator.validate(wself.selectedValue)
          switch validationResult {
          case .pass:
            wself.valid.next(true)
          case .fail(let reason):
            wself.valid.next(false)
            wself.validationMessage.next(reason)
          }
        }
      }
    }
  }

  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Binding Extensions
  private var _bndValue: Observable<String?>?
  override public var bndValue: Observable<String?> {
    if let bndValue = _bndValue {
      return bndValue
    }
    else {
      let bndValue = Observable<String?>(self.selectedValue)
      _ = bndValue.observeNext { [weak self] (value: String?) in
        self?.selectedValue = value
        if let selectedIndex = self?.values.index(where: { $0.id == value }) {
          self?.valuePicker.selectRow(selectedIndex + 1, inComponent: 0, animated: false)
        }
        self?.validateText(self?.textValidator, text: self?.selectedValue)
      }
      _bndValue = bndValue
      return bndValue
    }
  }

  // MARK: - Private methods and attributes

  fileprivate let valuePicker: UIPickerView
}

extension FormRowValuePickerView: UIPickerViewDataSource {
  public func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }

  public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return self.values.count + 1
  }
}

extension FormRowValuePickerView: UIPickerViewDelegate {
  public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    if row == 0 {
      return ""
    }
    else {
      return self.values[row - 1].text
    }
  }

  public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    guard row <= self.values.count else {
      return
    }
    var value: String? = nil
    if row == 0 {
      self.bndValue.next(nil)
      self.textField.text = nil
    }
    else {
      self.bndValue.next(self.values[row - 1].id)
      self.textField.text = self.values[row - 1].text
      value = self.values[row - 1].id
    }
    self.validateText(self.textValidator, text: value)
  }
}
