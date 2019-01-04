//
//  ManageShiftCardPresenter.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 24/10/2017.
//
//

import Foundation
import Bond

class ManageShiftCardPresenter: ManageShiftCardPresenterProtocol {
  // swiftlint:disable implicitly_unwrapped_optional
  var view: ManageShiftCardViewProtocol!
  var interactor: ManageShiftCardInteractorProtocol!
  weak var router: ManageShiftCardRouterProtocol!
  // swiftlint:enable implicitly_unwrapped_optional
  let viewModel: ManageShiftCardViewModel
  private let rowsPerPage = 20
  private var lastTransactionId: String?
  private let config: ManageShiftCardPresenterConfig
  private var cardInfoRetrieved = false
  private var transactionsInfoRetrieved = false
  private var remoteInfoRetrieved: Bool {
    return cardInfoRetrieved && transactionsInfoRetrieved
  }

  init(config: ManageShiftCardPresenterConfig) {
    self.config = config
    self.viewModel = ManageShiftCardViewModel()
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(backgroundRefresh),
                                           name: NSNotification.Name.UIApplicationDidBecomeActive,
                                           object: nil)
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  func viewLoaded() {
    interactor.provideFundingSource(forceRefresh: false) { [weak self] result in
      switch result {
      case .failure(let error):
        self?.view.show(error: error)
      case .success(let card):
        if let wself = self {
          wself.updateViewModelWith(card: card)
          wself.refreshTransactions(forceRefresh: false) { [weak self] _ in
            self?.backgroundRefresh()
          }
        }
      }
    }
  }

  func previousTapped() {
    router.backFromManageShiftCardViewer()
  }

  func closeTapped() {
    router.closeFromManageShiftCardViewer()
  }

  func nextTapped() {
    router.accountSettingsTappedInManageShiftCardViewer()
  }

  func cardTapped() {
    // Disable card settings if the card is pending activation
    guard viewModel.state.value != .created else { return }
    if viewModel.fundingSource.value?.state == .invalid {
      router.balanceTappedInManageShiftCardViewer()
    }
    else {
      router.cardSettingsTappedInManageShiftCardViewer()
    }
  }

  func cardSettingsTapped() {
    // Disable card settings if the card is pending activation
    guard viewModel.state.value != .created else { return }
    router.cardSettingsTappedInManageShiftCardViewer()
  }

  func balanceTapped() {
    router.balanceTappedInManageShiftCardViewer()
  }

  func transactionSelected(indexPath: IndexPath) {
    router.showTransactionDetails(transaction: viewModel.transactions.item(at: indexPath))
  }

  func activateCardTapped() {
    view.showLoadingSpinner()
    interactor.activateCard { [unowned self] result in
      self.view.hideLoadingSpinner()
      switch result {
      case .failure(let error):
        self.view.show(error: error)
      case .success:
        self.viewModel.state.next(.active)
      }
    }
  }

  func refreshCard() {
    view.showLoadingSpinner()
    refreshCard { [unowned self] in
      self.view.hideLoadingSpinner()
    }
  }

  func showCardInfo() {
    view.showLoadingSpinner()
    interactor.loadCardInfo { [weak self] result in
      self?.view.hideLoadingSpinner()
      switch result {
      case .failure(let error):
        self?.view.show(error: error)
      case .success(let cardDetails):
        if let wself = self {
          wself.updateViewModelWith(cardDetails: cardDetails)
          wself.viewModel.cardInfoVisible.next(true)
        }
      }
    }
  }

  func hideCardInfo() {
    viewModel.cardInfoVisible.next(false)
  }

  func reloadTapped(showSpinner: Bool) {
    refreshInfo(showSpinner: showSpinner)
  }

  func moreTransactionsTapped(completion: @escaping (_ noMoreTransactions: Bool) -> Void) {
    guard remoteInfoRetrieved else { return completion(true) }
    getMoreTransactions(forceRefresh: true) { transactionsLoaded in
      completion(transactionsLoaded == 0)
    }
  }

