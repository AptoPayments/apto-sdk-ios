//
//  ShiftCardSettingsViewController.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 25/03/2018.
//
//

import UIKit
import Stripe
import Bond
import ReactiveKit
import SnapKit
import PullToRefreshKit

class ShiftCardSettingsViewController: ShiftViewController, ShiftCardSettingsViewProtocol {
  private unowned let presenter: ShiftCardSettingsPresenterHandler
  private let formView = MultiStepForm()
  private var lockCardRow: FormRowSwitchTitleSubtitleView?
  private var showCardInfoRow: FormRowSwitchTitleSubtitleView?

  init(uiConfiguration: ShiftUIConfig, presenter: ShiftCardSettingsPresenterHandler) {
    self.presenter = presenter
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

  override func previousTapped() {
    presenter.previousTapped()
  }

  override func closeTapped() {
    presenter.closeTapped()
  }

  func showLoadingSpinner() {
    showLoadingSpinner(tintColor: uiConfiguration.uiPrimaryColor, position: .topCenter)
  }

  private func set(lockedSwitch: Bool) {
    self.lockCardRow?.switcher.isOn = lockedSwitch
  }

  private func set(showCardInfoSwitch: Bool) {
    self.showCardInfoRow?.switcher.isOn = showCardInfoSwitch
  }
}

// MARK: - Set up UI
private extension ShiftCardSettingsViewController {
  func setUpUI() {
    view.backgroundColor = uiConfiguration.backgroundColor
    setUpNavigationBar()
    setUpFormView()
  }

  func setUpNavigationBar() {
    navigationController?.navigationBar.setUpWith(uiConfig: uiConfiguration)
    edgesForExtendedLayout = UIRectEdge()
    extendedLayoutIncludesOpaqueBars = true
    self.title = "card.settings.title".podLocalized()
  }

  func setUpFormView() {
    view.addSubview(self.formView)
    formView.snp.makeConstraints { make in
      make.top.left.right.bottom.equalToSuperview()
    }
    formView.backgroundColor = view.backgroundColor
  }
}

// MARK: - View model subscriptions
private extension ShiftCardSettingsViewController {
  func setupViewModelSubscriptions() {
    let viewModel = presenter.viewModel

    _ = combineLatest(viewModel.showAddFundingSourceButton,
                      viewModel.fundingSources,
                      viewModel.faq,
                      viewModel.cardHolderAgreement,
                      viewModel.termsAndConditions,
                      viewModel.privacyPolicy).observeNext { [unowned self] showAddFundingSourceButton, fundingSources,
                                                             faq, cardHolderAgreement, termsAndConditions,
                                                             privacyPolicy in
      let rows = [
        self.createFundingSourceTitle(),
        self.createFundingSourceSelector(fundingSources: fundingSources),
        self.createAddFoundingSourceButton(showAddFundingSourceButton),
        self.createSettingsTitle(),
        self.createChangePinRow(),
        self.setUpShowCardInfoRow(),
        self.setUpLockCardRow(),
        self.createSupportTitle(),
        self.createLostCardButton(),
        self.createFAQButton(faq),
        self.createLegalTitle(content: [cardHolderAgreement, termsAndConditions, privacyPolicy]),
        self.createCardholderAgreementButton(cardHolderAgreement),
        self.createTermsAndConditionsButton(termsAndConditions),
        self.createPrivacyPolicyButton(privacyPolicy)
      ].compactMap { return $0 }
      self.formView.show(rows: rows)
    }

    _ = viewModel.locked.observeNext { [unowned self] locked in
      if let locked = locked {
        self.set(lockedSwitch: locked)
      }
    }

    _ = viewModel.showCardInfo.observeNext { [unowned self] showInfo in
      if let showInfo = showInfo {
        self.set(showCardInfoSwitch: showInfo)
      }
    }
  }

  func createFundingSourceTitle() -> FormRowLabelView {
    return FormBuilder.sectionTitleRowWith(text: "card.settings.funding_sources.title".podLocalized(),
                                           textAlignment: .left,
                                           uiConfig: self.uiConfiguration)
  }

  func createFundingSourceSelector(fundingSources: [FundingSource]) -> FormRowBalanceRadioView {
    let rows = rowValuesFrom(fundingSources: fundingSources)
    let values = fundingSources.enumerated().map { (index, _) in
      return index
    }
    let selector = FormBuilder.balanceRadioRowWith(balances: rows,
                                                   values: values,
                                                   uiConfig: uiConfiguration)
    _ = selector.bndValue.observeNext { [weak self] index in
      if let index = index {
        self?.presenter.fundingSourceSelected(index: index)
      }
    }
    presenter.viewModel.activeFundingSourceIdx.bind(to: selector.bndValue)
    return selector
  }

  func rowValuesFrom(fundingSources: [FundingSource]) -> [FormRowBalanceRadioViewValue] {
    return fundingSources.map { fundingSource in
      guard let amount = fundingSource.balance else {
        return nil
      }
      if let wallet = fundingSource as? CustodianWallet {
        return FormRowBalanceRadioViewValue(title: wallet.custodian.name ?? "",
                                            amount: amount,
                                            subtitle: wallet.nativeBalance.longText)
      }
      else {
        return FormRowBalanceRadioViewValue(title: "",
                                            amount: amount,
                                            subtitle: nil)
      }
    }.compactMap { return $0 }
  }

