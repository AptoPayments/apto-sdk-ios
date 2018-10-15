//
//  PhoneTextField.swift
//  ShiftSDK
//
// Created by Takeichi Kanzaki on 28/09/2018.
//

import UIKit
import SnapKit
import Bond
import ReactiveKit
import PhoneNumberKit

public class PhoneTextField: UIView {
  private let allowedCountries: [Country]
  private let uiConfig: ShiftUIConfig

  private let disposeBag = DisposeBag()
  private let phoneHelper = PhoneHelper.sharedHelper()
  private let validator = InternationalPhoneValidator(failReasonMessage: "")

  private let countryTextField: UITextField
  private let countryPicker: CountryPicker
  private let phoneNumberField: PhoneNumberTextField

  public let countryCode: Observable<Int?> = Observable(nil)
  public let phoneNumber: Observable<String?> = Observable(nil)
  public let isValid: Observable<Bool> = Observable(false)

  public init(allowedCountries: [Country],
              placeholder: String,
              value: InternationalPhoneNumber?,
              accessibilityLabel: String? = nil,
              uiConfig: ShiftUIConfig) {
    guard let country = allowedCountries.first else {
      fatalError("At least one country is required")
    }
    self.allowedCountries = allowedCountries
    self.uiConfig = uiConfig
    let countryCode = phoneHelper.countryCode(for: country.isoCode)
    self.countryTextField = ComponentCatalog.formFieldWith(placeholder: "",
                                                           value: country.flag + "+" + String(countryCode),
                                                           uiConfig: uiConfig)
    self.countryPicker = CountryPicker(allowedCountries: allowedCountries,
                                       selectedCountry: country,
                                       showFlag: true,
                                       showPhoneCode: true,
                                       uiConfig: uiConfig)
    self.countryTextField.inputView = self.countryPicker
    self.phoneNumberField = ComponentCatalog.formPhoneTextFieldWith(placeholder: placeholder,
                                                                    value: nil,
                                                                    uiConfig: uiConfig)
    super.init(frame: .zero)
    setUpUI()
    setUpObservers()
    set(initialPhoneNumber: value)
    self.accessibilityLabel = accessibilityLabel
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private var _bndValue: Observable<InternationalPhoneNumber?>?
  public var bndValue: Observable<InternationalPhoneNumber?> {
    if let bndValue = _bndValue {
      return bndValue
    }
    let bndValue = Observable<InternationalPhoneNumber?>(InternationalPhoneNumber(countryCode: self.countryCode.value,
                                                                                  phoneNumber: self.phoneNumber.value))
    combineLatest(self.countryCode, self.phoneNumber).observeNext { [unowned bndValue] countryCode, phoneNumber in
      let intPhoneNumber = InternationalPhoneNumber(countryCode: countryCode, phoneNumber: phoneNumber)
      bndValue.next(intPhoneNumber)
    }.dispose(in: disposeBag)
    bndValue.observeNext { [unowned self] internationalPhoneNumber in
      let validationResult = self.validator.validate(internationalPhoneNumber)
      switch validationResult {
      case .fail:
        self.isValid.next(false)
      case .pass:
        self.isValid.next(true)
      }
    }.dispose(in: disposeBag)
    _bndValue = bndValue
    return bndValue
  }

  public override func becomeFirstResponder() -> Bool {
    return phoneNumberField.becomeFirstResponder()
  }

  public override func resignFirstResponder() -> Bool {
    return endEditing(true)
  }
}

// MARK: - Set up UI
private extension PhoneTextField {
  func setUpUI() {
    addSubview(phoneNumberField)
    addSubview(countryTextField)
    layoutCountryTextField()
    layoutPhoneNumber()
  }

  func layoutCountryTextField() {
    countryTextField.tintColor = .clear
    countryTextField.adjustsFontSizeToFitWidth = true
    countryTextField.delegate = self
    countryTextField.snp.makeConstraints { make in
      make.left.top.bottom.equalToSuperview()
      make.width.equalTo(90)
    }
  }

  func layoutPhoneNumber() {
    phoneNumberField.delegate = self
    phoneNumberField.snp.makeConstraints { make in
      make.left.equalTo(countryTextField.snp.right)
      make.top.right.bottom.equalToSuperview()
    }
  }

  func set(initialPhoneNumber: InternationalPhoneNumber?) {
    if let value = initialPhoneNumber {
      if let countryCode = value.countryCode,
         let country = allowedCountries.first(where: { $0.isoCode == phoneHelper.region(for: countryCode) }) {
        self.countryPicker.bndValue.next(country)
      }
      self.phoneNumberField.text = value.phoneNumber
    }
    else if let regionCode = Locale.current.regionCode,
            let country = allowedCountries.first(where: { $0.isoCode == regionCode }) {
      self.countryPicker.bndValue.next(country)
    }
    else {
      self.countryPicker.bndValue.next(allowedCountries[0])
    }
  }
}

// MARK: - Reactive Observers
private extension PhoneTextField {
  func setUpObservers() {
    setUpCountryObserver()
    setUpPhoneNumberObserver()
  }

  func setUpCountryObserver() {
    countryPicker.bndValue.observeNext { [unowned self] country in
      let countryCode = self.phoneHelper.countryCode(for: country.isoCode)
      self.countryCode.next(countryCode)
      var formattedCountryCode = "\(country.flag)+\(countryCode)"
      if self.allowedCountries.count > 1 {
        formattedCountryCode += String.dropDownCharacter
      }
      self.countryTextField.text = formattedCountryCode
      self.countryTextField.positionCursor(atIndex: 0)
      self.phoneNumberField.defaultRegion = country.isoCode
    }.dispose(in: disposeBag)
  }

  func setUpPhoneNumberObserver() {
    phoneNumberField.reactive.text.observeNext { [unowned self] phoneNumber in
      self.phoneNumber.next(phoneNumber)
    }.dispose(in: disposeBag)
  }
}

extension PhoneTextField: UITextFieldDelegate {
  public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
    if textField == countryTextField {
      return allowedCountries.count > 1
    }

    return true
  }

  open func textFieldDidBeginEditing(_ textField: UITextField) {
    textField.textColor = uiConfig.textSecondaryColor
  }

  open func textFieldDidEndEditing(_ textField: UITextField) {
    guard textField == phoneNumberField else { return }
    if !isValid.value {
      textField.shake()
      textField.textColor = uiConfig.uiErrorColor
    }
  }
}

public struct InternationalPhoneNumber {
  let countryCode: Int?
  let phoneNumber: String?
}

class InternationalPhoneValidator: DataValidator<InternationalPhoneNumber> {
  init(failReasonMessage: String) {
    super.init(failReasonMessage: failReasonMessage) { phone in
      let validPhone = PhoneHelper.sharedHelper().validatePhoneWith(countryCode: phone?.countryCode,
                                                                    nationalNumber: phone?.phoneNumber)
      return validPhone ? .pass : .fail(reason: failReasonMessage)
    }
  }
}
