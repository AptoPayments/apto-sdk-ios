//
//  CountryPicker.swift
//  ShiftSDK
//
// Created by Takeichi Kanzaki on 01/10/2018.
//

import Bond
import ReactiveKit
import SnapKit

class CountryPicker: UIView {
  private let disposeBag = DisposeBag()
  let picker: UIPickerView
  private let allowedCountries: [Country]
  private var selectedCountry: Country
  private let showFlag: Bool
  private let showPhoneCode: Bool
  private let phoneHelper = PhoneHelper.sharedHelper()
  private let uiConfig: ShiftUIConfig

  init(allowedCountries: [Country],
       selectedCountry: Country? = nil,
       showFlag: Bool,
       showPhoneCode: Bool,
       uiConfig: ShiftUIConfig) {
    guard let firstCountry = allowedCountries.first else {
      fatalError("At least one country is required")
    }
    self.uiConfig = uiConfig
    self.allowedCountries = allowedCountries
    self.showFlag = showFlag
    self.showPhoneCode = showPhoneCode
    self.picker = UIPickerView()
    self.selectedCountry = selectedCountry ?? firstCountry
    super.init(frame: .zero)

    setUpUI()
  }

  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private var _bndValue: Observable<Country>?
  var bndValue: Observable<Country> {
    if let bndValue = _bndValue {
      return bndValue
    }
    else {
      let bndValue = Observable<Country>(selectedCountry)
      bndValue.observeNext { [weak self] (country: Country) in
        guard let self = self else { return }
        self.selectedCountry = country
        if let selectedIndex = self.allowedCountries.index(where: { $0 == country }) {
          self.picker.selectRow(selectedIndex, inComponent: 0, animated: false)
        }
      }.dispose(in: disposeBag)
      _bndValue = bndValue
      return bndValue
    }
  }

  override var intrinsicContentSize: CGSize {
    return picker.intrinsicContentSize
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    picker.frame = bounds
  }
}

private extension CountryPicker {
  func setUpUI() {
    // This is required for the view to get sized to the iOS keyboard size
    autoresizingMask = [.flexibleHeight, .flexibleWidth]
    addSubview(picker)
    picker.dataSource = self
    picker.delegate = self
  }
}

extension CountryPicker: UIPickerViewDataSource {
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }

  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return allowedCountries.count
  }
}

extension CountryPicker: UIPickerViewDelegate {
  public func pickerView(_ pickerView: UIPickerView,
                         viewForRow row: Int,
                         forComponent component: Int,
                         reusing view: UIView?) -> UIView {
    let countryLabel: CountryLabel
    if let reusing = view as? CountryLabel {
      countryLabel = reusing
    }
    else {
      countryLabel = CountryLabel(showFlag: showFlag, showPhoneCode: showPhoneCode, uiConfig: uiConfig)
    }
    countryLabel.country = allowedCountries[row]
    return countryLabel
  }

  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    bndValue.next(allowedCountries[row])
  }
}

private class CountryLabel: UIView {
  private let showFlag: Bool
  private let showPhoneCode: Bool
  private let phoneHelper = PhoneHelper.sharedHelper()
  var country: Country? {
    didSet {
      guard let country = country else { return }
      self.flagLabel.text = showFlag ? country.flag : nil
      self.codeLabel.text = showPhoneCode ? "+\(phoneHelper.countryCode(for: country.isoCode))" : nil
      self.nameLabel.text = country.name
    }
  }

  private let flagLabel: UILabel
  private let codeLabel: UILabel
  private let nameLabel: UILabel

  init(showFlag: Bool, showPhoneCode: Bool, uiConfig: ShiftUIConfig) {
    self.showFlag = showFlag
    self.showPhoneCode = showPhoneCode
    self.flagLabel = ComponentCatalog.formLabelWith(text: "", uiConfig: uiConfig)
    self.codeLabel = ComponentCatalog.formLabelWith(text: "", uiConfig: uiConfig)
    self.nameLabel = ComponentCatalog.formLabelWith(text: "", uiConfig: uiConfig)

    super.init(frame: .zero)

    setUpUI()
  }

  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setUpUI() {
    layoutFlag()
    layoutCode()
    layoutName()
  }

  private func layoutFlag() {
    addSubview(flagLabel)
    flagLabel.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(16)
      make.top.bottom.equalToSuperview()
      let width = showFlag ? 25 : 4
      make.width.equalTo(width)
    }
  }

  private func layoutCode() {
    addSubview(codeLabel)
    codeLabel.textAlignment = .right
    codeLabel.snp.makeConstraints { make in
      make.left.equalTo(flagLabel.snp.right)
      make.top.bottom.equalToSuperview()
      let width = showPhoneCode ? 50 : 4
      make.width.equalTo(width)
    }
  }

  private func layoutName() {
    addSubview(nameLabel)
    nameLabel.snp.makeConstraints { make in
      make.top.bottom.equalToSuperview()
      make.left.equalTo(codeLabel.snp.right).offset(8)
      make.right.equalToSuperview().inset(16)
    }
  }
}
