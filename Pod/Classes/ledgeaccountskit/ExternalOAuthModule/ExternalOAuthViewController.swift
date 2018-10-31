//
//  ExternalOAuthViewController.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 03/06/2018.
//
//

import Foundation
import SnapKit
import ReactiveKit

class ExternalOAuthViewController: ShiftViewController {
  private var disposeBag = DisposeBag()
  private unowned let presenter: ExternalOAuthPresenterProtocol
  private let imageView = UIImageView()
  private let providerLabel = UILabel()
  private let accessDescriptionLabel = UILabel()
  private var actionButton: UIButton! // swiftlint:disable:this implicitly_unwrapped_optional
  private let descriptionLabel = UILabel()
  private var allowedBalanceTypes = [AllowedBalanceType]()
  init(uiConfiguration: ShiftUIConfig, eventHandler: ExternalOAuthPresenterProtocol) {
    self.presenter = eventHandler
    super.init(uiConfiguration: uiConfiguration)
    self.actionButton = ComponentCatalog.buttonWith(title: "", uiConfig: uiConfiguration) { [unowned self] in
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
private extension ExternalOAuthViewController {
  func setupViewModelSubscriptions() {
    let viewModel = presenter.viewModel

    viewModel.title.ignoreNil().observeNext { [unowned self] title in
      self.set(title: title)
    }.dispose(in: disposeBag)

    viewModel.imageName.observeNext { [unowned self] imageName in
      self.set(imageName: imageName)
    }.dispose(in: disposeBag)

    viewModel.provider.ignoreNil().observeNext { [unowned self] provider in
      self.set(provider: provider)
    }.dispose(in: disposeBag)

    viewModel.accessDescription.ignoreNil().observeNext { [unowned self] accessDescription in
      self.set(accessDescription: accessDescription)
    }.dispose(in: disposeBag)

    viewModel.callToActionTitle.ignoreNil().observeNext { [unowned self] actionTitle in
      self.set(actionTitle: actionTitle)
    }.dispose(in: disposeBag)

    viewModel.description.ignoreNil().observeNext { [unowned self] description in
      self.set(description: description)
    }.dispose(in: disposeBag)

    viewModel.allowedBalanceTypes.ignoreNil().observeNext { [unowned self] allowedBalanceTypes in
      self.allowedBalanceTypes = allowedBalanceTypes
    }.dispose(in: disposeBag)
  }

  func set(imageName: String?) {
    if let imageName = imageName {
      self.imageView.image = UIImage.imageFromPodBundle(imageName)
    }
    else {
      self.imageView.image = nil
    }
  }

  func set(provider: String) {
    providerLabel.text = provider
  }

  func set(accessDescription: String) {
    accessDescriptionLabel.text = accessDescription
  }

  func set(actionTitle: String) {
    actionButton.setTitle(actionTitle, for: .normal)
  }

  func set(description: String) {
    descriptionLabel.text = description
  }
}

// MARK: - Set up UI
private extension ExternalOAuthViewController {
  func setUpUI() {
    view.backgroundColor = uiConfiguration.backgroundColor
    navigationController?.navigationBar.setUpWith(uiConfig: uiConfiguration)
    edgesForExtendedLayout = UIRectEdge()
    extendedLayoutIncludesOpaqueBars = true
    showNavPreviousButton(uiConfiguration.iconTertiaryColor)

    setUpImageView()
    setUpProviderLabel()
    setUpAccessDescriptionLabel()
    setUpActionButton()
    setUpDescriptionLabel()
  }

  func setUpImageView() {
    imageView.contentMode = .scaleAspectFit
    view.addSubview(imageView)
    imageView.snp.makeConstraints { make in
      make.top.equalToSuperview().offset(88)
      make.centerX.equalToSuperview()
      make.height.equalTo(48)
      make.width.equalTo(180)
    }
  }

  func setUpProviderLabel() {
    view.addSubview(providerLabel)
    providerLabel.textColor = uiConfiguration.textPrimaryColor
    providerLabel.font = uiConfiguration.fontProvider.amountBigFont
    providerLabel.textAlignment = .center
    providerLabel.snp.makeConstraints { make in
      make.top.equalTo(imageView.snp.bottom).offset(40)
      make.left.right.equalToSuperview().inset(18)
    }
  }

  func setUpAccessDescriptionLabel() {
    view.addSubview(accessDescriptionLabel)
    accessDescriptionLabel.numberOfLines = 0
    accessDescriptionLabel.textColor = uiConfiguration.textSecondaryColor
    accessDescriptionLabel.font = uiConfiguration.fontProvider.formListFont
    accessDescriptionLabel.textAlignment = .center
    accessDescriptionLabel.snp.makeConstraints { make in
      make.left.right.equalTo(providerLabel)
      make.top.equalTo(providerLabel.snp.bottom).offset(4)
    }
  }

  func setUpActionButton() {
    view.addSubview(actionButton)
    actionButton.snp.makeConstraints { make in
      make.top.equalTo(accessDescriptionLabel.snp.bottom).offset(60)
      make.left.right.equalToSuperview().inset(44)
    }
  }

  func setUpDescriptionLabel() {
    view.addSubview(descriptionLabel)
    descriptionLabel.numberOfLines = 0
    descriptionLabel.textColor = uiConfiguration.textTertiaryColor
    descriptionLabel.font = uiConfiguration.fontProvider.instructionsFont
    descriptionLabel.textAlignment = .center
    descriptionLabel.snp.makeConstraints { make in
      make.top.equalTo(actionButton.snp.bottom).offset(32)
      make.left.right.equalToSuperview().inset(64)
    }
  }
}
