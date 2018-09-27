//
//  FormRowView.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 31/01/16.
//
//

import UIKit
import SnapKit
import Bond

protocol ReturnButtonListenerProtocol {
  func focusNextRowfrom(row: FormRowView) -> Bool
  func focusPreviousRowfrom(row: FormRowView) -> Bool
}

protocol ValidationResultPresenterProtocol {
  func presentNonPassedValidationResult(_ reason:String)
  func presentPassedValidationResult()
}

protocol FormFocusPresenterProtocol {
  func presentFocusedState()
  func presentNonFocusedState()
}

protocol RowFocusListenerProtocol {
  func rowDidBeginEditing(_ row: FormRowView)
  func rowDidEndEditing(_ row: FormRowView)
}

enum ValidationResult {
  case pass
  case fail(reason:String)
}

open class DataValidator<T> {
  let failReasonMessage: String
  let validate: (T?) -> ValidationResult
  init(failReasonMessage:String, validate: @escaping (T?) -> ValidationResult) {
    self.failReasonMessage = failReasonMessage
    self.validate = validate
  }
}

open class FormRowView: UIControl, FormFocusPresenterProtocol, ValidationResultPresenterProtocol {

  // Observable flag indicating that this row has passed validation
  let valid = Observable(true)
  let validationMessage = Observable("")

  var showSplitter: Bool {
    didSet {
      if self.showSplitter {
        self.splitter = UIView()
        self.addSubview(self.splitter!)
        self.splitter!.backgroundColor = colorize( 0xefefef, alpha:1.0)
        self.splitter!.snp.makeConstraints{ make in
          make.left.right.equalTo(self.contentView);
          make.bottom.equalTo(self);
          make.height.equalTo(1);
        }
      }
      else {
        self.splitter?.removeFromSuperview()
      }
    }
  }
  var returnButtonListener: ReturnButtonListenerProtocol?
  var rowFocusListener: RowFocusListenerProtocol?
  let contentView: UIView
  var padding: UIEdgeInsets {
    didSet {
      self.setNeedsUpdateConstraints()
    }
  }
  var focusedColor = UIColor(red: 0.0, green: 0.45, blue: 0.94, alpha: 1.0)
  var unfocusedColor = UIColor.black
  var splitter: UIView? = nil

  init(showSplitter: Bool,
       topPadding: CGFloat = 5,
       bottomPadding: CGFloat = 5,
       leftPadding: CGFloat = 16,
       rightPadding: CGFloat = 16,
       height: CGFloat = 40,
       maxHeight: CGFloat = 20000) {
    self.padding = UIEdgeInsetsMake(topPadding, leftPadding, bottomPadding, rightPadding)
    self.contentView = UIView()
    self.showSplitter = showSplitter
    super.init(frame: CGRect(x: 0, y: 0, width: 320, height: height))
    self.snp.makeConstraints { make in
      make.height.greaterThanOrEqualTo(height)
      make.height.lessThanOrEqualTo(maxHeight)
    }
    self.addSubview(self.contentView)
    self.translatesAutoresizingMaskIntoConstraints = false
    self.contentView.translatesAutoresizingMaskIntoConstraints = false
    if showSplitter {
      let splitter = UIView()
      self.addSubview(splitter)
      splitter.backgroundColor = colorize(0xefefef, alpha: 1.0)
      splitter.snp.makeConstraints { make in
        make.left.right.equalTo(self.contentView);
        make.bottom.equalTo(self);
        make.height.equalTo(1);
      }
      self.splitter = splitter
    }
  }

  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override open func updateConstraints() {
    super.updateConstraints()
    self.contentView.snp.remakeConstraints { make in
      make.edges.equalTo(self).inset(self.padding);
    }
  }

  func focus() {
    self.rowFocusListener?.rowDidBeginEditing(self)
    self.presentFocusedState()
  }

  func looseFocus() {
    self.rowFocusListener?.rowDidEndEditing(self)
    self.presentNonFocusedState()
    if self.valid.value {
      self.presentPassedValidationResult()
    }
    else {
      self.presentNonPassedValidationResult(self.validationMessage.value)
    }
  }

  func validate(_ result: Result<Bool, NSError>.Callback) {}

  // MARK: - ValidationResultPresenterProtocol
  func presentNonPassedValidationResult(_ reason: String) {}

  func presentPassedValidationResult() {}

  // MARK: - FormFocusPresenterProtocol

  func presentFocusedState() {}
  func presentNonFocusedState() {}
}

extension FormRowView {
  func validateText(_ validator: DataValidator<String>?, text: String?) {
    guard let validator = validator else {
      return
    }
    if !self.isEnabled {
      self.valid.next(true)
      self.validationMessage.next("")
      self.presentPassedValidationResult()
    }
    else {
      let result = validator.validate(text)
      switch result {
      case .pass:
        self.valid.next(true)
        self.validationMessage.next("")
        self.presentPassedValidationResult()
      case .fail(let reason):
        self.valid.next(false)
        self.validationMessage.next(reason)
      }
    }
  }

  func validateInt(_ validator: DataValidator<Int>?, number: Int?) {
    guard let validator = validator else {
      return
    }
    let result = validator.validate(number)
    switch result {
    case .pass:
      self.valid.next(true)
      self.validationMessage.next("")
      self.presentPassedValidationResult()
    case .fail(let reason):
      self.valid.next(false)
      self.validationMessage.next(reason)
    }
  }

  func validateDouble(_ validator: DataValidator<Double>?, number: Double?) {
    guard let validator = validator else {
      return
    }
    let result = validator.validate(number)
    switch result {
    case .pass:
      self.valid.next(true)
      self.validationMessage.next("")
      self.presentPassedValidationResult()
    case .fail(let reason):
      self.valid.next(false)
      self.validationMessage.next(reason)
    }
  }

  func validateDate(_ validator: DataValidator<Date>?, date: Date?) {
    guard let validator = validator else {
      return
    }
    let result = validator.validate(date)
    switch result {
    case .pass:
      self.valid.next(true)
      self.validationMessage.next("")
      self.presentPassedValidationResult()
    case .fail(let reason):
      self.valid.next(false)
      self.validationMessage.next(reason)
    }
  }
}