  func activatePhysicalCardTapped() {
    view.requestPhysicalActivationCode(completion: activatePhysicalCard)
  }

  // MARK: - Private methods

  @objc private func backgroundRefresh() {
    refreshCard { [weak self] in
      self?.cardInfoRetrieved = true
    }
    lastTransactionId = nil
    refreshTransactions { [weak self] _ in
      self?.transactionsInfoRetrieved = true
    }
    interactor.loadFundingSources { _ in }
  }

  fileprivate func refreshInfo(showSpinner: Bool = true, completion: (() -> Void)? = nil) {
    if showSpinner {
      view.showLoadingSpinner()
    }
    refreshCard { [unowned self] in
      self.refreshTransactions { [unowned self] _ in
        if showSpinner {
          self.view.hideLoadingSpinner()
        }
        completion?()
      }
    }
  }

  fileprivate func refreshCard(completion: @escaping () -> Void) {
    interactor.reloadCard { [weak self] result in
      switch result {
      case .failure(let error):
        self?.view.show(error: error)
        completion()
      case .success(let card):
        if let wself = self {
          wself.updateViewModelWith(card: card)
          completion()
        }
      }
    }
  }

  private func updateViewModelWith(card: Card) {
    router.update(card: card)
    viewModel.cardHolder.next(card.cardHolder)
    viewModel.lastFour.next(card.lastFourDigits)
    viewModel.cardNetwork.next(card.cardNetwork)
    viewModel.fundingSource.next(card.fundingSource)
    if card.orderedStatus == .ordered && card.orderedStatus != viewModel.orderedStatus.value {
      viewModel.showPhysicalCardActivationMessage.next(true)
    }
    else {
      viewModel.showPhysicalCardActivationMessage.next(false)
    }
    viewModel.orderedStatus.next(card.orderedStatus)
    viewModel.spendableToday.next(card.spendableToday)
    viewModel.nativeSpendableToday.next(card.nativeSpendableToday)
    viewModel.cardStyle.next(card.cardStyle)
    if let imageUrl = config.imageUrl, let url = URL(string: imageUrl) {
      ImageCache.defaultCache().imageWithUrl(url) { result in
        if case let .success(image) = result {
          self.viewModel.custodianLogo.next(image)
        }
      }
      viewModel.custodianName.next(config.name)
    }
    else {
      if let custodianWallet = card.fundingSource as? CustodianWallet {
        viewModel.custodianLogo.next(custodianWallet.custodian.custodianLogo())
        viewModel.custodianName.next(custodianWallet.custodian.name)
      }
      else {
        viewModel.custodianLogo.next(nil)
        viewModel.custodianName.next(nil)
      }
    }
    viewModel.state.next(card.state)
    if let showActivateCardButton = config.showActivateCardButton {
      viewModel.isActivateCardFeatureEnabled.next(showActivateCardButton)
    }
    else {
      viewModel.isActivateCardFeatureEnabled.next(false)
    }
    if viewModel.cardLoaded.value == false {
      viewModel.cardLoaded.next(true)
    }
  }

  private func updateViewModelWith(cardDetails: CardDetails) {
    viewModel.pan.next(cardDetails.pan)
    viewModel.cvv.next(cardDetails.cvv)
    let expirationComponents = cardDetails.expiration.split(separator: "-")
    if var year = UInt(expirationComponents[0]), let month = UInt(expirationComponents[1]) {
      if year > 99 { year = year - 2000 }
      viewModel.expirationMonth.next(month)
      viewModel.expirationYear.next(year)
    }
  }

  fileprivate func refreshTransactions(forceRefresh: Bool = true,
                                       completion: @escaping (_ transactionsLoaded: Int) -> Void) {
    viewModel.transactionsLoaded.next(false)
    lastTransactionId = nil
    getMoreTransactions(forceRefresh: forceRefresh, clearCurrent: true, completion: completion)
  }

