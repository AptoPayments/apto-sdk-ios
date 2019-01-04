//
// ManageShiftCardViewControllerTheme2.swift
// ShiftSDK
//
// Created by Takeichi Kanzaki on 2018-12-11.
//

import UIKit
import Stripe
import Bond
import ReactiveKit
import SnapKit
import PullToRefreshKit

class ManageShiftCardViewControllerTheme2: ManageShiftCardViewControllerProtocol {
  private unowned let presenter: ManageShiftCardEventHandler
  private let topBackgroundView = UIView()
  private let bottomBackgroundView = UIView()
  // swiftlint:disable implicitly_unwrapped_optional
  private var mainView: ManageShiftCardMainViewProtocol!
  private var mainViewCellController: ViewWrapperCellController!
  // swiftlint:enable implicitly_unwrapped_optional
  private lazy var activationButton : UIBarButtonItem = { [unowned self] in
    return buildActivatePhysicalCardButtonItem()
  }()
  private let activateCardView: ActivateCardView
  private let footer = DefaultRefreshFooter.footer()
  private let transactionsList = UITableView(frame: .zero, style: .grouped)
  private let mode: ShiftCardModuleMode
  private let emptyCaseView = UIView()
  private var shouldShowActivation: Bool? = false
  private let disposeBag = DisposeBag()

  private lazy var notifyViewLoaded: () -> Void = { [unowned self] in
    self.presenter.viewLoaded()
    return {}
  }()

  init(mode: ShiftCardModuleMode, uiConfiguration: ShiftUIConfig, presenter: ManageShiftCardEventHandler) {
    self.presenter = presenter
    self.mode = mode
    self.activateCardView = ActivateCardView(uiConfig: uiConfiguration)
    super.init(uiConfiguration: uiConfiguration)
    self.mainView = ManageShiftCardMainViewTheme2(uiConfiguration: uiConfiguration, cardStyle: nil, delegate: self)
    self.mainViewCellController = ViewWrapperCellController(view: self.mainView)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    setUpUI()

    setupViewModelSubscriptions()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    setUpNavigationBar()
    notifyViewLoaded()
  }

  override func closeTapped() {
    presenter.closeTapped()
  }

  override func previousTapped() {
    presenter.previousTapped()
  }

  override func nextTapped() {
    presenter.nextTapped()
  }
}

extension ManageShiftCardViewControllerTheme2: ManageShiftCardMainViewDelegate, ActivateCardViewDelegate {
  func cardTapped() {
    presenter.cardTapped()
  }

  func cardSettingsTapped() {
    presenter.cardSettingsTapped()
  }

  func balanceTapped() {
    presenter.balanceTapped()
  }

  func activateCardTapped() {
    presenter.activateCardTapped()
  }

  func needToUpdateUI(action: () -> Void, completion: @escaping () -> Void) {
    CATransaction.begin()
    CATransaction.setCompletionBlock {
      completion()
    }
    transactionsList.beginUpdates()
    action()
    transactionsList.endUpdates()
    CATransaction.commit()
  }

  @objc func activatePhysicalCardTapped() {
    presenter.activatePhysicalCardTapped()
  }

  func requestPhysicalActivationCode(completion: @escaping (_ code: String) -> Void) {
    UIAlertController.prompt(title: "manage.shift.card.enter-code.title".podLocalized(),
                             message: "manage.shift.card.enter-code.message".podLocalized(),
                             placeholder: "manage.shift.card.enter-code.placeholder".podLocalized(),
                             keyboardType: .numberPad,
                             okTitle: "manage.shift.card.enter-code.submit".podLocalized(),
                             cancelTitle: "general.button.cancel".podLocalized()) { code in
      guard let code = code, !code.isEmpty else { return }
      completion(code)
    }
  }
}

