//
//  PINVerificationViewController.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 28/09/2016.
//
//

import UIKit
import Bond
import SnapKit

class PINVerificationViewController: ShiftViewController, PINVerificationView {
  private unowned let eventHandler: PINVerificationPresenter
  // swiftlint:disable implicitly_unwrapped_optional
  private var titleLabel: UILabel!
  private var datapointValueLabel: UILabel!
  private var pinEntryView: UIPinEntryTextField!
  private var resendButton: UIButton!
  // swiftlint:enable implicitly_unwrapped_optional

  init(uiConfig: ShiftUIConfig, eventHandler: PINVerificationPresenter) {
    self.eventHandler = eventHandler
    super.init(uiConfiguration: uiConfig)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    setUpUI()
    setupViewModelSubscriptions()
    eventHandler.viewLoaded()
  }

  private func setupViewModelSubscriptions() {
    let viewModel = eventHandler.viewModel
    _ = viewModel.datapointValue.observeNext { phoneNumber in
      self.datapointValueLabel.text = phoneNumber
    }
    _ = viewModel.title.observeNext { title in
      self.title = title
    }
    _ = viewModel.subtitle.observeNext { subtitle in
      self.titleLabel.text = subtitle
    }
    _ = viewModel.resendButtonTitle.ignoreNil().observeNext { resendButtonTitle in
      self.set(resendButtonTitle: resendButtonTitle)
    }
  }

  private func set(resendButtonTitle: String) {
    guard let attributedTitle = self.resendButton.attributedTitle(for: .normal) else {
      return
    }
    let mutableAttributedString = NSMutableAttributedString(attributedString: attributedTitle)
    mutableAttributedString.mutableString.setString(resendButtonTitle)
    self.resendButton.setAttributedTitle(mutableAttributedString, for: .normal)
  }

  @objc func viewTapped() {
    _ = pinEntryView.resignFirstResponder()
  }

  func showWrongPinError(error: Error) {
    show(error: error)
    pinEntryView.resetText()
    let delayTime = DispatchTime.now() + Double(Int64(0.25 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
    DispatchQueue.main.asyncAfter(deadline: delayTime) { [weak self] in
      self?.pinEntryView.focus()
    }
  }

  override func closeTapped() {
    eventHandler.closeTapped()
  }

  func showLoadingSpinner() {
    showLoadingSpinner(tintColor: uiConfiguration.uiPrimaryColor)
  }
}

extension PINVerificationViewController: UIPinEntryTextFieldDelegate {
  func pinEntryTextField(didFinishInput frPinView: UIPinEntryTextField) {
    _ = frPinView.resignFirstResponder()
    eventHandler.submitTapped(frPinView.getText())
  }

  func pinEntryTextField(didDeletePin frPinView: UIPinEntryTextField) {
  }
}

private extension PINVerificationViewController {
  func setUpUI() {
    view.backgroundColor = uiConfiguration.backgroundColor
    edgesForExtendedLayout = UIRectEdge()
    view.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                     action: #selector(PINVerificationViewController.viewTapped)))
    setUpNavigationBar()
    setUpTitleLabel()
    setUpPhoneNumberLabel()
    setUpPinEntryView()
    setUpResendButton()
  }

  private func setUpNavigationBar() {
    navigationController?.navigationBar.setUpWith(uiConfig: uiConfiguration)
    showNavCancelButton(uiConfiguration.iconTertiaryColor)
  }

  private func setUpTitleLabel() {
    titleLabel = ComponentCatalog.formLabelWith(text: "",
                                                textAlignment: .center,
                                                multiline: true,
                                                uiConfig: uiConfiguration)
    view.addSubview(titleLabel)
    titleLabel.snp.makeConstraints { make in
      make.left.right.equalTo(view).inset(48)
      make.top.equalTo(view).offset(72)
    }
  }

  private func setUpPhoneNumberLabel() {
    datapointValueLabel = ComponentCatalog.mainItemRegularLabelWith(text: "",
                                                                 textAlignment: .center,
                                                                 multiline: true,
                                                                 uiConfig: uiConfiguration)
    datapointValueLabel.font = uiConfiguration.formFieldFont
    datapointValueLabel.textColor = uiConfiguration.textSecondaryColor
    view.addSubview(datapointValueLabel)
    datapointValueLabel.snp.makeConstraints { make in
      make.top.equalTo(titleLabel.snp.bottom).offset(8)
      make.left.right.equalTo(view).inset(48)
    }
  }

  private func setUpPinEntryView() {
    pinEntryView = UIPinEntryTextField(size: 6,
                                       frame: CGRect(x: 0, y: 0, width: 252, height: 64),
                                       accessibilityLabel: "PIN Field")
    pinEntryView.delegate = self
    view.addSubview(pinEntryView)
    pinEntryView.snp.makeConstraints { make in
      make.top.equalTo(datapointValueLabel.snp.bottom).offset(52)
      make.centerX.equalTo(view)
      make.left.right.equalToSuperview().inset(48)
      make.height.equalTo(44)
    }
    pinEntryView.resetText()
    pinEntryView.focus()
  }

  private func setUpResendButton() {
    resendButton = ComponentCatalog.formTextLinkButtonWith(
      title: "verify_phone.resend_button.title".podLocalized(),
      uiConfig: uiConfiguration) { [weak self] in
        self?.eventHandler.resendTapped()
    }
    view.addSubview(resendButton)
    resendButton.snp.makeConstraints { make in
      make.top.equalTo(pinEntryView.snp.bottom).offset(130)
      make.left.right.equalTo(view).inset(60)
    }
  }
}
