//
//  PhysicalCardActivationSucceedViewControllerTheme2.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 28/12/2018.
//

import SnapKit
import Bond
import ReactiveKit

class PhysicalCardActivationSucceedViewControllerTheme2: PhysicalCardActivationSucceedViewControllerProtocol {
  private let disposeBag = DisposeBag()
  private unowned let presenter: PhysicalCardActivationSucceedPresenterProtocol

  init(uiConfiguration: ShiftUIConfig, presenter: PhysicalCardActivationSucceedPresenterProtocol) {
    self.presenter = presenter
    super.init(uiConfiguration: uiConfiguration)
  }

  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    setUpUI()
    setUpViewModelSubscriptions()
    presenter.viewLoaded()
  }

  override func closeTapped() {
    presenter.closeTapped()
  }
}

// MARK: - View model subscriptions
private extension PhysicalCardActivationSucceedViewControllerTheme2 {
  func setUpViewModelSubscriptions() {
    presenter.viewModel.showGetPinButton.observeNext { [unowned self] _ in
      self.setUpUI()
    }.dispose(in: disposeBag)
  }
}

// MARK: - Set up UI
private extension PhysicalCardActivationSucceedViewControllerTheme2 {
  func setUpUI() {
    view.backgroundColor = uiConfiguration.uiBackgroundSecondaryColor
    setUpNavigationBar()
    setupContent()
    if presenter.viewModel.showGetPinButton.value {
      let label = createChargeApplyLabel()
      createGetPinButton(chargeApplyView: label)
    }
  }

  func setUpNavigationBar() {
    navigationController?.navigationBar.setUp(barTintColor: uiConfiguration.uiNavigationSecondaryColor,
                                              tintColor: uiConfiguration.iconTertiaryColor)
    navigationController?.navigationBar.hideShadow()
    navigationItem.leftBarButtonItem?.tintColor = uiConfiguration.iconTertiaryColor
    edgesForExtendedLayout = UIRectEdge()
    extendedLayoutIncludesOpaqueBars = true
    setNeedsStatusBarAppearanceUpdate()
  }

  func setupContent() {
    let contentView = UIView()
    view.addSubview(contentView)
    contentView.snp.makeConstraints { make in
      make.centerX.equalTo(view)
      make.centerY.equalTo(view).offset(-44)
      make.left.right.equalToSuperview().inset(44)
    }
    let titleLabel = createTitleLabel()
    contentView.addSubview(titleLabel)
    titleLabel.snp.makeConstraints { make in
      make.left.right.top.equalTo(contentView)
    }
    let explanationLabel = createExplanationLabel()
    contentView.addSubview(explanationLabel)
    explanationLabel.snp.makeConstraints { make in
      make.left.right.bottom.equalTo(contentView)
      make.top.equalTo(titleLabel.snp.bottom).offset(24)
    }
  }

  func createTitleLabel() -> UILabel {
    let title = "physical.card.activation.succeed.label.title".podLocalized()
    let label = ComponentCatalog.largeTitleLabelWith(text: title, uiConfig: uiConfiguration)
    label.textAlignment = .center
    return label
  }

  func createExplanationLabel() -> UILabel {
    let explanation = "physical.card.activation.succeed.label.message".podLocalized()
    let label = ComponentCatalog.mainItemRegularLabelWith(text: explanation, multiline: true, uiConfig: uiConfiguration)
    label.textAlignment = .center
    return label
  }

  func createGetPinButton(chargeApplyView: UIView) {
    let button = ComponentCatalog.buttonWith(title: "physical.card.activation.succeed.button.title".podLocalized(),
                                             showShadow: false,
                                             accessibilityLabel: "Get PIN button",
                                             uiConfig: uiConfiguration) { [unowned self] in
                                              self.presenter.getPinTapped()
    }
    view.addSubview(button)
    button.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(44)
      make.bottom.equalTo(chargeApplyView.snp.top).offset(-32)
    }
  }

  func createChargeApplyLabel() -> UILabel {
    let chargeExplanation = "physical.card.activation.succeed.call.charge".podLocalized()
    let label = ComponentCatalog.instructionsLabelWith(text: chargeExplanation, uiConfig: uiConfiguration)
    view.addSubview(label)
    label.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(44)
      make.bottom.equalToSuperview().inset(44)
    }
    return label
  }
}