extension ManageShiftCardViewControllerTheme2: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return presenter.viewModel.transactions.numberOfSections + 1
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 0 {
      return presenter.viewModel.cardHolder.value == nil ? 0 : 1
    }
    return presenter.viewModel.transactions.numberOfItems(inSection: section - 1)
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if indexPath.section == 0 {
      return mainViewCellController.cell(tableView)
    }
    let path = IndexPath(item: indexPath.row, section: indexPath.section - 1)
    let viewModel = presenter.viewModel
    let transaction = viewModel.transactions[path]
    let controller = TransactionListCellControllerTheme2(transaction: transaction,
                                                         uiConfiguration: self.uiConfiguration)
    let cell = controller.cell(tableView)
    controller.isLastCellInSection = path.row == (viewModel.transactions.numberOfItems(inSection: path.section) - 1)
    return cell
  }
}

extension ManageShiftCardViewControllerTheme2: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if indexPath.section == 0 {
      return
    }
    let path = IndexPath(item: indexPath.row, section: indexPath.section - 1)
    presenter.transactionSelected(indexPath: path)
  }

  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    let headerViewSectionHeaderHeight: CGFloat = 0
    let transactionListSectionHeaderHeight: CGFloat = 36
    return section == 0 ? headerViewSectionHeaderHeight : transactionListSectionHeaderHeight
  }

  public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    guard section > 0 else {
      return nil
    }
    let containerView = UIView()
    containerView.backgroundColor = uiConfiguration.uiBackgroundSecondaryColor
    let contentView = SectionHeaderViewTheme2(text: presenter.viewModel.transactions.sections[section - 1].metadata,
                                              uiConfig: uiConfiguration)
    containerView.addSubview(contentView)
    contentView.snp.makeConstraints { make in
      make.top.bottom.equalToSuperview()
      make.left.right.equalToSuperview().inset(20)
    }
    return containerView
  }

  public func scrollViewDidScroll(_ scrollView: UIScrollView) {
    guard let navigationBar = navigationController?.navigationBar else { return }
    if scrollView.contentOffset.y < 8 {
      navigationBar.layer.shadowOpacity = 0
    }
    else {
      if navigationBar.layer.shadowOpacity < 1 {
        navigationBar.layer.shadowOpacity = 1
      }
    }
  }
}

// MARK: - Setup UI
private extension ManageShiftCardViewControllerTheme2 {
  func setUpUI() {
    view.backgroundColor = uiConfiguration.uiBackgroundSecondaryColor
    setUpNavigationBar()
    setUpBackgrounds()
    setUpTransactionList()
    createRefreshHeader()
    createRefreshFooter()
    setUpActivateCardView()
  }

  func setUpNavigationBar() {
    UIApplication.shared.keyWindow?.backgroundColor = uiConfiguration.uiNavigationSecondaryColor
    navigationController?.setNavigationBarHidden(false, animated: false)
    guard let navigationBar = navigationController?.navigationBar else { return }
    navigationBar.hideShadow()
    navigationBar.layer.shadowOffset = CGSize(width: 0, height: 2)
    navigationBar.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor
    navigationBar.layer.shadowOpacity = 0
    navigationBar.layer.shadowRadius = 8
    navigationBar.setUp(barTintColor: uiConfiguration.uiNavigationSecondaryColor,
                        tintColor: uiConfiguration.iconTertiaryColor)
    edgesForExtendedLayout = UIRectEdge()
    extendedLayoutIncludesOpaqueBars = true
    if mode == .standalone {
      hideNavBarBackButton()
    }
    else {
      showNavCancelButton(uiConfiguration.iconTertiaryColor, uiTheme: .theme2)
    }
    // swiftlint:disable:next force_unwrapping
    showNavNextButton(icon: UIImage.imageFromPodBundle("top_profile", uiTheme: .theme2)!,
                      tintColor: uiConfiguration.iconTertiaryColor)
    setNeedsStatusBarAppearanceUpdate()
  }

  func setUpBackgrounds() {
    topBackgroundView.backgroundColor = uiConfiguration.uiNavigationSecondaryColor
    view.addSubview(topBackgroundView)
    topBackgroundView.snp.makeConstraints { make in
      make.left.top.right.equalToSuperview()
      make.height.equalTo(180)
    }
    bottomBackgroundView.backgroundColor = uiConfiguration.uiNavigationSecondaryColor
    view.addSubview(bottomBackgroundView)
    bottomBackgroundView.snp.makeConstraints { make in
      make.left.bottom.right.equalToSuperview()
      make.top.equalTo(topBackgroundView.snp.bottom)
    }
  }

