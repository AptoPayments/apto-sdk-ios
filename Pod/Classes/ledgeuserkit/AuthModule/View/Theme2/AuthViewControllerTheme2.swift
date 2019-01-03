//
//  AuthViewControllerTheme2.swift
//  ShiftSDK
//
//  Created by Takeichi Kanzaki on 30/10/2018.
//

import UIKit
import SnapKit

class AuthViewControllerTheme2: AuthViewControllerProtocol {
  private unowned let eventHandler: AuthEventHandler
  private let formView: MultiStepForm
  private let titleLabel: UILabel
  private let explanationLabel: UILabel
  private var continueButton: UIButton! // swiftlint:disable:this implicitly_unwrapped_optional
  private var shouldBecomeFirstResponder = true

  init(uiConfiguration: ShiftUIConfig, eventHandler: AuthEventHandler) {
    self.formView = MultiStepForm()
    self.eventHandler = eventHandler
    self.titleLabel = ComponentCatalog.largeTitleLabelWith(text: "", multiline: false, uiConfig: uiConfiguration)
    self.explanationLabel = ComponentCatalog.formLabelWith(text: "auth.input_phone.explanation".podLocalized(),
                                                           multiline: true,
                                                           lineSpacing: uiConfiguration.lineSpacing,
                                                           letterSpacing: uiConfiguration.letterSpacing,
                                                           uiConfig: uiConfiguration)
    super.init(uiConfiguration: uiConfiguration)
    self.continueButton = ComponentCatalog.buttonWith(title: "auth.input_phone.call_to_action.title".podLocalized(),
                                                      showShadow: false,
                                                      accessibilityLabel: "Continue button",
                                                      uiConfig: uiConfiguration) { [unowned self] in
      self.view.endEditing(true)
      self.nextTapped()
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    setUpUI()
    eventHandler.viewLoaded()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    if shouldBecomeFirstResponder {
      shouldBecomeFirstResponder = false
      formView.becomeFirstResponder()
    }
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Public methods

  func setTitle(_ title: String) {
    titleLabel.text = title
  }

  func show(fields: [FormRowView]) {
    formView.show(rows: fields)
  }

  func update(progress: Float) {
  }

  func showCancelButton() {
    showNavPreviousButton(uiConfiguration.uiSecondaryColor, uiTheme: .theme2)
  }

  func show(error: NSError) {
    super.show(error: error)
  }

  func showNextButton() {
    continueButton.isHidden = false
  }

  func activateNextButton() {
    continueButton.isEnabled = true
    continueButton.backgroundColor = uiConfiguration.uiPrimaryColor
  }

  func deactivateNextButton() {
    continueButton.isEnabled = false
    continueButton.backgroundColor = uiConfiguration.uiPrimaryColorDisabled
  }

  override func nextTapped() {
    eventHandler.nextTapped()
  }

  override func closeTapped() {
    eventHandler.closeTapped()
  }

  override func previousTapped() {
    eventHandler.closeTapped()
  }

  @objc func viewTapped() {
    formView.resignFirstResponder()
  }
}

// MARK: - Setup UI
private extension AuthViewControllerTheme2 {
  func setUpUI() {
    view.backgroundColor = uiConfiguration.uiBackgroundPrimaryColor
    view.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                     action: #selector(AuthViewControllerTheme2.viewTapped)))
    setUpNavigationBar()
    edgesForExtendedLayout = .top
    extendedLayoutIncludesOpaqueBars = false
    setUpTitleLabel()
    setUpExplanationLabel()
    setUpFormView()
    setUpContinueButton()
  }

  func setUpNavigationBar() {
    navigationController?.navigationBar.hideShadow()
    navigationController?.navigationBar.setUp(barTintColor: uiConfiguration.uiNavigationPrimaryColor,
                                              tintColor: uiConfiguration.uiSecondaryColor)
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
      make.top.equalTo(titleLabel.snp.bottom).offset(6)
    }
  }

  func setUpFormView() {
    view.addSubview(formView)
    formView.snp.makeConstraints { make in
      make.top.equalTo(explanationLabel.snp.bottom).offset(24)
      make.left.right.bottom.equalToSuperview()
    }
    formView.backgroundColor = UIColor.clear
  }

  func setUpContinueButton() {
    view.addSubview(continueButton)
    continueButton.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(20)
      make.bottom.equalToSuperview().inset(buttonBottomMargin)
    }
  }

  var buttonBottomMargin: Int {
    switch UIDevice.deviceType() {
    case .iPhone5:
      return 60
    case .iPhone678:
      return 250
    default:
      return 320
    }
  }
}
