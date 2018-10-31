//
//  ManageShiftCardViewController.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 24/10/2017.
//
//

import UIKit
import Stripe
import Bond
import ReactiveKit
import SnapKit
import PullToRefreshKit

protocol ManageShiftCardEventHandler: class {
  var viewModel: ManageShiftCardViewModel { get }
  func viewLoaded()
  func previousTapped()
  func closeTapped()
  func nextTapped()
  func cardTapped()
  func activateCardTapped()
  func refreshCard()
  func reloadTapped(showSpinner: Bool)
  func moreTransactionsTapped(completion: @escaping (_ noMoreTransactions: Bool) -> Void)
  func transactionSelected(indexPath: IndexPath)
  func activatePhysicalCard(code: String)
  func addFundingSourceTapped()
}

class ManageShiftCardViewController: ShiftViewController, ManageShiftCardViewProtocol {
  private unowned let eventHandler: ManageShiftCardEventHandler
  // swiftlint:disable implicitly_unwrapped_optional
  private var mainView: ManageShiftCardMainView!
  private var mainViewCellController: ViewWrapperCellController!
  private lazy var activationButton = UIBarButtonItem(image: UIImage.imageFromPodBundle("physical-card-icon"),
                                                      style: .plain,
                                                      target: self,
                                                      action: #selector(activatePhysicalCardTapped))
  // swiftlint:enable implicitly_unwrapped_optional
  private let activateCardView: ActivateCardView
  private let footer = DefaultRefreshFooter.footer()
  private let transactionsList = UITableView(frame: .zero, style: .grouped)
  private let mode: ShiftCardModuleMode
  private let emptyCaseView = UIView()
  private var shouldShowActivation: Bool? = false
  private let disposeBag = DisposeBag()

  init(mode: ShiftCardModuleMode, uiConfiguration: ShiftUIConfig, eventHandler: ManageShiftCardEventHandler) {
    self.eventHandler = eventHandler
    self.mode = mode
    self.activateCardView = ActivateCardView(uiConfig: uiConfiguration)
    super.init(uiConfiguration: uiConfiguration)
    self.mainView = ManageShiftCardMainView(uiConfiguration: uiConfiguration, cardStyle: nil, delegate: self)
    self.mainViewCellController = ViewWrapperCellController(view: self.mainView)
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

  override func closeTapped() {
    eventHandler.closeTapped()
  }

  override func previousTapped() {
    eventHandler.previousTapped()
  }

  override func nextTapped() {
    eventHandler.nextTapped()
  }

  func showLoadingSpinner() {
    showLoadingSpinner(tintColor: uiConfiguration.uiPrimaryColor)
  }
}

extension ManageShiftCardViewController: ManageShiftCardMainViewDelegate, ActivateCardViewDelegate {
  func cardTapped() {
    eventHandler.cardTapped()
  }

  func activateCardTapped() {
    eventHandler.activateCardTapped()
  }

  func needToUpdateUI(action: () -> (), completion: @escaping () -> ()) {
    CATransaction.begin()
    CATransaction.setCompletionBlock {
      completion()
    }
    transactionsList.beginUpdates()
    action()
    transactionsList.endUpdates()
    CATransaction.commit()
  }

  func addFundingSourceTapped() {
    self.eventHandler.addFundingSourceTapped()
  }

  @objc func activatePhysicalCardTapped() {
    UIAlertController.prompt(title: "manage.shift.card.enter-code.title".podLocalized(),
                             message: "manage.shift.card.enter-code.message".podLocalized(),
                             placeholder: "manage.shift.card.enter-code.placeholder".podLocalized(),
                             keyboardType: .numberPad,
                             okTitle: "manage.shift.card.enter-code.submit".podLocalized(),
                             cancelTitle: "general.button.cancel".podLocalized()) { [unowned self] code in
      guard let code = code, !code.isEmpty else { return }
      self.eventHandler.activatePhysicalCard(code: code)
    }
  }
}

extension ManageShiftCardViewController: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return eventHandler.viewModel.transactions.numberOfSections + 1
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 0 {
      return eventHandler.viewModel.cardHolder.value == nil ? 0 : 1
    }
    return eventHandler.viewModel.transactions.numberOfItems(inSection: section - 1)
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if indexPath.section == 0 {
      return mainViewCellController.cell(tableView)
    }
    let path = IndexPath(item: indexPath.row, section: indexPath.section - 1)
    let transaction = eventHandler.viewModel.transactions[path]
    let controller = TransactionListCellController(transaction: transaction, uiConfiguration: self.uiConfiguration)
    return controller.cell(tableView)
  }
}