  func setUpTransactionList() {
    transactionsList.backgroundColor = .clear
    view.addSubview(transactionsList)
    transactionsList.snp.makeConstraints { make in
      make.left.right.top.bottom.equalTo(view)
    }
    transactionsList.separatorStyle = .none
    transactionsList.estimatedRowHeight = 72
    transactionsList.rowHeight = UITableViewAutomaticDimension
    transactionsList.dataSource = self
    transactionsList.delegate = self
    transactionsList.sectionFooterHeight = 0
  }

  func createRefreshHeader() {
    let header = DefaultRefreshHeader.header()
    header.imageRenderingWithTintColor = true
    header.tintColor = uiConfiguration.textTopBarColor.withAlphaComponent(0.7)
    header.textLabel.font = uiConfiguration.fontProvider.timestampFont
    transactionsList.configRefreshHeader(with: header, container: self) { [weak self] in
      self?.presenter.reloadTapped(showSpinner: false)
    }
  }

  func createRefreshFooter() {
    footer.tintColor = uiConfiguration.textTopBarColor.withAlphaComponent(0.7)
    footer.textLabel.font = uiConfiguration.fontProvider.timestampFont
    footer.textLabel.numberOfLines = 0
    footer.setText("manage.shift.card.refresh.title".podLocalized(), mode: .scrollAndTapToRefresh)
    footer.setText("manage.shift.card.refresh.loading".podLocalized(), mode: .refreshing)
    transactionsList.configRefreshFooter(with: footer, container: self) { [weak self] in
      self?.presenter.moreTransactionsTapped { noMoreTransactions in
        if noMoreTransactions {
          self?.transactionsList.switchRefreshFooter(to: .noMoreData)
        }
      }
    }
  }

