//
//  VerifyPhoneViewController.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 28/09/2016.
//
//

import UIKit
import SnapKit

protocol VerifyBirthDateEventHandler: class {
  func viewLoaded()
  func submitTapped(_ birthDate: Date)
  func closeTapped()
}

class VerifyBirthDateViewController: ShiftViewController, VerifyBirthDateViewControllerProtocol {
  private let formView: MultiStepForm
  private var submitButton: FormRowButtonView! // swiftlint:disable:this implicitly_unwrapped_optional
  private var birthdayField: FormRowDatePickerView! // swiftlint:disable:this implicitly_unwrapped_optional

  weak var eventHandler: VerifyBirthDateEventHandler?

  init(uiConfig: ShiftUIConfig) {
    self.formView = MultiStepForm()
    super.init(uiConfiguration: uiConfig)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    setUpUI()
    self.eventHandler?.viewLoaded()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
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

  // MARK: - Private methods

  @objc func viewTapped() {
    _ = birthdayField.resignFirstResponder()
  }

  override func closeTapped() {
    eventHandler?.closeTapped()
  }

  func showLoadingSpinner() {
    let position = view.convert(submitButton.center, from: formView)
    showLoadingSpinner(tintColor: uiConfiguration.backgroundColor, position: .custom(coordinates: position))
  }
}

private extension VerifyBirthDateViewController {
  func setUpUI() {
    title = "verify_birthdate.title".podLocalized()
    setUpNavigation()
    setUpFormView()
    setUpBirthdayField()
    setUpSubmitButton()
    setUpBirthdayObserver()

    formView.show(rows: [
      FormBuilder.separatorRow(height: 128),
      birthdayField,
      FormBuilder.separatorRow(height: 56),
      submitButton
    ])
    view.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                     action: #selector(VerifyBirthDateViewController.viewTapped)))
  }

  func setUpNavigation() {
    view.backgroundColor = uiConfiguration.backgroundColor
    navigationController?.navigationBar.setUpWith(uiConfig: uiConfiguration)
    edgesForExtendedLayout = .top
    extendedLayoutIncludesOpaqueBars = true
  }

  func setUpFormView() {
    view.addSubview(formView)
    formView.snp.makeConstraints { make in
      make.top.equalTo(topLayoutGuide.snp.bottom)
      make.left.right.bottom.equalToSuperview()
    }
    formView.backgroundColor = view.backgroundColor
  }

  func setUpBirthdayField() {
    let failureReasonMessage = "verify_birthdate.birthday.warning.minimum-date".podLocalized()
    let validator = MaximumDateValidator(maximumDate: Date(), failReasonMessage: failureReasonMessage)
    birthdayField = FormBuilder.datePickerRowWith(label: "verify_birthdate.birthday".podLocalized(),
                                                  placeholder: "verify_birthdate.birthday.placeholder".podLocalized(),
                                                  format: .dateOnly,
                                                  value: nil,
                                                  validator: validator,
                                                  firstFormField: true,
                                                  lastFormField: true,
                                                  uiConfig: uiConfiguration)
    birthdayField.showSplitter = false
    _ = birthdayField.becomeFirstResponder()
  }

  func setUpSubmitButton() {
    submitButton = FormBuilder.buttonRowWith(title: "verify_birthdate.submit_button.title".podLocalized(),
                                             tapHandler: { [weak self] in
                                               guard let date = self?.birthdayField.bndDate.value else {
                                                 return
                                               }
                                               _ = self?.birthdayField.resignFirstResponder()
                                               self?.eventHandler?.submitTapped(date)
                                             },
                                             uiConfig: uiConfiguration)
  }

  func setUpBirthdayObserver() {
    _ = birthdayField.valid.observeNext { [unowned self] valid in
      self.submitButton.isEnabled = valid
      let config = self.uiConfiguration
      self.submitButton.button.backgroundColor = valid ? config.uiPrimaryColor : config.uiPrimaryColorDisabled
    }
  }
}
