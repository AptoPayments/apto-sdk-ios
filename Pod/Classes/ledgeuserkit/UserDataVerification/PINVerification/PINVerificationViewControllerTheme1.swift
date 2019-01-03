//
//  PINVerificationViewControllerTheme1.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 28/09/2016.
//
//

import UIKit
import Bond
import ReactiveKit
import SnapKit

class PINVerificationViewControllerTheme1: PINVerificationViewControllerProtocol {
  private let disposeBag = DisposeBag()
  private unowned let presenter: PINVerificationPresenter
  // swiftlint:disable implicitly_unwrapped_optional
  private var titleLabel: UILabel!
  private var datapointValueLabel: UILabel!
  private var pinEntryView: UIPinEntryTextField!
  private var resendButton: UIButton!
  // swiftlint:enable implicitly_unwrapped_optional

  init(uiConfig: ShiftUIConfig, presenter: PINVerificationPresenter) {
    self.presenter = presenter
    super.init(uiConfiguration: uiConfig)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    setUpUI()
    setupViewModelSubscriptions()
    presenter.viewLoaded()
  }

  private func setupViewModelSubscriptions() {
    let viewModel = presenter.viewModel
    viewModel.datapointValue.observeNext { phoneNumber in
      self.datapointValueLabel.text = phoneNumber
    }.dispose(in: disposeBag)
    viewModel.title.observeNext { title in
      self.title = title
    }.dispose(in: disposeBag)
    viewModel.subtitle.observeNext { subtitle in
      self.titleLabel.text = subtitle
    }.dispose(in: disposeBag)
    viewModel.resendButtonTitle.ignoreNil().observeNext { resendButtonTitle in
      self.set(resendButtonTitle: resendButtonTitle)
    }.dispose(in: disposeBag)
  }

  private func set(resendButtonTitle: String) {
    resendButton.updateAttributedTitle(resendButtonTitle, for: .normal)
  }

  @objc func viewTapped() {
    _ = pinEntryView.resignFirstResponder()
  }

  func showWrongPinError(error: Error) {
    show(error: error)
    pinEntryView.resetText()
  }

  override func closeTapped() {
    presenter.closeTapped()
  }
}

extension PINVerificationViewControllerTheme1: UIPinEntryTextFieldDelegate {
  func pinEntryTextField(didFinishInput frPinView: UIPinEntryTextField) {
    _ = frPinView.resignFirstResponder()
    presenter.submitTapped(frPinView.getText())
  }

  func pinEntryTextField(didDeletePin frPinView: UIPinEntryTextField) {
  }
}

private extension PINVerificationViewControllerTheme1 {
  func setUpUI() {
    view.backgroundColor = uiConfiguration.uiBackgroundPrimaryColor
    edgesForExtendedLayout = UIRectEdge()
    view.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                     action: #selector(PINVerificationViewControllerTheme1.viewTapped)))
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
    datapointValueLabel.font = uiConfiguration.fontProvider.formFieldFont
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
        self?.presenter.resendTapped()
    }
    view.addSubview(resendButton)
    resendButton.snp.makeConstraints { make in
      make.top.equalTo(pinEntryView.snp.bottom).offset(130)
      make.left.right.equalTo(view).inset(60)
    }
  }
}