  func setUpEmptyCaseView() {
    emptyCaseView.backgroundColor = .clear
    let label = ComponentCatalog.sectionTitleLabelWith(text: "manage.shift.card.no.transactions".podLocalized(),
                                                       textAlignment: .center,
                                                       uiConfig: uiConfiguration)
    label.textColor = uiConfiguration.textTertiaryColor
    label.numberOfLines = 0
    emptyCaseView.addSubview(label)
    label.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(16)
      make.centerY.equalToSuperview().offset(-16)
    }
    view.bringSubview(toFront: emptyCaseView)
  }

  func setUpActivateCardView() {
    activateCardView.delegate = self
    activateCardView.backgroundColor = uiConfiguration.uiBackgroundSecondaryColor
    activateCardView.isHidden = true
    view.addSubview(activateCardView)
    activateCardView.snp.makeConstraints { make in
      make.left.right.bottom.equalToSuperview()
    }
    view.bringSubview(toFront: activateCardView)
  }

  func updateNavigationBar(showActivateButton: Bool) {
    var items = navigationItem.rightBarButtonItems ?? []
    if showActivateButton {
      if !items.contains(activationButton) {
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
private extension ManageShiftCardViewControllerTheme2 {
  func setupViewModelSubscriptions() {
    let viewModel = presenter.viewModel

    combineLatest(viewModel.cardHolder, viewModel.cardLoaded).observeNext { [unowned self] cardHolder, cardLoaded in
      guard cardLoaded == true else { return }
      self.mainView.set(cardHolder: cardHolder)
      self.updateUI()
    }.dispose(in: disposeBag)

    viewModel.pan.observeNext { [unowned self] pan in
      self.mainView.set(cardNumber: pan)
    }.dispose(in: disposeBag)

    combineLatest(viewModel.lastFour, viewModel.cardLoaded).observeNext { [unowned self] lastFour, cardLoaded in
      guard cardLoaded == true else { return }
      self.mainView.set(lastFour: lastFour)
    }.dispose(in: disposeBag)

    viewModel.cvv.observeNext { [unowned self] cvv in
      self.mainView.set(cvv: cvv)
    }.dispose(in: disposeBag)

    combineLatest(viewModel.cardNetwork, viewModel.cardLoaded).observeNext { [unowned self] cardNetwork, cardLoaded in
      guard cardLoaded == true else { return }
      self.mainView.set(cardNetwork: cardNetwork)
    }.dispose(in: disposeBag)

    combineLatest(viewModel.expirationMonth,
                  viewModel.expirationYear).observeNext { [unowned self] expirationMonth, expirationYear in
      if let expirationMonth = expirationMonth, let expirationYear = expirationYear {
        self.mainView.set(expirationMonth: expirationMonth, expirationYear: expirationYear)
      }
    }.dispose(in: disposeBag)

    combineLatest(viewModel.fundingSource,
                  viewModel.cardLoaded).observeNext { [unowned self] fundingSource, cardLoaded in
      guard cardLoaded == true else { return }
      self.mainView.set(fundingSource: fundingSource)
    }.dispose(in: disposeBag)

    combineLatest(viewModel.orderedStatus,
                  viewModel.cardLoaded).observeNext { [unowned self] orderedStatus, cardLoaded in
      guard cardLoaded == true else { return }
      let activationNeeded: Bool = orderedStatus == .ordered
      self.mainView.set(physicalCardActivationRequired: activationNeeded,
                        showMessage: viewModel.showPhysicalCardActivationMessage.value)
      self.updateNavigationBar(showActivateButton: activationNeeded)
    }.dispose(in: disposeBag)

    combineLatest(viewModel.spendableToday,
                  viewModel.nativeSpendableToday,
                  viewModel.cardLoaded).observeNext { [unowned self] spendableToday, nativeSpendableToday, cardLoaded in
      guard cardLoaded == true else { return }
      self.mainView.setSpendable(amount: spendableToday, nativeAmount: nativeSpendableToday)
    }.dispose(in: disposeBag)

    combineLatest(viewModel.state, viewModel.cardLoaded).observeNext { [unowned self] state, cardLoaded in
      guard cardLoaded == true else { return }
      self.mainView.set(cardState: state)
      self.updateUI()
    }.dispose(in: disposeBag)

    combineLatest(viewModel.isActivateCardFeatureEnabled,
                  viewModel.cardLoaded).observeNext { [unowned self] shouldShowActivation, cardLoaded in
      guard cardLoaded == true else { return }
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

    combineLatest(viewModel.cardStyle, viewModel.cardLoaded).observeNext { [unowned self] cardStyle, cardLoaded in
      guard cardLoaded == true else { return }
      self.mainView.set(cardStyle: cardStyle)
    }.dispose(in: disposeBag)
  }

  func updateUI() {
    let viewModel = presenter.viewModel
    transactionsList.reloadData()
    activateCardView.isHidden = shouldShowActivation == true ? viewModel.state.value != .created : true
    footer.isHidden = viewModel.transactions.isEmpty
    // Only show the empty case if we are all set
    if viewModel.transactionsLoaded.value == true {
      let shouldShowEmptyCase = viewModel.transactions.isEmpty
      emptyCaseView.isHidden = !shouldShowEmptyCase
      if shouldShowEmptyCase {
        showEmptyCase()
      }
      else {
        bottomBackgroundView.backgroundColor = uiConfiguration.uiNavigationSecondaryColor
      }
    }
  }

  func showEmptyCase() {
    bottomBackgroundView.backgroundColor = uiConfiguration.uiBackgroundSecondaryColor
    emptyCaseView.removeFromSuperview()
    emptyCaseView.snp.removeConstraints()
    view.addSubview(emptyCaseView)
    emptyCaseView.snp.makeConstraints { make in
      let topConstraint = transactionsList.visibleCells.last?.snp.bottom ?? view.snp.top
      make.top.equalTo(topConstraint)
      make.left.right.bottom.equalToSuperview()
    }
    setUpEmptyCaseView()
  }

  func buildActivatePhysicalCardButtonItem() -> UIBarButtonItem {
    let topBarButtonItem = TopBarButtonItem(
      uiConfig: uiConfiguration,
      text: "manage_card.activate_physical_card.top_bar_item.title".podLocalized(),
      icon: UIImage.imageFromPodBundle("activate_physical_card", uiTheme: .theme2)) {
        self.activatePhysicalCardTapped()
    }
    return topBarButtonItem
  }
}
