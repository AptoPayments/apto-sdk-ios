//
//  FullScreenDisclaimerViewControllerTheme1.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 17/02/16.
//
//

import UIKit
import TTTAttributedLabel
import Bond
import ReactiveKit
import SnapKit

final class FullScreenDisclaimerViewControllerTheme1: ShiftViewController {
  private let disposeBag = DisposeBag()
  fileprivate unowned let eventHandler: FullScreenDisclaimerEventHandler
  fileprivate let contentPresenterView: ContentPresenterView
  fileprivate let navigationView = UIView()
  fileprivate var agreeButton: UIButton! // swiftlint:disable:this implicitly_unwrapped_optional

  init(uiConfiguration: ShiftUIConfig, eventHandler: FullScreenDisclaimerEventHandler) {
    self.eventHandler = eventHandler
    self.contentPresenterView = ContentPresenterView(uiConfig: uiConfiguration)
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

    viewModel.disclaimer.ignoreNil().observeNext { disclaimer in
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

extension FullScreenDisclaimerViewControllerTheme1: ContentPresenterViewDelegate {
  func linkTapped(url: URL) {
    eventHandler.linkTapped(url)
  }
}

private extension FullScreenDisclaimerViewControllerTheme1 {
  func setUpUI() {
    view.backgroundColor = uiConfiguration.uiBackgroundPrimaryColor
    edgesForExtendedLayout = UIRectEdge()
    extendedLayoutIncludesOpaqueBars = true

    setUpNavigationBar()
    // Bottom Bar Buttons
    setUpNavigationView()
    setUpAgreeButton()
    setUpCancelButton()
    setUpContentPresenterView()
  }

  func setUpNavigationBar() {
    title = "disclaimer.disclaimer.title".podLocalized()
    navigationController?.navigationBar.setUpWith(uiConfig: uiConfiguration)
    hideNavCancelButton()
  }

  func setUpNavigationView() {
    view.addSubview(navigationView)
    navigationView.snp.makeConstraints { make in
      make.left.right.bottom.equalTo(self.view)
    }
  }

  func setUpAgreeButton() {
    agreeButton = ComponentCatalog.buttonWith(title: "disclaimer.disclaimer.call_to_action.title".podLocalized(),
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
    contentPresenterView.font = uiConfiguration.fontProvider.formListFont
    contentPresenterView.lineSpacing = 4
    view.addSubview(contentPresenterView)
    contentPresenterView.delegate = self
    contentPresenterView.snp.makeConstraints { make in
      make.left.top.right.equalToSuperview()
      make.bottom.lessThanOrEqualTo(navigationView.snp.top)
    }
  }
}
