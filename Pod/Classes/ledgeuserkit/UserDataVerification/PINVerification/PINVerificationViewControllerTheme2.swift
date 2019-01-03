//
// PINVerificationViewControllerTheme2.swift
// ShiftSDK
//
// Created by Takeichi Kanzaki on 08/11/2018.
//

import SnapKit
import Bond
import ReactiveKit

class PINVerificationViewControllerTheme2: PINVerificationViewControllerProtocol {
  private let disposeBag = DisposeBag()
  private unowned let presenter: PINVerificationPresenter
  // swiftlint:disable implicitly_unwrapped_optional
  private var titleLabel: UILabel!
  private var explanationLabel: UILabel!
  private var pinEntryView: UIPinEntryTextField!
  private var resendExplanationLabel: UILabel!
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
    viewModel.title.observeNext { [unowned self] title in
      self.titleLabel.updateAttributedText(title)
    }.dispose(in: disposeBag)
    viewModel.subtitle.observeNext { [unowned self] subtitle in
      self.explanationLabel.updateAttributedText(subtitle)
    }.dispose(in: disposeBag)
    viewModel.resendButtonTitle.ignoreNil().observeNext { [unowned self] resendButtonTitle in
      self.set(resendButtonTitle: resendButtonTitle)
    }.dispose(in: disposeBag)
    viewModel.footerTitle.observeNext { footerTitle in
      self.resendExplanationLabel.updateAttributedText(footerTitle)
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
  }

  override func closeTapped() {
    presenter.closeTapped()
  }
}

extension PINVerificationViewControllerTheme2: UIPinEntryTextFieldDelegate {
  func pinEntryTextField(didFinishInput frPinView: UIPinEntryTextField) {
    _ = frPinView.resignFirstResponder()
    presenter.submitTapped(frPinView.getText())
  }

  func pinEntryTextField(didDeletePin frPinView: UIPinEntryTextField) {
  }
}

private extension PINVerificationViewControllerTheme2 {
  func setUpUI() {
    view.backgroundColor = uiConfiguration.uiBackgroundPrimaryColor
    edgesForExtendedLayout = UIRectEdge()
    view.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                     action: #selector(PINVerificationViewControllerTheme2.viewTapped)))
    setUpNavigationBar()
    setUpTitleLabel()
    setUpExplanationLabel()
    setUpPinEntryView()
    setUpResendExplanationLabel()
    setUpResendButton()
  }

  func setUpNavigationBar() {
    navigationController?.navigationBar.hideShadow()
    navigationController?.navigationBar.setUp(barTintColor: uiConfiguration.uiNavigationPrimaryColor,
                                              tintColor: uiConfiguration.uiSecondaryColor)
    showNavCancelButton(uiConfiguration.uiSecondaryColor, uiTheme: .theme2)
  }

  func setUpTitleLabel() {
    titleLabel = ComponentCatalog.largeTitleLabelWith(text: "", multiline: false, uiConfig: uiConfiguration)
    titleLabel.adjustsFontSizeToFitWidth = true
    view.addSubview(titleLabel)
    titleLabel.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(20)
      make.top.equalToSuperview().offset(16)
    }
  }

  func setUpExplanationLabel() {
    explanationLabel = ComponentCatalog.formLabelWith(text: " ",
                                                      multiline: true,
                                                      lineSpacing: uiConfiguration.lineSpacing,
                                                      letterSpacing: uiConfiguration.letterSpacing,
                                                      uiConfig: uiConfiguration)
    view.addSubview(explanationLabel)
    explanationLabel.snp.makeConstraints { make in
      make.left.right.equalTo(titleLabel)
      make.top.equalTo(titleLabel.snp.bottom).offset(8)
    }
  }

  func setUpPinEntryView() {
    let container = createPinEntryContainer()
    pinEntryView = UIPinEntryTextField(size: 6,
                                       frame: CGRect(x: 0, y: 0, width: 252, height: 64),
                                       accessibilityLabel: "PIN Field")
    pinEntryView.delegate = self
    pinEntryView.showMiddleSeparator = false
    pinEntryView.pinBorderWidth = 0
    pinEntryView.pinBorderColor = .clear
    pinEntryView.font = uiConfiguration.fontProvider.formFieldFont
    pinEntryView.textColor = uiConfiguration.textSecondaryColor
    pinEntryView.invisibleSign = ""
    pinEntryView.placeholder = "-"
    container.addSubview(pinEntryView)
    pinEntryView.snp.makeConstraints { make in
      make.center.equalToSuperview()
      make.left.right.equalToSuperview().inset(48)
      make.height.equalTo(44)
    }
    pinEntryView.resetText()
    pinEntryView.focus()
  }

  func createPinEntryContainer() -> UIView {
    let containerView = UIView()
    containerView.backgroundColor = .white
    containerView.layer.cornerRadius = uiConfiguration.buttonCornerRadius
    containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
    containerView.layer.shadowColor = UIColor(red:0, green:0, blue:0, alpha:0.12).cgColor
    containerView.layer.shadowOpacity = 1
    containerView.layer.shadowRadius = 4
    view.addSubview(containerView)
    containerView.snp.makeConstraints { make in
      make.top.equalTo(explanationLabel.snp.bottom).offset(48)
      make.left.right.equalTo(titleLabel)
      make.height.equalTo(uiConfiguration.formRowHeight)
    }

    return containerView
  }

  func setUpResendExplanationLabel() {
    resendExplanationLabel = ComponentCatalog.instructionsLabelWith(text: "auth.verify_phone.footer".podLocalized(),
                                                                    textAlignment: .left,
                                                                    uiConfig: uiConfiguration)
    view.addSubview(resendExplanationLabel)
    resendExplanationLabel.snp.makeConstraints { make in
      make.left.right.equalTo(titleLabel)
      make.top.equalTo(pinEntryView.snp.bottom).offset(resendTopDistance)
    }
  }

  func setUpResendButton() {
    resendButton = ComponentCatalog.formTextLinkButtonWith(
      title: "verify_phone.resend_button.title".podLocalized(),
      uiConfig: uiConfiguration) { [weak self] in
      self?.presenter.resendTapped()
    }
    view.addSubview(resendButton)
    resendButton.snp.removeConstraints()
    resendButton.snp.makeConstraints { make in
      make.top.equalTo(resendExplanationLabel.snp.bottom)
      make.left.equalTo(titleLabel)
    }
  }

  var resendTopDistance: CGFloat {
    switch UIDevice.deviceType() {
    case .iPhone5:
      return 48
    default:
      return 68
    }
  }
}
