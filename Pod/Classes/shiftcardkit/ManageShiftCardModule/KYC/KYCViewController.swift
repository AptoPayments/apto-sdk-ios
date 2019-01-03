//
//  KYCViewController.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 09/04/2017.
//
//

import UIKit
import Bond
import ReactiveKit
import SnapKit

class KYCViewController: KYCViewControllerProtocol {
  private let disposeBag = DisposeBag()
  private unowned let presenter: KYCPresenterProtocol
  private let statusLabel: UILabel
  private let footerLabel: ContentPresenterView
  private let imageView = UIImageView()

  init(uiConfiguration: ShiftUIConfig, presenter: KYCPresenterProtocol) {
    self.presenter = presenter
    self.statusLabel = ComponentCatalog.boldMessageLabelWith(text: "",
                                                             textAlignment: .center,
                                                             uiConfig: uiConfiguration)
    self.footerLabel = ContentPresenterView(uiConfig: uiConfiguration)
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

  func setupViewModelSubscriptions() {
    let viewModel = presenter.viewModel

    viewModel.kycState.observeNext { [unowned self] kycState in
      self.statusLabel.text = self.kycStateDescription(kyc: kycState)
      self.imageView.image = self.image(forState: kycState)
    }.dispose(in: disposeBag)
  }

  override func closeTapped() {
    presenter.closeTapped()
  }

  override func previousTapped() {
    presenter.previousTapped()
  }

  private func kycStateDescription(kyc: KYCState?) -> String? {
    guard let kyc = kyc else {
      return nil
    }
    switch kyc {
    case .resubmitDetails:
      return "manage_card.kyc.state.resubmit_details".podLocalized()
    case .uploadFile:
      return "manage_card.kyc.state.upload_file".podLocalized()
    case .underReview:
      return "manage_card.kyc.state.under_review".podLocalized()
    case .passed:
      return "manage_card.kyc.state.passed".podLocalized()
    case .rejected:
      return "manage_card.kyc.state.rejected".podLocalized()
    case .temporaryError:
      return "manage_card.kyc.state.temporary_error".podLocalized()
    }
  }

  private func image(forState kyc: KYCState?) -> UIImage? {
    guard let kyc = kyc else { return nil }
    let imageName: String
    switch kyc {
    case .rejected:
      imageName = "kyc_failure"
    default:
      imageName = "kyc_reviewing"
    }
    return UIImage.imageFromPodBundle(imageName)?.asTemplate()
  }
}

private extension KYCViewController {
  func setUpUI() {
    view.backgroundColor = uiConfiguration.uiBackgroundPrimaryColor
    setUpNavigationBar()
    let containerView = createContainerView()
    let icon = createIconView(containerView: containerView)
    setUpStatusLabel(containerView: containerView, icon: icon)
    setUpFooterLabel()
    createRefreshButton()
  }

  func setUpNavigationBar() {
    navigationController?.navigationBar.setUpWith(uiConfig: uiConfiguration)
    edgesForExtendedLayout = UIRectEdge()
    extendedLayoutIncludesOpaqueBars = true
    self.title = "manage_card.kyc.title".podLocalized()
  }

  func createContainerView() -> UIView {
    let containerView = UIView()
    view.addSubview(containerView)
    containerView.snp.makeConstraints { make in
      make.left.right.equalTo(view).inset(20)
      make.centerY.equalTo(view).offset(-72)
    }
    return containerView
  }

  func createIconView(containerView: UIView) -> UIImageView {
    imageView.tintColor = uiConfiguration.iconSecondaryColor
    imageView.image = UIImage.imageFromPodBundle("kyc_reviewing")?.asTemplate()
    containerView.addSubview(imageView)
    imageView.snp.makeConstraints { make in
      make.centerX.equalTo(containerView)
      make.top.equalTo(containerView)
    }
    return imageView
  }

  func setUpStatusLabel(containerView: UIView, icon: UIImageView) {
    statusLabel.textColor = uiConfiguration.iconSecondaryColor
    containerView.addSubview(statusLabel)
    statusLabel.snp.makeConstraints { make in
      make.top.equalTo(icon.snp.bottom).offset(12)
      make.left.right.bottom.equalTo(containerView)
    }
  }

  func setUpFooterLabel() {
    view.addSubview(footerLabel)
    footerLabel.textAlignment = .center
    footerLabel.delegate = self
    footerLabel.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(46)
      make.bottom.equalTo(bottomConstraint).inset(16)
    }
    footerLabel.set(content: .plainText("manage_card.kyc.footer".podLocalized()))
  }

  func createRefreshButton() {
    let refreshButton = ComponentCatalog.buttonWith(title: "manage_card.kyc.call_to_action.title".podLocalized(),
                                                    uiConfig: self.uiConfiguration) {
                                                      self.presenter.refreshTapped()
    }
    view.addSubview(refreshButton)
    refreshButton.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(44)
      make.bottom.equalTo(footerLabel.snp.top).offset(-16)
    }
  }
}

extension KYCViewController: ContentPresenterViewDelegate {
  func linkTapped(url: URL) {
    presenter.show(url: url)
  }
}
