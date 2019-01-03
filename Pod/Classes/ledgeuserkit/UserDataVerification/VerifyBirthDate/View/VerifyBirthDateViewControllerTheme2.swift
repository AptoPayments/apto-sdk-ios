//
// VerifyBirthDateViewControllerTheme2.swift
// ShiftSDK
//
// Created by Takeichi Kanzaki on 13/11/2018.
//

import UIKit
import SnapKit
import Bond
import ReactiveKit

class VerifyBirthDateViewControllerTheme2: VerifyBirthDateViewControllerProtocol {
  private let disposeBag = DisposeBag()
  private unowned let presenter: VerifyBirthDateEventHandler
  private let titleLabel: UILabel
  private let explanationLabel: UILabel
  // swiftlint:disable implicitly_unwrapped_optional
  private var submitButton: UIButton!
  private var birthdayField: FormRowDatePickerView!
  // swiftlint:enable implicitly_unwrapped_optional

  init(uiConfig: ShiftUIConfig, presenter: VerifyBirthDateEventHandler) {
    self.presenter = presenter
    self.titleLabel = ComponentCatalog.largeTitleLabelWith(text: "auth.verify_birthdate.title".podLocalized(),
                                                           multiline: false,
                                                           uiConfig: uiConfig)
    self.explanationLabel = ComponentCatalog.formLabelWith(text: "auth.verify_birthdate.explanation".podLocalized(),
                                                           multiline: true,
                                                           lineSpacing: uiConfig.lineSpacing,
                                                           letterSpacing: uiConfig.letterSpacing,
                                                           uiConfig: uiConfig)
    super.init(uiConfiguration: uiConfig)
    self.submitButton = ComponentCatalog.buttonWith(title: "auth.verify_birthdate.call_to_action.title".podLocalized(),
                                                    showShadow: false,
                                                    uiConfig: uiConfig) { [weak self] in
      guard let date = self?.birthdayField.bndDate.value else {
        return
      }
      _ = self?.birthdayField.resignFirstResponder()
      self?.presenter.submitTapped(date)
    }
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    setUpUI()
    presenter.viewLoaded()
  }

  // MARK: - Public methods

  func showWrongBirthDateErrorMessage() {
    show(error: BackendError(code: .birthDateVerificationFailed))
    birthdayField.bndDate.next(nil)
    let delayTime = DispatchTime.now() + Double(Int64(0.25 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
    DispatchQueue.main.asyncAfter(deadline: delayTime) { [weak self] in
      self?.birthdayField.focus()
    }
  }

  @objc func viewTapped() {
    _ = birthdayField.resignFirstResponder()
  }

  override func closeTapped() {
    presenter.closeTapped()
  }

  override func showLoadingSpinner() {
    let position = submitButton.center
    showLoadingSpinner(tintColor: uiConfiguration.uiBackgroundPrimaryColor, position: .custom(coordinates: position))
  }
}

private extension VerifyBirthDateViewControllerTheme2 {
  func setUpUI() {
    view.backgroundColor = uiConfiguration.uiBackgroundPrimaryColor
    view.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                     action: #selector(VerifyBirthDateViewControllerTheme2.viewTapped)))
    setUpNavigation()
    setUpTitleLabel()
    setUpExplanationLabel()
    setUpBirthdayField()
    setUpSubmitButton()
    setUpBirthdayObserver()
  }

  func setUpNavigation() {
    navigationController?.navigationBar.hideShadow()
    navigationController?.navigationBar.setUp(barTintColor: uiConfiguration.uiNavigationPrimaryColor,
                                              tintColor: uiConfiguration.uiSecondaryColor)
    showNavCancelButton(uiConfiguration.uiSecondaryColor, uiTheme: .theme2)
    edgesForExtendedLayout = .top
    extendedLayoutIncludesOpaqueBars = false
  }

  func setUpTitleLabel() {
    titleLabel.adjustsFontSizeToFitWidth = true
    view.addSubview(titleLabel)
    titleLabel.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(20)
      make.top.equalToSuperview().offset(16)
    }
  }

  func setUpExplanationLabel() {
    view.addSubview(explanationLabel)
    explanationLabel.snp.makeConstraints { make in
      make.left.right.equalTo(titleLabel)
      make.top.equalTo(titleLabel.snp.bottom).offset(10)
    }
  }

  func setUpBirthdayField() {
    let failureReasonMessage = "verify_birthdate.birthday.warning.minimum-date".podLocalized()
    let validator = MaximumDateValidator(maximumDate: Date(), failReasonMessage: failureReasonMessage)
    birthdayField = FormBuilder.datePickerRowWith(label: nil,
                                                  placeholder: "auth.verify_birthdate.placeholder".podLocalized(),
                                                  format: .dateOnly,
                                                  value: nil,
                                                  validator: validator,
                                                  firstFormField: true,
                                                  lastFormField: true,
                                                  uiConfig: uiConfiguration)
    birthdayField.showSplitter = false
    view.addSubview(birthdayField)
    birthdayField.snp.makeConstraints { make in
      make.left.right.equalTo(titleLabel)
      make.top.equalTo(explanationLabel.snp.bottom).offset(44)
    }
    _ = birthdayField.becomeFirstResponder()
  }

  func setUpSubmitButton() {
    view.addSubview(submitButton)
    submitButton.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(20)
      make.bottom.equalToSuperview().inset(submitBottomMargin)
    }
  }

  var submitBottomMargin: Int {
    switch UIDevice.deviceType() {
    case .iPhone5:
      return 220
    default:
      return 250
    }
  }

  func setUpBirthdayObserver() {
    birthdayField.valid.observeNext { [unowned self] valid in
      self.submitButton.isEnabled = valid
      let config = self.uiConfiguration
      self.submitButton.backgroundColor = valid ? config.uiPrimaryColor : config.uiPrimaryColorDisabled
    }.dispose(in: disposeBag)
  }
}
