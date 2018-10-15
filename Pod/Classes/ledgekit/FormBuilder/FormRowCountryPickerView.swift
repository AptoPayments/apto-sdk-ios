//
//  FormRowCountryPickerView.swift
//  ShiftSDK
//
// Created by Takeichi Kanzaki on 09/10/2018.
//

import SnapKit
import Bond
import ReactiveKit

class FormRowCountryPickerView: FormRowView {
  private var disposeBag = DisposeBag()
  private let label: UILabel
  private let textField: UITextField
  private let allowedCountries: [Country]
  private let uiConfig: ShiftUIConfig
  private let countryPicker: CountryPicker
  private let height: CGFloat

  override var isEnabled: Bool {
    get {
      return super.isEnabled
    }
    set {
      super.isEnabled = newValue
      label.textColor = newValue ? uiConfig.textPrimaryColor : uiConfig.textPrimaryColorDisabled
      textField.isEnabled = newValue
      textField.textColor = newValue ? uiConfig.textSecondaryColor : uiConfig.textSecondaryColorDisabled
    }
  }

  init(label: UILabel,
       textField: UITextField,
       allowedCountries: [Country],
       value: Country? = nil,
       height: CGFloat = 80,
       uiConfig: ShiftUIConfig) {
    self.label = label
    self.textField = textField
    self.allowedCountries = allowedCountries
    self.uiConfig = uiConfig
    self.height = height
    self.countryPicker = CountryPicker(allowedCountries: allowedCountries,
                                       selectedCountry: value,
                                       showFlag: false,
                                       showPhoneCode: false,
                                       uiConfig: uiConfig)
    super.init(showSplitter: false, height: height)

    setUpUI()
    setUpObservers()
  }

  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  var bndValue: Observable<Country> {
    return countryPicker.bndValue
  }
}

// MARK: - Reactive observers
private extension FormRowCountryPickerView {
  func setUpObservers() {
    countryPicker.bndValue.observeNext { [unowned self] country in
      var text = country.name
      if self.allowedCountries.count > 1 {
        text += " " + String.dropDownCharacter
      }
      self.textField.text = text
      self.valid.next(true)
    }.dispose(in: disposeBag)
  }
}

// MARK: - Set up UI
private extension FormRowCountryPickerView {
  func setUpUI() {
    backgroundColor = uiConfig.backgroundColor
    setUpLabel()
    setUpTextField()
  }

  func setUpLabel() {
    contentView.addSubview(label)
    label.snp.makeConstraints { make in
      make.left.equalToSuperview()
      make.top.equalToSuperview().offset(16)
    }
  }

  func setUpTextField() {
    contentView.addSubview(textField)
    textField.snp.makeConstraints { make in
      make.top.equalTo(label.snp.bottom).offset(6)
      make.left.right.bottom.equalToSuperview()
      make.height.equalTo(height / 2)
    }
    textField.inputView = countryPicker
  }
}