extension ManageShiftCardViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if indexPath.section == 0 {
      return
    }
    let path = IndexPath(item: indexPath.row, section: indexPath.section - 1)
    eventHandler.transactionSelected(indexPath: path)
  }

  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    let headerViewSectionHeaderHeight: CGFloat = 0
    let transactionListSectionHeaderHeight: CGFloat = 40
    return section == 0 ? headerViewSectionHeaderHeight : transactionListSectionHeaderHeight
  }

  public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    guard section > 0 else {
      return nil
    }
    let view = UIView()
    view.backgroundColor = uiConfiguration.backgroundColor
    let label = UILabel()
    view.addSubview(label)
    label.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(16)
      make.bottom.equalToSuperview().inset(4)
    }
    label.textColor = uiConfiguration.textSecondaryColor
    label.font = uiConfiguration.fontProvider.sectionTitleFont
    label.text = eventHandler.viewModel.transactions.sections[section - 1].metadata
    return view
  }
}

// MARK: - Setup UI
private extension ManageShiftCardViewController {
  func setUpUI() {
    view.backgroundColor = uiConfiguration.backgroundColor
    setUpNavigationBar()
    setUpTransactionList()
    createRefreshHeader()
    createRefreshFooter()
    setUpEmptyCaseView()
    setUpActivateCardView()
  }

  func setUpNavigationBar() {
    self.title = "manage.shift.card.title".podLocalized()
    navigationController?.navigationBar.setUpWith(uiConfig: uiConfiguration)
    edgesForExtendedLayout = UIRectEdge()
    extendedLayoutIncludesOpaqueBars = true
    if mode == .standalone {
      hideNavBarBackButton()
    }
    else {
      showNavCancelButton(uiConfiguration.iconTertiaryColor)
    }
    // swiftlint:disable:next force_unwrapping
    showNavNextButton(icon: UIImage.imageFromPodBundle("top_profile@2x.png")!,
                      tintColor: uiConfiguration.iconTertiaryColor)
  }

  func setUpTransactionList() {
    transactionsList.backgroundColor = uiConfiguration.backgroundColor
    view.addSubview(transactionsList)
    transactionsList.snp.makeConstraints { make in
      make.left.right.top.bottom.equalTo(view)
    }
    transactionsList.separatorStyle = .none
    transactionsList.estimatedRowHeight = 60
    transactionsList.rowHeight = UITableViewAutomaticDimension
    transactionsList.dataSource = self
    transactionsList.delegate = self
    transactionsList.sectionFooterHeight = 0
  }

  func createRefreshHeader() {
    let header = DefaultRefreshHeader.header()
    header.textLabel.textColor = uiConfiguration.textTertiaryColor
    header.textLabel.font = uiConfiguration.fontProvider.timestampFont
    transactionsList.configRefreshHeader(with: header, container: self) { [weak self] in
      self?.eventHandler.reloadTapped(showSpinner: false)
    }
  }

  func createRefreshFooter() {
    footer.textLabel.textColor = uiConfiguration.textTertiaryColor
    footer.textLabel.font = uiConfiguration.fontProvider.timestampFont
    footer.textLabel.numberOfLines = 0
    footer.setText("manage.shift.card.refresh.title".podLocalized(), mode: .scrollAndTapToRefresh)
    footer.setText("manage.shift.card.refresh.loading".podLocalized(), mode: .refreshing)
    transactionsList.configRefreshFooter(with: footer, container: self) { [weak self] in
      self?.eventHandler.moreTransactionsTapped { noMoreTransactions in
        if noMoreTransactions {
          self?.transactionsList.switchRefreshFooter(to: .noMoreData)
        }
      }
    }
  }

  func setUpEmptyCaseView() {
    emptyCaseView.isHidden = true
    view.addSubview(emptyCaseView)
    emptyCaseView.snp.makeConstraints { make in
      make.left.right.bottom.equalToSuperview()
    }
    let label = ComponentCatalog.sectionTitleLabelWith(text: "manage.shift.card.no.transactions".podLocalized(),
                                                       textAlignment: .center,
                                                       uiConfig: uiConfiguration)
    label.textColor = uiConfiguration.textTertiaryColor
    label.numberOfLines = 0
    emptyCaseView.addSubview(label)
    label.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(16)
      make.bottom.equalToSuperview().inset(self.emptyCaseBottomMargin)
    }
    let imageView = UIImageView(image: UIImage.imageFromPodBundle("icon-emptycase-translist")?.asTemplate())
    imageView.tintColor = uiConfiguration.textTertiaryColor
    emptyCaseView.addSubview(imageView)
    imageView.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.bottom.equalTo(label.snp.top).offset(-8)
      make.top.equalToSuperview().offset(0)
    }
    view.bringSubview(toFront: emptyCaseView)
  }

  func setUpActivateCardView() {
    activateCardView.delegate = self
    activateCardView.backgroundColor = uiConfiguration.backgroundColor
    activateCardView.isHidden = true
    view.addSubview(activateCardView)
    activateCardView.snp.makeConstraints { make in
      make.left.right.bottom.equalToSuperview()
    }
    view.bringSubview(toFront: activateCardView)
  }

  private var emptyCaseBottomMargin: Int {
    switch UIDevice.deviceType() {
    case .iPhone5:
      return 40
    case .iPhone678:
      return 80
    case .iPhone678Plus, .iPhoneX, .iPhoneUnknown, .unknown:
      return 120
    }
  }

  func updateNavigationBar(showActivateButton: Bool) {
    var items = navigationItem.rightBarButtonItems ?? []
    if showActivateButton {
      if !items.contains(activationButton) {
        activationButton.tintColor = uiConfiguration.textTopBarColor
        items.append(activationButton)
        navigationItem.rightBarButtonItems = items
      }
    }
    else if items.contains(activationButton) {
      items.removeAll { $0 == activationButton }
      navigationItem.rightBarButtonItems = items
    }
  }
}

