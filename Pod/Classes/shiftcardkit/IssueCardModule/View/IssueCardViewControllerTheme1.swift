//
//  IssueCardViewControllerTheme1.swift
//  ShiftSDK
//
//  Created by Takeichi Kanzaki on 29/06/2018.
//
//

import UIKit
import Bond
import ReactiveKit
import SnapKit

class IssueCardViewControllerTheme1: ShiftViewController {
  private let disposeBag = DisposeBag()
  private let eventHandler: IssueCardPresenterProtocol
  private let errorViewContainer = UIView()
  private let legalNoticeViewContainer = UIView()
  private let legalNoticeActionsView = UIView()
  private let legalNoticeView: ContentPresenterView
  private var errorTitleLabel: UILabel! // swiftlint:disable:this implicitly_unwrapped_optional
  private var errorMessageLabel: UILabel! // swiftlint:disable:this implicitly_unwrapped_optional

  private var currentState: IssueCardViewState?

  init(uiConfiguration: ShiftUIConfig, eventHandler: IssueCardPresenterProtocol) {
    self.eventHandler = eventHandler
    self.legalNoticeView = ContentPresenterView(uiConfig: uiConfiguration)
    super.init(uiConfiguration: uiConfiguration)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    setUpUI()

    // Subscribe to viewModel changes
    setupViewModelSubscriptions()

    eventHandler.viewLoaded()
  }

  override func previousTapped() {
    eventHandler.backTapped()
  }

  private func setupViewModelSubscriptions() {
    let viewModel = eventHandler.viewModel

    viewModel.state.observeNext { [unowned self] state in
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
      showLoadingView()
      errorViewContainer.isHidden = true
      legalNoticeViewContainer.isHidden = true
    case .error:
      errorViewContainer.isHidden = false
      legalNoticeViewContainer.isHidden = true
      hideLoadingView()
    case .done:
      hideLoadingView()
    case .showLegalNotice(let content):
      errorViewContainer.isHidden = true
      hideLoadingView()
      legalNoticeView.set(content: content)
      legalNoticeViewContainer.isHidden = false
    }
  }

  @objc private func retry() {
    eventHandler.retryTapped()
  }
}

// MARK: - setup UI
private extension IssueCardViewControllerTheme1 {
  func setUpUI() {
    view.backgroundColor = uiConfiguration.uiBackgroundPrimaryColor
    title = "issue_card.issue_card.title".podLocalized()
    navigationController?.navigationBar.setUpWith(uiConfig: uiConfiguration)
    hideNavCancelButton()
    setUpErrorView()
    setUpLegalNoticeView()
  }

  func setUpErrorView() {
    setUpErrorViewContainer()
    setUpErrorMessageLabel()
    setUpErrorTitleLabel()
    setUpRetryButton()
    setUpErrorImageView()
  }

  func setUpErrorViewContainer() {
    errorViewContainer.backgroundColor = view.backgroundColor
    view.addSubview(errorViewContainer)
    errorViewContainer.snp.makeConstraints { make in
      make.top.left.right.bottom.equalToSuperview()
    }
  }

  func setUpErrorMessageLabel() {
    errorMessageLabel = ComponentCatalog.errorMessageLabel(text: "issue-card.error.message".podLocalized(),
                                                           uiConfig: uiConfiguration)
    errorViewContainer.addSubview(errorMessageLabel)
    errorMessageLabel.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(16)
      make.right.equalToSuperview().offset(-16)
      make.center.equalToSuperview()
    }
  }

  private func setUpErrorTitleLabel() {
    errorTitleLabel = ComponentCatalog.errorTitleLabel(text: "issue-card.error.title".podLocalized(),
                                                       uiConfig: uiConfiguration)
    errorViewContainer.addSubview(errorTitleLabel)
    errorTitleLabel.snp.makeConstraints { make in
      make.width.equalToSuperview()
      make.bottom.equalTo(errorMessageLabel.snp.top).offset(-16)
    }
  }

  private func setUpRetryButton() {
    let button = ComponentCatalog.buttonWith(title: "issue-card.action.retry".podLocalized(),
                                             uiConfig: uiConfiguration) { [unowned self] in
      self.retry()
    }
    errorViewContainer.addSubview(button)
    button.snp.makeConstraints { make in
      make.top.equalTo(errorMessageLabel.snp.bottom).offset(24)
      make.leading.equalToSuperview().offset(44)
      make.trailing.equalToSuperview().offset(-44)
    }
  }

  private func setUpErrorImageView() {
    let image = UIImage.imageFromPodBundle("error_backend.png")
    let imageView = UIImageView(image: image?.asTemplate())
    errorViewContainer.addSubview(imageView)
    imageView.tintColor = uiConfiguration.uiPrimaryColor
    imageView.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.bottom.equalTo(errorTitleLabel.snp.top).offset(-50)
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
                                             uiConfig: uiConfiguration) { [unowned self] in
      self.eventHandler.requestCardTapped()
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
    legalNoticeView.font = uiConfiguration.fontProvider.formListFont
    legalNoticeView.lineSpacing = 4
    legalNoticeViewContainer.addSubview(legalNoticeView)
    legalNoticeView.delegate = self
    legalNoticeView.snp.makeConstraints { make in
      make.left.top.right.equalToSuperview()
      make.bottom.greaterThanOrEqualTo(legalNoticeViewContainer.snp.top)
    }
  }
}

extension IssueCardViewControllerTheme1: ContentPresenterViewDelegate {
  func linkTapped(url: URL) {
    eventHandler.show(url: url)
  }
}
