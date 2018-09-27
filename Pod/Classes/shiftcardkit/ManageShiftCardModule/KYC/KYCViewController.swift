//
//  KYCViewController.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 09/04/2017.
//
//

import UIKit
import Stripe
import Bond
import ReactiveKit
import SnapKit
import PullToRefreshKit

protocol KYCEventHandler: class {
  var viewModel: KYCViewModel { get }
  func viewLoaded()
  func previousTapped()
  func closeTapped()
  func refreshTapped()
}

class KYCViewController: ShiftViewController, KYCViewProtocol {
  private unowned let eventHandler: KYCEventHandler
  private var statusLabel: UILabel! // swiftlint:disable:this implicitly_unwrapped_optional

  init(uiConfiguration: ShiftUIConfig, eventHandler: KYCEventHandler) {
    self.eventHandler = eventHandler
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

  func setupViewModelSubscriptions() {
    let viewModel = eventHandler.viewModel

    _ = viewModel.kycState.observeNext { kycState in
      self.statusLabel.text = self.kycStateDescription(kyc: kycState)
    }
  }

  override func closeTapped() {
    eventHandler.closeTapped()
  }

  override func previousTapped() {
    eventHandler.previousTapped()
  }

  fileprivate func kycStateDescription(kyc: KYCState?) -> String? {
    guard let kyc = kyc else {
      return nil
    }
    switch kyc {
    case .resubmitDetails:
      return "kyc.state.resubmitDetails".podLocalized()
    case .uploadFile:
      return "kyc.state.uploadFile".podLocalized()
    case .underReview:
      return "kyc.state.underReview".podLocalized()
    case .passed:
      return "kyc.state.passed".podLocalized()
    case .rejected:
      return "kyc.state.rejected".podLocalized()
    case .temporaryError:
      return "kyc.state.temporaryError".podLocalized()
    }
  }
}

private extension KYCViewController {
  func setUpUI() {
    view.backgroundColor = uiConfiguration.backgroundColor
    setUpNavigationBar()
    let containerView = createContainerView()
    let icon = createIconView(containerView: containerView)
    setUpStatusLabel(containerView: containerView, icon: icon)
    createRefreshButton()
  }

  func setUpNavigationBar() {
    navigationController?.navigationBar.setUpWith(uiConfig: uiConfiguration)
    edgesForExtendedLayout = UIRectEdge()
    extendedLayoutIncludesOpaqueBars = true
    self.title = "kyc.title".podLocalized()
  }

  func createContainerView() -> UIView {
    let containerview = UIView()
    view.addSubview(containerview)
    containerview.snp.makeConstraints { make in
      make.left.right.equalTo(view).inset(20)
      make.centerY.equalTo(view).offset(-32)
    }
    return containerview
  }

  func createIconView(containerView: UIView) -> UIImageView {
    let icon = UIImageView(image: UIImage.imageFromPodBundle("CloudQueue"))
    containerView.addSubview(icon)
    icon.snp.makeConstraints { make in
      make.centerX.equalTo(containerView)
      make.top.equalTo(containerView)
      make.width.height.equalTo(100)
    }
    return icon
  }

  func setUpStatusLabel(containerView: UIView, icon: UIImageView) {
    statusLabel = ComponentCatalog.mainItemRegularLabelWith(text: "",
                                                            textAlignment: .center,
                                                            uiConfig: uiConfiguration)
    containerView.addSubview(statusLabel)
    statusLabel.snp.makeConstraints { make in
      make.top.equalTo(icon.snp.bottom).offset(40)
      make.left.right.bottom.equalTo(containerView)
    }
  }

  func createRefreshButton() {
    let refreshButton = ComponentCatalog.buttonWith(title: "kyc.refresh_button.title".podLocalized(),
                                                    uiConfig: self.uiConfiguration) {
                                                      self.eventHandler.refreshTapped()
    }
    view.addSubview(refreshButton)
    refreshButton.snp.makeConstraints { make in
      make.left.right.bottom.equalTo(view).inset(40)
    }
  }
}