  func createSettingsTitle() -> FormRowLabelView {
    return FormBuilder.sectionTitleRowWith(text: "card.settings.settings.title".podLocalized(),
                                           textAlignment: .left,
                                           uiConfig: self.uiConfiguration)
  }

  func createSupportTitle() -> FormRowLabelView {
    return FormBuilder.sectionTitleRowWith(text: "card.settings.support.title".podLocalized(),
                                           textAlignment: .left,
                                           uiConfig: self.uiConfiguration)
  }

  func createLostCardButton() -> FormRowTopBottomLabelView {
    return FormBuilder.linkRowWith(title: "card.settings.report-lost-card.title".podLocalized(),
                                   subtitle: "card.settings.report-lost-card.subtitle".podLocalized(),
                                   leftIcon: nil,
                                   uiConfig: uiConfiguration) { [unowned self] in
      self.presenter.lostCardTapped()
    }
  }

  func createFAQButton(_ faq: Content?) -> FormRowTopBottomLabelView? {
    return createContentRow(faq,
                            title: "card.settings.faq.title".podLocalized(),
                            subtitle: "card.settings.faq.subtitle".podLocalized())
  }

  func createLegalTitle(content: [Content?]) -> FormRowLabelView? {
    guard !(content.compactMap { return $0 }).isEmpty else {
      return nil
    }
    return FormBuilder.sectionTitleRowWith(text: "card.settings.legal.title".podLocalized(),
                                           textAlignment: .left,
                                           uiConfig: self.uiConfiguration)
  }

  func createCardholderAgreementButton(_ agreement: Content?) -> FormRowTopBottomLabelView? {
    return createContentRow(agreement,
                            title: "card.settings.cardholder-agreement.title".podLocalized(),
                            subtitle: "card.settings.cardholder-agreement.subtitle".podLocalized())
  }

  func createTermsAndConditionsButton(_ termsAndConditions: Content?) -> FormRowTopBottomLabelView? {
    return createContentRow(termsAndConditions,
                            title: "card.settings.terms-and-conditions.title".podLocalized(),
                            subtitle: "card.settings.terms-and-conditions.subtitle".podLocalized())
  }

  func createPrivacyPolicyButton(_ privacyPolicy: Content?) -> FormRowTopBottomLabelView? {
    return createContentRow(privacyPolicy,
                            title: "card.settings.privacy-policy.title".podLocalized(),
                            subtitle: "card.settings.privacy-policy.subtitle".podLocalized())
  }

  func createContentRow(_ content: Content?, title: String, subtitle: String) -> FormRowTopBottomLabelView? {
    guard let content = content else {
      return nil
    }
    return FormBuilder.linkRowWith(title: title,
                                   subtitle: subtitle,
                                   leftIcon: nil,
                                   uiConfig: uiConfiguration) { [unowned self] in
      self.presenter.show(content: content, title: title)
    }
  }

  func createAddFoundingSourceButton(_ showAddFundingSourceButton: Bool?) -> FormRowLinkView? {
    guard showAddFundingSourceButton == true else { return nil }
    let retVal = FormBuilder.linkRowWith(title: "card.settings.add-funding-source.button.title".podLocalized(),
                                         leftIcon: UIImage.imageFromPodBundle("add-icon")?.asTemplate(),
                                         uiConfig: self.uiConfiguration) { [unowned self] in
      self.presenter.addFundingSourceTapped()
    }
    retVal.label?.textColor = uiConfiguration.uiPrimaryColor

    return retVal
  }

  func createChangePinRow() -> FormRowTopBottomLabelView {
    return FormBuilder.linkRowWith(title: "card.settings.change-pin.title".podLocalized(),
                                   subtitle: "card.settings.change-pin.subtitle".podLocalized(),
                                   leftIcon: nil,
                                   uiConfig: uiConfiguration) { [unowned self] in
      self.presenter.changePinTapped()
    }
  }

  func setUpLockCardRow() -> FormRowSwitchTitleSubtitleView? {
    lockCardRow = FormBuilder.titleSubtitleSwitchRowWith(title: "card.settings.enable-card.title".podLocalized(),
                                                         subtitle: "card.settings.enable-card.subtitle".podLocalized(),
                                                         uiConfig: uiConfiguration) { [unowned self] switcher in
      self.presenter.lockCardChanged(switcher: switcher)
    }
    if let locked = presenter.viewModel.locked.value {
      set(lockedSwitch: locked)
    }
    return lockCardRow
  }

  func setUpShowCardInfoRow() -> FormRowSwitchTitleSubtitleView? {
    showCardInfoRow = FormBuilder.titleSubtitleSwitchRowWith(title: "card.settings.show-card.title".podLocalized(),
                                                             subtitle: "card.settings.show-card.subtitle".podLocalized(),
                                                             uiConfig: uiConfiguration) { [unowned self] switcher in
      self.presenter.showCardInfoChanged(switcher: switcher)
    }
    if let showInfo = presenter.viewModel.showCardInfo.value {
      set(showCardInfoSwitch: showInfo)
    }
    return showCardInfoRow
  }
}
