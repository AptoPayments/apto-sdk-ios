//
// FullScreenDisclaimerViewControllerTheme2.swift
// ShiftSDK
//
// Created by Takeichi Kanzaki on 15/11/2018.
//

import UIKit
import TTTAttributedLabel
import Bond
import ReactiveKit
import SnapKit

class FullScreenDisclaimerViewControllerTheme2: ShiftViewController {
  private let disposeBag = DisposeBag()
  private unowned let eventHandler: FullScreenDisclaimerEventHandler
  private let titleLabel: UILabel
  private let contentPresenterView: ContentPresenterView
  private let navigationView = UIView()
  private var agreeButton: UIButton! // swiftlint:disable:this implicitly_unwrapped_optional

  init(uiConfiguration: ShiftUIConfig, eventHandler: FullScreenDisclaimerEventHandler) {
    self.eventHandler = eventHandler
    self.contentPresenterView = ContentPresenterView(uiConfig: uiConfiguration)
    self.titleLabel = ComponentCatalog.largeTitleLabelWith(text: "disclaimer.disclaimer.title".podLocalized(),
                                                           uiConfig: uiConfiguration)
    super.init(uiConfiguration: uiConfiguration)
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

  // Setup viewModel subscriptions
  private func setupViewModelSubscriptions() {
    let viewModel = eventHandler.viewModel

    viewModel.disclaimer.ignoreNil().observeNext { [unowned self] disclaimer in
      self.set(disclaimer: disclaimer)
    }.dispose(in: disposeBag)
  }

  final private func set(disclaimer: Content) {
    contentPresenterView.set(content: disclaimer)
  }

  override func closeTapped() {
    eventHandler.closeTapped()
  }

  func agreeTapped() {
    eventHandler.agreeTapped()
  }
}

extension FullScreenDisclaimerViewControllerTheme2: ContentPresenterViewDelegate {
  func linkTapped(url: URL) {
    eventHandler.linkTapped(url)
  }
}

private extension FullScreenDisclaimerViewControllerTheme2 {
  func setUpUI() {
    view.backgroundColor = uiConfiguration.uiBackgroundPrimaryColor
    extendedLayoutIncludesOpaqueBars = true
    automaticallyAdjustsScrollViewInsets = true
    edgesForExtendedLayout = .top

    setUpNavigationBar()
    setUpTitleLabel()
    // Bottom Bar Buttons
    setUpNavigationView()
    setUpAgreeButton()
    setUpCancelButton()
    setUpContentPresenterView()
  }

  func setUpNavigationBar() {
    navigationController?.isNavigationBarHidden = true
  }

  func setUpTitleLabel() {
    titleLabel.adjustsFontSizeToFitWidth = true
    view.addSubview(titleLabel)
    titleLabel.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(20)
      make.top.equalTo(topConstraint).offset(16)
      make.height.equalTo(62)
    }
  }

  func setUpNavigationView() {
    navigationView.backgroundColor = view.backgroundColor
    view.addSubview(navigationView)
    navigationView.snp.makeConstraints { make in
      make.left.right.bottom.equalToSuperview()
    }
  }

  func setUpAgreeButton() {
    agreeButton = ComponentCatalog.buttonWith(title: "disclaimer.disclaimer.call_to_action.title".podLocalized(),
                                              showShadow: false,
                                              uiConfig: uiConfiguration) { [unowned self] in
      self.agreeTapped()
    }
    navigationView.addSubview(agreeButton)
    agreeButton.snp.makeConstraints { make in
      make.left.top.right.equalTo(navigationView).inset(20)
    }
  }

  func setUpCancelButton() {
    let title = "disclaimer.disclaimer.cancel_action.button".podLocalized()
    let button = ComponentCatalog.formTextLinkButtonWith(title: title,
                                                         uiConfig: uiConfiguration) { [unowned self] in
      self.closeTapped()
    }
    navigationView.addSubview(button)
    button.snp.makeConstraints { make in
      make.top.equalTo(agreeButton.snp.bottom).offset(4)
      make.left.right.equalTo(agreeButton)
      make.bottom.equalTo(bottomConstraint).inset(12)
    }
  }

  func setUpContentPresenterView() {
    contentPresenterView.font = uiConfiguration.fontProvider.mainItemLightFont
    contentPresenterView.lineSpacing = 4
    view.addSubview(contentPresenterView)
    contentPresenterView.delegate = self
    contentPresenterView.snp.makeConstraints { make in
      make.top.equalTo(titleLabel.snp.bottom).offset(16)
      make.left.right.equalToSuperview()
      make.bottom.equalTo(navigationView.snp.top)
    }
  }
}
