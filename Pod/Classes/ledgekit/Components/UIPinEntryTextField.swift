//
//  UIPinEntryTextField.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 18/07/2017.
//
//

import UIKit
import SnapKit

@objc protocol UIPinEntryTextFieldDelegate {
  func pinEntryTextField(didFinishInput frPinView: UIPinEntryTextField)
  @objc optional func pinEntryTextField(didDeletePin frPinView: UIPinEntryTextField)
}

class UIPinEntryTextField: UIView {
  // Constants
  fileprivate struct Constants {
    static let InvisibleSign = "\u{200B}"
  }

  // Variables
  private let stackView = UIStackView()
  private var textFields = [UITextField]()
  private var keyboardType: UIKeyboardType = .numberPad
  private var pinViewWidth: Int {
    return (pinWidth * pinCount) + (pinSpacing * pinCount)
  }
  private let middleSeparatorView = UIView()
  private var separatorView: UIView {
    return middleSeparatorView.subviews[0]
  }

  weak var delegate: UIPinEntryTextFieldDelegate?

  // Outlets
  @IBInspectable var pinCount: Int = 6
  @IBInspectable var pinSpacing: Int = 4
  @IBInspectable var pinWidth: Int = 32
  @IBInspectable var pinHeight: Int = 44
  @IBInspectable var pinCornerRadius: CGFloat = 5
  @IBInspectable var pinBorderWidth: CGFloat = 1
  @IBInspectable var textColor: UIColor = .black {
    didSet {
      textFields.forEach { $0.textColor = textColor }
    }
  }
  @IBInspectable var pinBorderColor: UIColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.00) {
    didSet {
      textFields.forEach { $0.layer.borderColor = pinBorderColor.cgColor }
      separatorView.backgroundColor = pinBorderColor
    }
  }
  @IBInspectable var showMiddleSeparator: Bool = true {
    didSet {
      middleSeparatorView.isHidden = !showMiddleSeparator
    }
  }
  @IBInspectable var middleSeparatorWidth: CGFloat = 12 {
    didSet {
      separatorView.snp.updateConstraints { make in
        make.width.equalTo(middleSeparatorWidth)
      }
    }
  }
  @IBInspectable var middleSeparatorHeight: CGFloat = 2 {
    didSet {
      separatorView.snp.updateConstraints { make in
        make.width.equalTo(middleSeparatorHeight)
      }
    }
  }

  init(size: Int, frame: CGRect, accessibilityLabel: String? = nil) {
    super.init(frame: frame)

    // Styling textfield
    self.pinCount = size

    if let accessibilityLabel = accessibilityLabel {
      self.accessibilityLabel = accessibilityLabel
      self.isAccessibilityElement = true
    }

    self.createTextFields()
    self.createMiddleSeparator()
    self.setUpStackView()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    self.createTextFields()
    self.createMiddleSeparator()
    self.setUpStackView()
  }

  /// Generate textfield
  private func createTextFields() {
    // Create textfield based on size
    for index in 0..<self.pinCount {
      let textField = UITextField()

      // Set textfield params
      textField.keyboardType = keyboardType
      textField.textAlignment = .center
      textField.backgroundColor = self.backgroundColor
      textField.tintColor = self.backgroundColor
      textField.textColor = self.textColor
      textField.delegate = self
      if let accessibilityLabel = self.accessibilityLabel {
        textField.accessibilityLabel = accessibilityLabel + " (" + String(index + 1) + ")"
      }

      // Styling textfield
      textField.layer.cornerRadius = self.pinCornerRadius
      textField.layer.borderWidth = self.pinBorderWidth
      textField.layer.borderColor = self.pinBorderColor.cgColor

      NotificationCenter.default.addObserver(self,
                                             selector: #selector(fieldChanged),
                                             name: NSNotification.Name.UITextFieldTextDidChange,
                                             object: textField)

      textFields.append(textField)
    }
  }

  private func createMiddleSeparator() {
    middleSeparatorView.backgroundColor = .clear
    middleSeparatorView.isHidden = !showMiddleSeparator
    addSubview(middleSeparatorView)

    let separatorView = UIView()
    separatorView.backgroundColor = pinBorderColor
    middleSeparatorView.addSubview(separatorView)
    separatorView.snp.makeConstraints { make in
      make.center.equalToSuperview()
      make.width.equalTo(middleSeparatorWidth)
      make.height.equalTo(middleSeparatorHeight)
    }
  }

  /// Make textfield rounded
  private func setUpStackView() {
    addSubview(stackView)
    stackView.snp.makeConstraints { make in
      make.top.left.right.bottom.equalToSuperview()
    }
    stackView.distribution = .fillEqually
    stackView.axis = .horizontal
    textFields.forEach {
      stackView.addArrangedSubview($0)
    }
    let middleIndex = textFields.count / 2
    stackView.insertArrangedSubview(middleSeparatorView, at: middleIndex)
    let shouldShowSeparator = showMiddleSeparator && (textFields.count % 2 == 0)
    middleSeparatorView.isHidden = !shouldShowSeparator
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    let visibleSubviews = middleSeparatorView.isHidden ? textFields.count : textFields.count + 1
    stackView.spacing = (bounds.size.width - CGFloat(visibleSubviews * pinWidth)) / CGFloat(visibleSubviews - 1)
  }

  /// Move forward to textfield
  ///
  /// - Parameter textField: textField Current textfield
  private func moveFrom(currentTextField textField: UITextField) {
    guard let index = textFields.index(of: textField), index < (pinCount - 1) else {
      return
    }
    textFields[index + 1].text = Constants.InvisibleSign
    textFields[index + 1].becomeFirstResponder()
  }

  /// Move backward from textfield
  ///
  /// - Parameter textField: textField Current textfield
  private func moveBackwardFrom(currentTextField textField: UITextField) {
    guard let index = textFields.index(of: textField), index > 0 else {
      return
    }
    textFields[index].text = ""
    textFields[index - 1].text = Constants.InvisibleSign
    textFields[index - 1].becomeFirstResponder()
  }

  /// Get text from all pin textfields
  ///
  /// - Returns: return String Text from all pin textfields
  func getText() -> String {
    var pin = ""
    for textField in textFields {
      if let text = textField.text {
        pin += text
      }
    }
    return pin.replacingOccurrences(of: Constants.InvisibleSign, with: "")
  }

  /// Reset text values
  func resetText() {
    textFields.forEach { $0.text = "" }
    textFields[0].text = Constants.InvisibleSign
  }

  /// Make the first textfield become first responder
  func focus() {
    textFields[0].becomeFirstResponder()
  }

  override func resignFirstResponder() -> Bool {
    for textField in textFields {
      textField.resignFirstResponder()
    }
    return true
  }

  @objc private func fieldChanged(_ notification: Notification) {
    if let sender = notification.object as? UITextField {
      if var text = sender.text {
        if text.count == 1 && text != Constants.InvisibleSign {
          text = Constants.InvisibleSign + text
          sender.text = text
        }
      }
      if sender == textFields.last && self.getText().count == self.pinCount {
        let delayTime = DispatchTime.now() + Double(Int64(0.25 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
          self.delegate?.pinEntryTextField(didFinishInput: self)
        }
      }
    }
  }
}

extension UIPinEntryTextField: UITextFieldDelegate {
  func textField(_ textField: UITextField,
                 shouldChangeCharactersIn range: NSRange,
                 replacementString string: String) -> Bool {
    let char = string.cString(using: String.Encoding.utf8)! // swiftlint:disable:this force_unwrapping
    let isBackSpace = strcmp(char, "\\b")

    if isBackSpace == -92 {
      if var string = textField.text {
        string = string.replacingOccurrences(of: Constants.InvisibleSign, with: "")
        if string.isEmpty {
          //last visible character, if needed u can skip replacement and detect once even in empty text field
          //for example u can switch to prev textField
          let delayTime = DispatchTime.now() + Double(Int64(0.001 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
          DispatchQueue.main.asyncAfter(deadline: delayTime) {
            self.moveBackwardFrom(currentTextField: textField)
          }
        }
      }
    }
    else {
      let delayTime = DispatchTime.now() + Double(Int64(0.001 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
      DispatchQueue.main.asyncAfter(deadline: delayTime) {
        self.moveFrom(currentTextField: textField)
      }
    }
    return true
  }
}
