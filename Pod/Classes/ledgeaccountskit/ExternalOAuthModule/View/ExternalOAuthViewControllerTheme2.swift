//
// ExternalOAuthViewControllerTheme2.swift
// ShiftSDK
//
// Created by Takeichi Kanzaki on 12/11/2018.
//

import SnapKit
import Bond
import ReactiveKit

class ExternalOAuthViewControllerTheme2: ShiftViewController {
  private let disposeBag = DisposeBag()
  private unowned let presenter: ExternalOAuthPresenterProtocol
  // swiftlint:disable implicitly_unwrapped_optional
  private var titleLabel: UILabel!
  private var explanationLabel: UILabel!
  private var actionButton: UIButton!
  // swiftlint:enable implicitly_unwrapped_optional
  private var allowedBalanceTypes = [AllowedBalanceType]()

  init(uiConfiguration: ShiftUIConfig, eventHandler: ExternalOAuthPresenterProtocol) {
    self.presenter = eventHandler
    super.init(uiConfiguration: uiConfiguration)
    let callToActionTitle = "select_balance_store.login.call_to_action.title".podLocalized()
    self.actionButton = ComponentCatalog.buttonWith(title: callToActionTitle,
                                                    showShadow: false,
                                                    uiConfig: uiConfiguration) { [unowned self] in
      self.custodianSelected(type: .coinbase)
    }
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

  override func previousTapped() {
    presenter.backTapped()
  }

  private func custodianSelected(type: CustodianType) {
    if let balanceType = allowedBalanceTypes.first(where: { $0.type == type }) {
      presenter.balanceTypeTapped(balanceType)
    }
    else {
      showMessage("external-oauth.wrong-type.error".podLocalized())
    }
  }
}

// MARK: - Set viewModel subscriptions
private extension ExternalOAuthViewControllerTheme2 {
  func setupViewModelSubscriptions() {
    let viewModel = presenter.viewModel

    viewModel.title.ignoreNil().observeNext { [unowned self] title in
      self.titleLabel.updateAttributedText(title)
    }.dispose(in: disposeBag)

    viewModel.allowedBalanceTypes.ignoreNil().observeNext { [unowned self] allowedBalanceTypes in
      self.allowedBalanceTypes = allowedBalanceTypes
    }.dispose(in: disposeBag)

    viewModel.error.ignoreNil().observeNext { [unowned self] error in
      self.show(error: error)
    }.dispose(in: disposeBag)
  }
}

// MARK: - Set up UI
private extension ExternalOAuthViewControllerTheme2 {
  func setUpUI() {
    view.backgroundColor = uiConfiguration.uiBackgroundPrimaryColor
    setUpNavigationBar()
    setUpTitleLabel()
    setUpExplanationLabel()
    setUpActionButton()
  }

  func setUpNavigationBar() {
    navigationController?.navigationBar.hideShadow()
    navigationController?.navigationBar.setUp(barTintColor: uiConfiguration.uiNavigationPrimaryColor,
                                              tintColor: uiConfiguration.uiSecondaryColor)
    showNavPreviousButton(uiConfiguration.uiSecondaryColor, uiTheme: .theme2)
  }

  func setUpTitleLabel() {
    titleLabel = ComponentCatalog.largeTitleLabelWith(text: " ", multiline: true, uiConfig: uiConfiguration)
    view.addSubview(titleLabel)
    titleLabel.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(20)
      make.top.equalToSuperview().offset(16)
    }
  }

  func setUpExplanationLabel() {
    explanationLabel = ComponentCatalog.formLabelWith(text: "select_balance_store.login.explanation".podLocalized(),
                                                      multiline: true,
                                                      lineSpacing: uiConfiguration.lineSpacing,
                                                      letterSpacing: uiConfiguration.letterSpacing,
                                                      uiConfig: uiConfiguration)
    view.addSubview(explanationLabel)
    explanationLabel.snp.makeConstraints { make in
      make.left.right.equalTo(titleLabel)
      make.top.equalTo(titleLabel.snp.bottom).offset(16)
    }
  }

  func setUpActionButton() {
    view.addSubview(actionButton)
    actionButton.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(24)
      make.bottom.equalToSuperview().inset(54)
    }
  }
}
