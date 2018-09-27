//
//  ExternalOAuthViewController.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 03/06/2018.
//
//

import Foundation
import SnapKit
import ReactiveKit

class ExternalOAuthViewController: ShiftViewController {
  private unowned let eventHandler: ExternalOAuthPresenterProtocol
  private let imageView = UIImageView()
  private let providerLabel = UILabel()
  private let accessDescriptionLabel = UILabel()
  private var actionButton: UIButton! // swiftlint:disable:this implicitly_unwrapped_optional
  private let descriptionLabel = UILabel()

  init(uiConfiguration: ShiftUIConfig, eventHandler: ExternalOAuthPresenterProtocol) {
    self.eventHandler = eventHandler
    super.init(uiConfiguration: uiConfiguration)
    self.actionButton = ComponentCatalog.buttonWith(title: "", uiConfig: uiConfiguration) { [unowned self] in
      self.eventHandler.custodianTapped(custodianType: .coinbase)
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

  // Setup viewModel subscriptions
  private func setupViewModelSubscriptions() {
    let viewModel = eventHandler.viewModel

    _ = viewModel.title.ignoreNil().observeNext { title in
      self.set(title: title)
    }

    _ = viewModel.imageName.observeNext { imageName in
      self.set(imageName: imageName)
    }

    _ = viewModel.provider.ignoreNil().observeNext { provider in
      self.set(provider: provider)
     }

    _ = viewModel.accessDescription.ignoreNil().observeNext { accessDescription in
      self.set(accessDescription: accessDescription)
    }

    _ = viewModel.callToActionTitle.ignoreNil().observeNext { actionTitle in
      self.set(actionTitle: actionTitle)
    }

    _ = viewModel.description.ignoreNil().observeNext { description in
      self.set(description: description)
    }
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

  override func previousTapped() {
    eventHandler.backTapped()
  }
}

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
    providerLabel.font = uiConfiguration.amountBigFont
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
    accessDescriptionLabel.font = uiConfiguration.formListFont
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
    descriptionLabel.font = uiConfiguration.instructionsFont
    descriptionLabel.textAlignment = .center
    descriptionLabel.snp.makeConstraints { make in
      make.top.equalTo(actionButton.snp.bottom).offset(32)
      make.left.right.equalToSuperview().inset(64)
    }
  }
}