  fileprivate func getMoreTransactions(forceRefresh: Bool,
                                       clearCurrent: Bool = false,
                                       completion: @escaping (_ transactionsLoaded: Int) -> Void) {
    interactor.provideTransactions(rows: rowsPerPage,
                                   lastTransactionId: lastTransactionId,
                                   forceRefresh: forceRefresh) { [weak self] result in
      if self?.viewModel.transactionsLoaded.value == false {
        self?.viewModel.transactionsLoaded.next(true)
      }
      switch result {
      case .failure(let error):
        self?.view.show(error: error)
        completion(0)
      case .success(let transactions):
        if clearCurrent {
          self?.viewModel.transactions.removeAllItemsAndSections()
        }
        self?.process(newTransactions: transactions)
        completion(transactions.count)
      }
    }
  }

  private func process(newTransactions transactions: [Transaction]) {
    if let lastTransaction = transactions.last {
      self.lastTransactionId = lastTransaction.transactionId
    }
    else {
      return
    }
    var transactions = transactions
    let mostRecentItemsCount = min(3, transactions.count)
    if viewModel.transactions.numberOfSections == 0 {
      let mostRecentSectionTitle = "manage.shift.card.most-recents".podLocalized()
      let section = Observable2DArraySection<String, Transaction>(metadata: mostRecentSectionTitle, items: [])
      viewModel.transactions.appendSection(section)
      for _ in 0..<mostRecentItemsCount {
        viewModel.transactions.appendItem(transactions.removeFirst(), toSection: 0)
      }
    }
    else if viewModel.transactions.numberOfItems(inSection: 0) < mostRecentItemsCount {
      let missingRecentElements = mostRecentItemsCount - viewModel.transactions.numberOfItems(inSection: 0)
      let endIndex = min(transactions.count, missingRecentElements)
      for _ in 0..<endIndex {
        viewModel.transactions.appendItem(transactions.removeFirst(), toSection: 0)
      }
    }
    var sections = viewModel.transactions.sections.map { return $0.metadata }
    transactions.forEach { transaction in
      append(transaction: transaction, to: &sections)
    }
  }

  private var firstTransactionMonthPerYear = [Int: Int]()

  private func append(transaction: Transaction, to sections: inout [String]) {
    let transactionYear = transaction.createdAt.year
    let transactionMonth = transaction.createdAt.month
    if firstTransactionMonthPerYear[transactionYear] == nil {
      firstTransactionMonthPerYear[transactionYear] = transactionMonth
    }
    let isFirstMonthOfTheYearWithTransaction = firstTransactionMonthPerYear[transactionYear] == transactionMonth
    let sectionName = section(for: transaction, includeYearNumber: isFirstMonthOfTheYearWithTransaction)
    if let indexOfSection = sections.index(of: sectionName) {
      viewModel.transactions.appendItem(transaction, toSection: indexOfSection)
    }
    else {
      sections.append(sectionName)
      let section = Observable2DArraySection<String, Transaction>(metadata: sectionName, items: [transaction])
      viewModel.transactions.appendSection(section)
    }
  }

  private func section(for transaction: Transaction, includeYearNumber: Bool) -> String {
    let formatter = includeYearNumber ? yearDateFormatter : dateFormatter
    return formatter.string(from: transaction.createdAt)
  }

  private lazy var dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMMM"
    return formatter
  }()

  private lazy var yearDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMMM, yyyy"
    return formatter
  }()

  private func activatePhysicalCard(_ code: String) {
    view.showLoadingSpinner()
    interactor.activatePhysicalCard(code: code) { [unowned self] result in
      self.view.hideLoadingSpinner()
      switch result {
      case .failure(let error):
        self.view.show(error: error)
      case .success:
        self.router.physicalActivationSucceed()
      }
    }
  }
}
