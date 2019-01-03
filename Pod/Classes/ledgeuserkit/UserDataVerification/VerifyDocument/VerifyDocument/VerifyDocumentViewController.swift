//
//  VerifyDocumentViewController.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 22/03/2018.
//
//

import UIKit

protocol VerifyDocumentEventHandler {
  var viewModel: VerifyDocumentViewModel { get }
  func viewLoaded()
  func closeTapped()
  func continueTapped()
  func retakePicturesTapped()
  func retakeSelfieTapped()
}

class VerifyDocumentViewController: ShiftViewController {
  private let eventHandler: VerifyDocumentEventHandler
  private var icon = UIImageView()
  private var explanationLabel: UILabel! // swiftlint:disable:this implicitly_unwrapped_optional
  private var continueButton: UIButton! // swiftlint:disable:this implicitly_unwrapped_optional
  private var retakePicturesButton: UIButton! // swiftlint:disable:this implicitly_unwrapped_optional
  private var retakeSelfieButton: UIButton! // swiftlint:disable:this implicitly_unwrapped_optional

  open override var preferredStatusBarStyle: UIStatusBarStyle {
    return .default
  }

  init(uiConfiguration: ShiftUIConfig, eventHandler: VerifyDocumentEventHandler) {
    self.eventHandler = eventHandler
    super.init(uiConfiguration: uiConfiguration)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = uiConfiguration.uiBackgroundPrimaryColor
    setUpIcon()
    setUpExplanationLabel()
    setUpContinueButton()
    setUpRetakePicturesButton()
    setUpRetakeSelfieButton()

    // Setup viewModel subscriptions
    setupViewModelSubscriptions()

    eventHandler.viewLoaded()
  }

  // Setup subviews
  private func setUpRetakeSelfieButton() {
    let title = "verify_document.retake_selfie_button.title".podLocalized()
    retakeSelfieButton = ComponentCatalog.buttonWith(title: title, uiConfig: uiConfiguration) { [weak self] in
      self?.eventHandler.retakeSelfieTapped()
    }
    retakeSelfieButton.tintColor = UIColor.colorFromHex(0x7F0000)
    view.addSubview(retakeSelfieButton)
    retakeSelfieButton.snp.makeConstraints { make in
      make.left.right.equalTo(view).inset(16)
      make.bottom.equalTo(bottomLayoutGuide.snp.top).inset(-16)
    }
  }

  private func setUpRetakePicturesButton() {
    let title = "verify_document.retake_pictures_button.title".podLocalized()
    retakePicturesButton = ComponentCatalog.buttonWith(title: title, uiConfig: uiConfiguration) { [weak self] in
      self?.eventHandler.retakePicturesTapped()
    }
    retakePicturesButton.tintColor = UIColor.colorFromHex(0x7F0000)
    view.addSubview(retakePicturesButton)
    retakePicturesButton.snp.makeConstraints { make in
      make.left.right.equalTo(view).inset(16)
      make.bottom.equalTo(bottomLayoutGuide.snp.top).inset(-16)
    }
  }

  private func setUpContinueButton() {
    let title = "verify_document.continue_button.title".podLocalized()
    continueButton = ComponentCatalog.buttonWith(title: title, uiConfig: uiConfiguration) { [weak self] in
      self?.eventHandler.continueTapped()
    }
    view.addSubview(continueButton)
    continueButton.snp.makeConstraints { make in
      make.left.right.equalTo(view).inset(16)
      make.bottom.equalTo(bottomLayoutGuide.snp.top).inset(-16)
    }
  }

  private func setUpExplanationLabel() {
    explanationLabel = ComponentCatalog.instructionsLabelWith(text: "",
                                                              textAlignment: .center,
                                                              accessibilityLabel: "Verify Document Explanation",
                                                              uiConfig: uiConfiguration)
    explanationLabel.font = uiConfiguration.shiftFont
    explanationLabel.textColor = uiConfiguration.noteTextColor
    explanationLabel.numberOfLines = 0
    view.addSubview(explanationLabel)
    explanationLabel.snp.makeConstraints { make in
      make.centerX.equalTo(view)
      make.left.right.equalTo(view).inset(16)
      make.top.equalTo(icon.snp.bottom).offset(32)
    }
  }

  private func setUpIcon() {
    icon.image = UIImage.imageFromPodBundle("verify_email_icon")
    view.addSubview(icon)
    icon.snp.makeConstraints { make in
      make.top.equalTo(view).offset(184)
      make.centerX.equalTo(view)
      make.width.height.equalTo(132)
    }
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationItem.setHidesBackButton(true, animated: false)
    self.setNavigationBar(tintColor: UIColor.black)
  }

  func setupViewModelSubscriptions() {
    let viewModel = eventHandler.viewModel

    _ = viewModel.state.observeNext { [weak self] newState in
      switch newState {
      case .processing:
        self?.showProcessingState()
      case .success:
        self?.showSuccessState()
      case .error(let error):
        self?.showErrorState(error: error)
      case .selfieDoNotMatch:
        self?.showSelfieDoNotMatchState()
      }
    }
  }

  private func showProcessingState() {
    explanationLabel.text = "verify_document.explanation.processing".podLocalized()
    continueButton.isHidden = true
    retakePicturesButton.isHidden = true
    retakeSelfieButton.isHidden = true
    icon.image = UIImage.imageFromPodBundle("verify-docs")
  }

  private func showSuccessState() {
    explanationLabel.text = "verify_document.explanation.success".podLocalized()
    continueButton.isHidden = false
    retakePicturesButton.isHidden = true
    retakeSelfieButton.isHidden = true
    icon.image = UIImage.imageFromPodBundle("docs-ok")
  }

  private func showErrorState(error: String?) {
    explanationLabel.text = error
    continueButton.isHidden = true
    retakePicturesButton.isHidden = false
    retakeSelfieButton.isHidden = true
    icon.image = UIImage.imageFromPodBundle("docs-error")
  }

  private func showSelfieDoNotMatchState() {
    explanationLabel.text = "verify_document.explanation.selfie_do_not_match".podLocalized()
    continueButton.isHidden = true
    retakePicturesButton.isHidden = true
    retakeSelfieButton.isHidden = false
    icon.image = UIImage.imageFromPodBundle("selfie-error")
  }

  override func closeTapped() {
    eventHandler.closeTapped()
  }
}
