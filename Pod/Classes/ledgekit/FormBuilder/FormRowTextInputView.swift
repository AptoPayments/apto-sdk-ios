//
//  FormTextInputRowView.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 31/01/16.
//
//

import UIKit
import Bond
import ReactiveKit
import SnapKit

open class FormRowTextInputView: FormRowLeftLabelView, UITextFieldDelegate {
  private let disposeBag = DisposeBag()
  public let textField: UITextField
  private let textColor: UIColor?
  private let firstFormField: Bool
  private let lastFormField: Bool
  private let height: CGFloat
  let toggleSecureEntryState: Bool
  let initiallyReadOnly: Bool
  let uiConfig: ShiftUIConfig

  var textValidator: DataValidator<String>? {
    didSet {
      self.validateText(self.textValidator, text: self.textField.text)
    }
  }

  open override var isEnabled: Bool {
    didSet {
      self.textField.isEnabled = self.isEnabled
      if let button = self.textField.rightView as? UIButton {
        button.isEnabled = self.isEnabled
      }
      if !self.isEnabled {
        self.textField.textColor = uiConfig.textSecondaryColorDisabled
        self.label?.textColor = uiConfig.textPrimaryColorDisabled
      }
      else {
        self.textField.textColor = self.textColor
        self.label?.textColor = uiConfig.textPrimaryColor
        self.presentNonFocusedState()
      }
      self.validateText(self.textValidator, text: self.textField.text)
    }
  }

  public init(label: UILabel?,
              labelWidth: CGFloat?,
              textField: UITextField,
              toggleSecureEntryState: Bool = false,
              initiallyReadOnly: Bool = false,
              firstFormField: Bool = false,
              lastFormField: Bool = false,
              validator: DataValidator<String>? = nil,
              uiConfig: ShiftUIConfig,
              height: CGFloat = 80) {
    self.textField = textField
    self.toggleSecureEntryState = toggleSecureEntryState
    self.initiallyReadOnly = initiallyReadOnly
    self.firstFormField = firstFormField
    self.lastFormField = lastFormField
    self.textValidator = validator
    self.textColor = textField.textColor
    self.uiConfig = uiConfig
    self.height = height
    super.init(label: label, labelWidth: labelWidth, showSplitter: false, height: height / 2)

    setUpTextField()
    setUpContentView()
    setUpTextFieldRightView()
    setUpValidationButton()
    setUpLabelListener()
  }

  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override open func becomeFirstResponder() -> Bool {
    return textField.becomeFirstResponder()
  }

  override open func resignFirstResponder() -> Bool {
    return textField.resignFirstResponder()
  }

  @objc func labelTapped() {
    textField.becomeFirstResponder()
  }

  @objc func switchSecureText() {
    textField.isSecureTextEntry = !textField.isSecureTextEntry
    if textField.isSecureTextEntry {
      guard let button = textField.rightView as? UIButton else {
        return
      }
      button.setImage(UIImage.imageFromPodBundle("icon-field-show")?.asTemplate(), for: .normal)
    }
    else {
      guard let button = textField.rightView as? UIButton else {
        return
      }
      button.setImage(UIImage.imageFromPodBundle("icon-field-hide")?.asTemplate(), for: .normal)
    }
  }

  @objc func editContents() {
    textField.text = ""
    if toggleSecureEntryState {
      addToggleSecureTextButton()
      if textField.isSecureTextEntry {
        switchSecureText()
      }
    }
    textField.becomeFirstResponder()
  }

  // MARK: - UITextFieldDelegate

