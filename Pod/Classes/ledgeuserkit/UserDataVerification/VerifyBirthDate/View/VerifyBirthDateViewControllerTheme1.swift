//
//  VerifyBirthDateViewControllerTheme1.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 28/09/2016.
//
//

import UIKit
import SnapKit

class VerifyBirthDateViewControllerTheme1: VerifyBirthDateViewControllerProtocol {
  private unowned let presenter: VerifyBirthDateEventHandler
  private let formView: MultiStepForm
  private var submitButton: FormRowButtonView! // swiftlint:disable:this implicitly_unwrapped_optional
  private var birthdayField: FormRowDatePickerView! // swiftlint:disable:this implicitly_unwrapped_optional

  init(uiConfig: ShiftUIConfig, presenter: VerifyBirthDateEventHandler) {
    self.presenter = presenter
    self.formView = MultiStepForm()
    super.init(uiConfiguration: uiConfig)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    setUpUI()
    presenter.viewLoaded()
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
    presenter.closeTapped()
  }

  override func showLoadingSpinner() {
    let position = view.convert(submitButton.center, from: formView)
    showLoadingSpinner(tintColor: uiConfiguration.uiBackgroundPrimaryColor, position: .custom(coordinates: position))
  }
}

private extension VerifyBirthDateViewControllerTheme1 {
  func setUpUI() {
    title = "auth.verify_birthdate.title".podLocalized()
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
                                                     action: #selector(VerifyBirthDateViewControllerTheme1.viewTapped)))
  }

  func setUpNavigation() {
    view.backgroundColor = uiConfiguration.uiBackgroundPrimaryColor
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
    birthdayField = FormBuilder.datePickerRowWith(label: "auth.verify_birthdate.explanation".podLocalized(),
                                                  placeholder: "auth.verify_birthdate.placeholder".podLocalized(),
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
    submitButton = FormBuilder.buttonRowWith(title: "auth.verify_birthdate.call_to_action.title".podLocalized(),
                                             tapHandler: { [weak self] in
                                               guard let date = self?.birthdayField.bndDate.value else {
                                                 return
                                               }
                                               _ = self?.birthdayField.resignFirstResponder()
                                               self?.presenter.submitTapped(date)
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
