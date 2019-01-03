//
// IssueCardViewControllerTheme2.swift
// ShiftSDK
//
// Created by Takeichi Kanzaki on 19/11/2018.
//

import UIKit
import Bond
import ReactiveKit
import SnapKit

class IssueCardViewControllerTheme2: ShiftViewController {
  private let disposeBag = DisposeBag()
  private let presenter: IssueCardPresenterProtocol

  private let errorViewContainer = UIView()
  private let errorImageView = UIImageView(image: UIImage.imageFromPodBundle("error_backend", uiTheme: .theme2))
  private var errorMessageLabel: UILabel! // swiftlint:disable:this implicitly_unwrapped_optional
  private let legalNoticeViewContainer = UIView()
  private let legalNoticeActionsView = UIView()
  private let legalNoticeView: ContentPresenterView

  private var currentState: IssueCardViewState?

  init(uiConfiguration: ShiftUIConfig, presenter: IssueCardPresenterProtocol) {
    self.presenter = presenter
    self.legalNoticeView = ContentPresenterView(uiConfig: uiConfiguration)
    super.init(uiConfiguration: uiConfiguration)
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

  private func setupViewModelSubscriptions() {
    let viewModel = presenter.viewModel

    viewModel.state.observeNext { state in
      self.updateUIForState(state)
    }.dispose(in: disposeBag)
  }

  private func updateUIForState(_ state: IssueCardViewState) {
    guard currentState != state else {
      return
    }
    currentState = state
    switch state {
    case .loading:
      showLoadingState()
      showLoadingView()
      hideErrorState()
      hideLegalNotice()
    case .error:
      hideLoadingView()
      hideLegalNotice()
      showErrorState()
    case .done:
      hideLoadingView()
    case .showLegalNotice(let content):
      hideLoadingView()
      hideErrorState()
      showLegalNotice(content)
    }
  }

  @objc private func retry() {
    presenter.retryTapped()
  }
}

// MARK: - setup UI
private extension IssueCardViewControllerTheme2 {
  func setUpUI() {
    updateBackgroundColor(uiConfiguration.uiBackgroundPrimaryColor)
    hideNavCancelButton()
    setUpErrorView()
    setUpLegalNoticeView()
  }

  func setUpErrorView() {
    setUpErrorViewContainer()
    setUpErrorImageView()
    setUpErrorMessageLabel()
    setUpRetryButton()
  }

  func setUpErrorViewContainer() {
    errorViewContainer.backgroundColor = uiConfiguration.uiSecondaryColor
    view.addSubview(errorViewContainer)
    errorViewContainer.snp.makeConstraints { make in
      make.top.left.right.bottom.equalToSuperview()
    }
  }

  func setUpErrorImageView() {
    let topView = UIView()
    topView.backgroundColor = errorViewContainer.backgroundColor
    errorViewContainer.addSubview(topView)
    topView.snp.makeConstraints { make in
      make.left.top.right.equalToSuperview()
      make.height.equalToSuperview().dividedBy(4.0)
    }
    errorViewContainer.addSubview(errorImageView)
    errorImageView.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalTo(topView.snp.bottom)
    }
  }

  func setUpErrorMessageLabel() {
    errorMessageLabel = ComponentCatalog.mainItemRegularLabelWith(text: "issue-card.error.message".podLocalized(),
                                                                  textAlignment: .center,
                                                                  multiline: true,
                                                                  uiConfig: uiConfiguration)
    errorMessageLabel.textColor = uiConfiguration.textMessageColor
    errorViewContainer.addSubview(errorMessageLabel)
    errorMessageLabel.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(26)
      make.top.equalTo(errorImageView.snp.bottom).offset(34)
    }
  }

  func setUpRetryButton() {
    let button = ComponentCatalog.buttonWith(title: "issue-card.action.retry".podLocalized(),
                                             showShadow: false,
                                             uiConfig: uiConfiguration) { [unowned self] in
      self.retry()
    }
    errorViewContainer.addSubview(button)
    button.snp.makeConstraints { make in
      make.bottom.equalToSuperview().inset(54)
      make.left.right.equalToSuperview().inset(20)
    }
  }

  func setUpLegalNoticeView() {
    setUpLegalNoticeContainerView()
    setUpLegalNoticeActionsView()
    setUpLegalNoticeContentView()
  }

  func setUpLegalNoticeContainerView() {
    view.addSubview(legalNoticeViewContainer)
    legalNoticeViewContainer.snp.makeConstraints { make in
      make.edges.equalTo(edgesConstraint)
    }
  }

  func setUpLegalNoticeActionsView() {
    let button = ComponentCatalog.buttonWith(title: "issue_card.issue_card.call_to_action.title".podLocalized(),
                                             showShadow: false,
                                             uiConfig: uiConfiguration) { [unowned self] in
      self.presenter.requestCardTapped()
    }
    legalNoticeActionsView.addSubview(button)
    button.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(44)
      make.top.equalToSuperview().offset(10)
      make.bottom.equalToSuperview().inset(24)
    }
    legalNoticeViewContainer.addSubview(legalNoticeActionsView)
    legalNoticeActionsView.snp.makeConstraints { make in
      make.left.bottom.right.equalToSuperview()
    }
  }

  func setUpLegalNoticeContentView() {
    let titleLabel = ComponentCatalog.largeTitleLabelWith(text: "issue_card.issue_card.title".podLocalized(),
                                                          multiline: false,
                                                          uiConfig: uiConfiguration)
    titleLabel.adjustsFontSizeToFitWidth = true
    legalNoticeViewContainer.addSubview(titleLabel)
    titleLabel.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(20)
      make.top.equalToSuperview().offset(16)
    }
    legalNoticeView.font = uiConfiguration.fontProvider.mainItemLightFont
    legalNoticeView.lineSpacing = 4
    legalNoticeViewContainer.addSubview(legalNoticeView)
    legalNoticeView.delegate = self
    legalNoticeView.snp.makeConstraints { make in
      make.top.equalTo(titleLabel.snp.bottom).offset(6)
      make.left.right.equalToSuperview()
      make.bottom.greaterThanOrEqualTo(legalNoticeViewContainer.snp.top)
    }
  }

  func showLoadingState() {
    hideErrorState()
    updateBackgroundColor(uiConfiguration.uiBackgroundPrimaryColor)
    setNeedsStatusBarAppearanceUpdate()
  }

  func showErrorState() {
    errorViewContainer.isHidden = false
    updateBackgroundColor(uiConfiguration.uiSecondaryColor)
    setNeedsStatusBarAppearanceUpdate()
  }

  func hideErrorState() {
    errorViewContainer.isHidden = true
  }

  func showLegalNotice(_ content: Content) {
    updateBackgroundColor(uiConfiguration.uiBackgroundPrimaryColor)
    legalNoticeView.set(content: content)
    legalNoticeViewContainer.isHidden = false
  }

  func hideLegalNotice() {
    legalNoticeViewContainer.isHidden = true
  }

  func updateBackgroundColor(_ color: UIColor) {
    view.backgroundColor = color
    navigationController?.navigationBar.setUp(barTintColor: color, tintColor: color)
  }
}

extension IssueCardViewControllerTheme2: ContentPresenterViewDelegate {
  func linkTapped(url: URL) {
    presenter.show(url: url)
  }
}

