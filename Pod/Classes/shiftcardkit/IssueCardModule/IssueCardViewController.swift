//
//  IssueCardViewController.swift
//  Pods
//
//  Created by Takeichi Kanzaki on 29/06/2018.
//
//

import UIKit
import Bond
import SnapKit

class IssueCardViewController: ShiftViewController {
  private let eventHandler: IssueCardPresenterProtocol

  private let errorViewContainer = UIView()
  private var errorTitleLabel: UILabel! // swiftlint:disable:this implicitly_unwrapped_optional
  private var errorMessageLabel: UILabel! // swiftlint:disable:this implicitly_unwrapped_optional

  private var currentState: IssueCardViewState?

  init(uiConfiguration: ShiftUIConfig, eventHandler: IssueCardPresenterProtocol) {
    self.eventHandler = eventHandler
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

  private func setupViewModelSubscriptions() {
    let viewModel = eventHandler.viewModel

    _ = viewModel.state.observeNext { state in
      self.updateUIForState(state)
    }
  }

  private func updateUIForState(_ state: IssueCardViewState) {
    guard currentState != state else {
      return
    }
    currentState = state
    switch state {
    case .loading:
      showLoadingSpinner(tintColor: uiConfiguration.uiPrimaryColor, position: .bottomCenter)
      errorViewContainer.isHidden = true
    case .error:
      errorViewContainer.isHidden = false
      hideLoadingSpinner()
    }
  }

  @objc private func retry() {
    eventHandler.retryTapped()
  }
}

// MARK: - setup UI
private extension IssueCardViewController {
  func setUpUI() {
    view.backgroundColor = uiConfiguration.backgroundColor
    title = "issue-card.navigationBar.title".podLocalized()
    hideNavPreviousButton()
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
      make.height.equalTo(50)
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
}