  open func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    guard let listener = returnButtonListener else {
      return true
    }
    return listener.focusNextRowfrom(row: self)
  }

  // MARK: - Label highlighting

  @objc func textFieldDidBeginEditingHandler(_ textField: UITextField) {
    focus()
  }

  @objc func textFieldDidEndEditingHandler(_ textField: UITextField) {
    looseFocus()
  }

  @objc func textFieldDidChangeHandler(_ textField: UITextField) {
    presentPassedValidationResult()
  }

  @objc public func textField(_ textField: UITextField,
                              shouldChangeCharactersIn range: NSRange,
                              replacementString string: String) -> Bool {
    return true
  }

  // MARK: - Validation icon

  override func presentNonPassedValidationResult(_ reason: String) {
    super.presentNonPassedValidationResult(reason)
    textField.textColor = uiConfig.uiErrorColor
    shakeTextField()
  }

  override func presentPassedValidationResult() {
    super.presentPassedValidationResult()
    textField.textColor = self.textColor
  }

  // MARK: - Binding Extensions

  private var _bndValue: Observable<String?>?
  public var bndValue: Observable<String?> {
    if let bndValue = _bndValue {
      return bndValue
    }
    else {
      let bndValue = Observable<String?>(textField.text)
      bndValue.observeNext { [weak self] _ in
        self?.validateText(self?.textValidator, text: self?.textField.text)
      }.dispose(in: disposeBag)
      textField.reactive.text.bidirectionalBind(to: bndValue).dispose(in: disposeBag)
      _bndValue = bndValue
      return bndValue
    }
  }

  // MARK: - Private methods and attributes

  private func setUpTextField() {
    setUpTextFieldNotificationObservers()
    textField.delegate = self
    contentView.addSubview(textField)
  }

  private func setUpTextFieldNotificationObservers() {
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(textFieldDidBeginEditingHandler(_:)),
                                           name: NSNotification.Name.UITextFieldTextDidBeginEditing,
                                           object: textField)
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(textFieldDidEndEditingHandler(_:)),
                                           name: NSNotification.Name.UITextFieldTextDidEndEditing,
                                           object: textField)
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(textFieldDidChangeHandler(_:)),
                                           name: NSNotification.Name.UITextFieldTextDidChange,
                                           object: textField)
  }

  private func setUpContentView() {
    if let label = self.label {
      textField.snp.makeConstraints { make in
        make.top.equalTo(label.snp.bottom).offset(6)
        make.left.right.bottom.equalToSuperview()
        make.height.equalTo(height / 2)
      }
    }
    else {
      textField.snp.makeConstraints { make in
        make.left.right.top.bottom.equalToSuperview()
        make.height.equalTo(height / 2)
      }
    }
  }

  private func setUpTextFieldRightView() {
    if initiallyReadOnly {
      addEditButton()
    }
    else if toggleSecureEntryState {
      addToggleSecureTextButton()
    }
    if let button = textField.rightView as? UIButton {
      button.setTitleColor(UIColor.lightGray, for: .disabled)
    }
  }

  private func addEditButton() {
    setUpTextFieldRightView(image: UIImage.imageFromPodBundle("icon-field-edit")?.asTemplate(),
                            selector: #selector(editContents))
  }

  private func addToggleSecureTextButton() {
    setUpTextFieldRightView(image: UIImage.imageFromPodBundle("icon-field-show")?.asTemplate(),
                            selector: #selector(switchSecureText))
  }

  private func setUpTextFieldRightView(image: UIImage?, selector: Selector) {
    let button = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 20))
    button.tintColor = uiConfig.iconSecondaryColor
    button.setImage(image, for: .normal)
    button.addTarget(self, action: selector, for: .touchUpInside)
    textField.rightView = button
    textField.rightViewMode = .always
  }

  private func setUpValidationButton() {
    if textValidator != nil {
      bndValue.observeNext { text in
        let delayTime = DispatchTime.now() + Double(Int64(0.1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime) { [weak self] in
          guard let wself = self else {
            return
          }
          wself.validateText(wself.textValidator, text: text)
        }
      }.dispose(in: disposeBag)
    }
  }

  private func setUpLabelListener() {
    guard let label = self.label else {
      return
    }
    self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(labelTapped)))
    label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(labelTapped)))
  }

  private func shakeTextField() {
    textField.shake()
  }
}

class NonEmptyTextValidator: DataValidator<String> {
  init(failReasonMessage: String) {
    super.init(failReasonMessage: failReasonMessage) { text -> ValidationResult in
      guard let text = text else {
        return .fail(reason: failReasonMessage)
      }
      if !text.isEmpty {
        return .pass
      }
      else {
        return .fail(reason: failReasonMessage)
      }
    }
  }
}

class PatternTextValidator: DataValidator<String> {
  private let validPatterns: [String]

  init(validPatterns: [String], failReasonMessage: String) {
    self.validPatterns = validPatterns
    super.init(failReasonMessage: failReasonMessage) { text -> ValidationResult in
      guard let text = text else {
        return .fail(reason: failReasonMessage)
      }
      for pattern in validPatterns {
        if text.range(of: pattern, options: .regularExpression) != nil {
          return .pass
        }
      }
      return .fail(reason: failReasonMessage)
    }
  }
}

class SSNTextValidator: PatternTextValidator {
  static let unknownValidSSN = "   -  -    "

  init(failReasonMessage: String) {
    super.init(validPatterns: ["^\\d{3}-\\d{2}-\\d{4}$", "^   -  -    $"], failReasonMessage: failReasonMessage)
  }
}

class ZipCodeValidator: PatternTextValidator {
  init(failReasonMessage: String) {
    super.init(validPatterns: ["^\\d{5}$", "^\\d{5}(?:[-]\\d{4})?$"], failReasonMessage: failReasonMessage)
  }
}
