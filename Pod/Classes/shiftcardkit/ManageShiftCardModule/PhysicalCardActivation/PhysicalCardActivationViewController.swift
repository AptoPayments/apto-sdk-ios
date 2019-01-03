//
// PhysicalCardActivationViewController.swift
// ShiftSDK
//
// Created by Takeichi Kanzaki on 2018-12-10.
//

import UIKit
import SnapKit
import ReactiveKit

class PhysicalCardActivationViewController: ShiftViewController {
  private let disposeBag = DisposeBag()
  private unowned let presenter: PhysicalCardActivationPresenterProtocol
  private let titleLabel: UILabel
  private let cardView: CreditCardView
  private let addressTitleLabel: UILabel
  private let addressValueLabel = UILabel()
  private var activateButton: UIButton! // swiftlint:disable:this implicitly_unwrapped_optional
  private let footerLabel: ContentPresenterView

  init(uiConfiguration: ShiftUIConfig, presenter: PhysicalCardActivationPresenterProtocol) {
    self.presenter = presenter
    let title = "manage_card.activate_physical_card.title".podLocalized()
    self.titleLabel = ComponentCatalog.largeTitleLabelWith(text: title, uiConfig: uiConfiguration)
    self.cardView = CreditCardView(uiConfiguration: uiConfiguration, cardStyle: nil)
    let addressTitle = "manage_card.activate_physical_card.shipping_address".podLocalized()
    self.addressTitleLabel  = ComponentCatalog.sectionTitleLabelWith(text: addressTitle, uiConfig: uiConfiguration)
    self.footerLabel = ContentPresenterView(uiConfig: uiConfiguration)
    super.init(uiConfiguration: uiConfiguration)
    let buttonTitle = "manage_card.activate_physical_card.call_to_action.title".podLocalized()
    self.activateButton = ComponentCatalog.buttonWith(title: buttonTitle,
                                                      uiConfig: uiConfiguration) { [unowned self] in
      self.presenter.activateCardTapped()
    }
  }

  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    setUpUI()
    setUpViewModelObservers()
    presenter.viewLoaded()
  }
}

extension PhysicalCardActivationViewController: ContentPresenterViewDelegate {
  func linkTapped(url: URL) {
    presenter.show(url: url)
  }
}

// MARK: - View model observers
private extension PhysicalCardActivationViewController {
  func setUpViewModelObservers() {
    let viewModel = presenter.viewModel

    viewModel.address.observeNext { [weak self] address in
      self?.set(address: address)
    }.dispose(in: disposeBag)
    viewModel.lastFour.observeNext { [weak self] lastFour in
      self?.cardView.set(lastFour: lastFour)
    }.dispose(in: disposeBag)
    viewModel.cardNetwork.observeNext { [weak self] cardNetwork in
      self?.cardView.set(cardNetwork: cardNetwork)
    }.dispose(in: disposeBag)
    viewModel.cardHolder.observeNext { [weak self] cardHolder in
      self?.cardView.set(cardHolder: cardHolder)
    }.dispose(in: disposeBag)
    viewModel.cardStyle.observeNext { [weak self] cardStyle in
      self?.cardView.set(cardStyle: cardStyle)
    }.dispose(in: disposeBag)
  }

  func set(address: Address?) {
    guard let address = address else { return }
    let addressFormatter = AddressFormatter(dataPoint: address)
    guard let formattedAddress = addressFormatter.titleValues.first?.value else { return }
    addressValueLabel.text = formattedAddress
  }
}

// MARK: - Set up UI
private extension PhysicalCardActivationViewController {
  func setUpUI() {
    view.backgroundColor = uiConfiguration.uiBackgroundPrimaryColor
    setUpNavigationBar()
    setUpTitleLabel()
    setUpCardView()
    setUpAddressView()
    setUpFooterLabel()
    setUpActivateButton()
  }

  func setUpNavigationBar() {
    navigationController?.isNavigationBarHidden = true
    setNeedsStatusBarAppearanceUpdate()
  }

  func setUpTitleLabel() {
    view.addSubview(titleLabel)
    titleLabel.snp.makeConstraints { make in
      let offset = showCard() ? 0 : -130
      make.left.right.equalToSuperview().inset(26)
      make.centerY.equalToSuperview().offset(offset)
    }
  }

  func setUpCardView() {
    guard showCard() else { return }
    view.addSubview(cardView)
    cardView.set(cardState: .active) // In this view the card is always presented as active
    cardView.set(showInfo: false) // Disable copy card number
    cardView.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(26)
      make.height.equalTo(cardView.snp.width).dividedBy(cardAspectRatio)
      make.bottom.equalTo(titleLabel.snp.top).offset(-46)
    }
  }

  func setUpAddressView() {
    setUpAddressTitleLabel()
    setUpAddressValueLabel()
  }

  func setUpAddressTitleLabel() {
    view.addSubview(addressTitleLabel)
    addressTitleLabel.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(26)
      make.top.equalTo(titleLabel.snp.bottom).offset(20)
    }
  }

  func setUpAddressValueLabel() {
    addressValueLabel.font = uiConfiguration.fontProvider.formFieldFont
    addressValueLabel.textColor = uiConfiguration.textSecondaryColor
    addressValueLabel.numberOfLines = 0
    view.addSubview(addressValueLabel)
    addressValueLabel.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(26)
      make.top.equalTo(addressTitleLabel.snp.bottom).offset(12)
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
    footerLabel.set(content: .plainText("manage_card.activate_physical_card.footer".podLocalized()))
  }

  func setUpActivateButton() {
    view.addSubview(activateButton)
    activateButton.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(44)
      make.bottom.equalTo(footerLabel.snp.top).offset(-16)
    }
  }

  func showCard() -> Bool {
    return UIDevice.deviceType() != .iPhone5
  }
}