// MARK: - View model subscriptions
private extension ManageShiftCardViewController {
  func setupViewModelSubscriptions() {
    let viewModel = eventHandler.viewModel

    viewModel.cardHolder.observeNext { [unowned self] cardHolder in
      self.mainView.set(cardHolder: cardHolder)
      self.updateUI()
    }.dispose(in: disposeBag)

    viewModel.pan.observeNext { [unowned self] pan in
      self.mainView.set(cardNumber: pan)
    }.dispose(in: disposeBag)

    viewModel.lastFour.observeNext { [unowned self] lastFour in
      self.mainView.set(lastFour: lastFour)
    }.dispose(in: disposeBag)

    viewModel.cvv.observeNext { [unowned self] cvv in
      self.mainView.set(cvv: cvv)
    }.dispose(in: disposeBag)

    viewModel.cardNetwork.observeNext { [unowned self] cardNetwork in
      self.mainView.set(cardNetwork: cardNetwork)
    }.dispose(in: disposeBag)

    combineLatest(viewModel.expirationMonth,
                  viewModel.expirationYear).observeNext { [unowned self] expirationMonth, expirationYear in
                    if let expirationMonth = expirationMonth, let expirationYear = expirationYear {
                      self.mainView.set(expirationMonth: expirationMonth, expirationYear: expirationYear)
                    }
    }.dispose(in: disposeBag)

    viewModel.fundingSource.observeNext { [unowned self] fundingSource in
      self.mainView.set(fundingSource: fundingSource)
    }.dispose(in: disposeBag)

    viewModel.physicalCardActivationRequired.observeNext { [unowned self] physicalCardActivationRequired in
      self.mainView.set(physicalCardActivationRequired: physicalCardActivationRequired)
      self.updateNavigationBar(showActivateButton: physicalCardActivationRequired == true)
    }.dispose(in: disposeBag)

    combineLatest(viewModel.spendableToday,
                  viewModel.nativeSpendableToday).observeNext { [unowned self] spendableToday, nativeSpendableToday in
                    self.mainView.setSpendable(amount: spendableToday, nativeAmount: nativeSpendableToday)
    }.dispose(in: disposeBag)

    viewModel.state.observeNext { [unowned self] state in
      self.mainView.set(cardState: state)
      self.updateUI()
    }.dispose(in: disposeBag)

    viewModel.isActivateCardFeatureEnabled.observeNext { [unowned self] shouldShowActivation in
      self.mainView.set(activateCardFeatureEnabled: shouldShowActivation)
      self.shouldShowActivation = shouldShowActivation
    }.dispose(in: disposeBag)

    viewModel.cardInfoVisible.observeNext { [unowned self] visible in
      self.mainView.set(showInfo: visible)
    }.dispose(in: disposeBag)

    viewModel.transactions.observeNext { [unowned self] event in
      switch event.change {
      case .reset:
        break
      default:
        self.updateUI()
        self.transactionsList.switchRefreshHeader(to: .normal(.success, 0.5))
        self.transactionsList.switchRefreshFooter(to: .normal)
      }
    }.dispose(in: disposeBag)

    viewModel.transactionsLoaded.observeNext { [unowned self] _ in
      self.updateUI()
    }.dispose(in: disposeBag)

    viewModel.cardStyle.observeNext { [unowned self] cardStyle in
      self.mainView.set(cardStyle: cardStyle)
    }.dispose(in: disposeBag)
  }

  func updateUI() {
    let viewModel = eventHandler.viewModel
    transactionsList.reloadData()
    activateCardView.isHidden = shouldShowActivation == true ? viewModel.state.value != .created : true
    footer.isHidden = viewModel.transactions.isEmpty
    // Only show the empty case if we are all set
    if viewModel.transactionsLoaded.value == true {
      emptyCaseView.isHidden = !viewModel.transactions.isEmpty
    }
  }
}
