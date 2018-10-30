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
  private var disposeBag = DisposeBag()
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

extension ShiftCardSettingsViewController: FundingSourceEmptyCaseViewDelegate {
  func addFundingSourceTapped() {
    self.presenter.addFundingSourceTapped()
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
    combineLatest(viewModel.showBalancesSection,
                  viewModel.showChangePin,
                  viewModel.showGetPin,
                  viewModel.fundingSources,
                  viewModel.fundingSourcesLoaded,
                  viewModel.legalDocuments).observeNext { [unowned self] showBalancesSection, showChangePin,
                                                                         showGetPin, fundingSources,
                                                                         fundingSourcesLoaded, legalDocuments in
      let rows = [
        self.createFundingSourceTitle(showBalancesSection),
        self.createFundingSourceView(showBalancesSection,
                                     fundingSources: fundingSources,
                                     fundingSourcesLoaded: fundingSourcesLoaded),
        self.createAddFoundingSourceButton(showBalancesSection, fundingSources: fundingSources),
        self.createSettingsTitle(),
        self.createChangePinRow(showButton: showChangePin),
        self.createGetPinRow(showButton: showGetPin),
        self.setUpShowCardInfoRow(),
        self.setUpLockCardRow(),
        self.createSupportTitle(),
        self.createLostCardButton(),
        self.createFAQButton(legalDocuments.faq),
        self.createLegalTitle(legalDocuments: legalDocuments),
        self.createCardholderAgreementButton(legalDocuments.cardHolderAgreement),
        self.createTermsAndConditionsButton(legalDocuments.termsAndConditions),
        self.createPrivacyPolicyButton(legalDocuments.privacyPolicy)
      ].compactMap { return $0 }
      self.formView.show(rows: rows)
    }.dispose(in: disposeBag)

    viewModel.locked.observeNext { [unowned self] locked in
      if let locked = locked {
        self.set(lockedSwitch: locked)
      }
    }.dispose(in: disposeBag)

    viewModel.showCardInfo.observeNext { [unowned self] showInfo in
      if let showInfo = showInfo {
        self.set(showCardInfoSwitch: showInfo)
      }
    }.dispose(in: disposeBag)
  }

  func createFundingSourceTitle(_ showBalancesSection: Bool?) -> FormRowLabelView? {
    guard showBalancesSection == true else { return nil }
    return FormBuilder.sectionTitleRowWith(text: "card.settings.funding_sources.title".podLocalized(),
                                           textAlignment: .left,
                                           uiConfig: self.uiConfiguration)
  }

  func createFundingSourceView(_ showBalancesSection: Bool?,
                               fundingSources: [FundingSource],
                               fundingSourcesLoaded: Bool) -> FormRowView? {
    guard showBalancesSection == true else { return nil }
    if !fundingSources.isEmpty {
      return createFundingSourceSelector(fundingSources: fundingSources)
    }
    else {
      return createFundingSourceEmptyCase(fundingSourcesLoaded: fundingSourcesLoaded)
    }
  }

  func createFundingSourceSelector(fundingSources: [FundingSource]) -> FormRowBalanceRadioView {
    let rows = rowValuesFrom(fundingSources: fundingSources)
    let values = fundingSources.enumerated().map { (index, _) in
      return index
    }
    let selector = FormBuilder.balanceRadioRowWith(balances: rows,
                                                   values: values,
                                                   uiConfig: uiConfiguration)
    selector.bndValue.observeNext { [weak self] index in
      if let index = index {
        self?.presenter.fundingSourceSelected(index: index)
      }
    }.dispose(in: disposeBag)
    presenter.viewModel.activeFundingSourceIdx.bind(to: selector.bndValue)
    return selector
  }

  func createFundingSourceEmptyCase(fundingSourcesLoaded: Bool) -> FormRowCustomView? {
    guard fundingSourcesLoaded else { return nil }
    let emptyCaseView = FundingSourceEmptyCaseView(uiConfig: uiConfiguration)
    emptyCaseView.delegate = self
    return FormRowCustomView(view: emptyCaseView, showSplitter: false)
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

  func createLegalTitle(legalDocuments: LegalDocuments) -> FormRowLabelView? {
    let content: [Content?] = [
      legalDocuments.cardHolderAgreement,
      legalDocuments.termsAndConditions,
      legalDocuments.privacyPolicy
    ]
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

  func createAddFoundingSourceButton(_ showBalancesSection: Bool?,
                                     fundingSources: [FundingSource]) -> FormRowLinkView? {
    guard showBalancesSection == true, !fundingSources.isEmpty else { return nil }
    let retVal = FormBuilder.linkRowWith(title: "card.settings.add-funding-source.button.title".podLocalized(),
                                         leftIcon: UIImage.imageFromPodBundle("add-icon")?.asTemplate(),
                                         uiConfig: self.uiConfiguration) { [unowned self] in
      self.presenter.addFundingSourceTapped()
    }
    retVal.label?.textColor = uiConfiguration.uiPrimaryColor

    return retVal
  }

  func createChangePinRow(showButton: Bool) -> FormRowTopBottomLabelView? {
    guard showButton else { return nil }
    return FormBuilder.linkRowWith(title: "card.settings.change-pin.title".podLocalized(),
                                   subtitle: "card.settings.change-pin.subtitle".podLocalized(),
                                   leftIcon: nil,
                                   uiConfig: uiConfiguration) { [unowned self] in
      self.presenter.changePinTapped()
    }
  }

  func createGetPinRow(showButton: Bool) -> FormRowTopBottomLabelView? {
    guard showButton else { return nil }
    return FormBuilder.linkRowWith(title: "card.settings.get-pin.title".podLocalized(),
                                   subtitle: "card.settings.get-pin.subtitle".podLocalized(),
                                   leftIcon: nil,
                                   uiConfig: uiConfiguration) { [unowned self] in
      self.presenter.getPinTapped()
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
