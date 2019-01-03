//
//  FormDatePickerRowView.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 01/02/16.
//
//

import UIKit
import Bond

public enum FormDateFormat {
  case dateOnly
  case timeOnly
  case dateTime
}

open class FormRowDatePickerView: FormRowTextInputView {

  // MARK: - Public attributes
  var dateValidator: DataValidator<Date>? {
    didSet {
      self.validateDate(self.dateValidator, date: self.date)
    }
  }

  open var date: Date? {
    didSet {
      self.updateTextWith(date: self.date)
      self.validateDate(self.dateValidator, date: self.date)
      guard let date = self.date else {
        return
      }
      datePicker.date = date
    }
  }

  // MARK: - Initializers
  public init(label: UILabel?,
              labelWidth: CGFloat?,
              textField: UITextField,
              date: Date?,
              format: FormDateFormat,
              firstFormField: Bool = false,
              lastFormField: Bool = false,
              validator: DataValidator<Date>? = nil,
              uiConfig: ShiftUIConfig) {
    self.date = date
    self.dateValidator = validator
    self.datePicker = UIDatePicker()
    switch format {
    case .dateOnly:
      datePicker.datePickerMode = .date
      dateFormatter = DateFormatter.dateOnlyFormatter()
    case .timeOnly:
      datePicker.datePickerMode = .time
      dateFormatter = DateFormatter.timeOnlyFormatter()
    case .dateTime:
      datePicker.datePickerMode = .dateAndTime
      dateFormatter = DateFormatter.dateTimeFormatter()
    }
    super.init(label: label,
               labelWidth: labelWidth,
               textField: textField,
               firstFormField: firstFormField,
               lastFormField: lastFormField,
               uiConfig: uiConfig)
    textField.inputView = datePicker
    datePicker.addTarget(self, action: #selector(FormRowDatePickerView.datePickerValueChanged(_:)), for: .valueChanged)
    guard let date = self.date else {
      self.valid.next(false)
      return
    }
    datePicker.date = date
    if validator != nil {
      _ = self.bndValue.observeNext { _ in
        let delayTime = DispatchTime.now() + Double(Int64(0.01 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime) { [weak self] in
          guard let wself = self else {
            return
          }
          wself.validateDate(wself.dateValidator, date: wself.date)
        }
      }
    }
  }

  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Binding Extensions
  private var _bndDate: Observable<Date?>?
  var bndDate: Observable<Date?> {
    if let bndDate = _bndDate {
      return bndDate
    }
    else {
      let bndDate = Observable<Date?>(self.date)
      _ = bndDate.observeNext { [weak self] (date: Date?) in
        self?.date = date
      }
      _bndDate = bndDate
      return bndDate
    }
  }

  @objc func datePickerValueChanged(_ sender: UIDatePicker) {
    bndDate.next(sender.date)
    updateTextWith(date: sender.date)
  }

  // MARK: - Private methods and attributes

  fileprivate let datePicker: UIDatePicker
  fileprivate let dateFormatter: DateFormatter

  fileprivate func updateTextWith(date: Date?) {
    guard let date = date else {
      textField.text = nil
      return
    }
    self.textField.text = self.dateFormatter.string(from: date)
  }
}

class MaximumDateValidator: DataValidator<Date> {
  init(maximumDate: Date,
       failReasonMessage: String) {
    super.init(failReasonMessage: failReasonMessage) { date -> ValidationResult in
      guard let date = date else {
        return .fail(reason: failReasonMessage)
      }
      if date.isLessThanDate(maximumDate) {
        return .pass
      }
      else {
        return .fail(reason: failReasonMessage)
      }
    }
  }
}

class MinimumDateValidator: DataValidator<Date> {
  init(minimumDate: Date,
       failReasonMessage: String) {
    super.init(failReasonMessage: failReasonMessage) { date -> ValidationResult in
      guard let date = date else {
        return .fail(reason: failReasonMessage)
      }
      if date.isGreaterThanDate(minimumDate) {
        return .pass
      }
      else {
        return .fail(reason: failReasonMessage)
      }
    }
  }
}
