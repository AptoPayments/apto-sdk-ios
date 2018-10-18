//
//  ManageShiftCardPresenter.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 24/10/2017.
//
//

import Foundation
import Stripe
import Bond

protocol ManageShiftCardRouterProtocol: class {
  func update(card newCard: Card)
  func backFromManageShiftCardViewer()
  func closeFromManageShiftCardViewer()
  func accountSettingsTappedInManageShiftCardViewer()
  func cardSettingsTappedInManageShiftCardViewer()
  func showTransactionDetails(transaction: Transaction)
}

protocol ManageShiftCardViewProtocol: ViewControllerProtocol {
  func showLoadingSpinner()
}

protocol ManageShiftCardInteractorProtocol {
  func provideCard(_ callback: @escaping Result<Card, NSError>.Callback)
  func activateCard(_ callback: @escaping Result<Card, NSError>.Callback)
  func provideTransactions(rows: Int,
                           lastTransactionId: String?,
                           callback: @escaping Result<[Transaction], NSError>.Callback)
}

open class ManageShiftCardViewModel {
  open var state: Observable<FinancialAccountState?> = Observable(nil)
  open var isActivateCardFeatureEnabled: Observable<Bool?> = Observable(nil)
  open var cardInfoVisible: Observable<Bool?> = Observable(false)
  open var pan: Observable<String?> = Observable(nil)
  open var cvv: Observable<String?> = Observable(nil)
  open var cardHolder: Observable<String?> = Observable(nil)
  open var expirationMonth: Observable<UInt?> = Observable(nil)
  open var expirationYear: Observable<UInt?> = Observable(nil)
  open var lastFour: Observable<String?> = Observable(nil)
  open var cardNetwork: Observable<CardNetwork?> = Observable(nil)
  open var fundingSource: Observable<FundingSource?> = Observable(nil)
  open var spendableToday: Observable<Amount?> = Observable(nil)
  open var nativeSpendableToday: Observable<Amount?> = Observable(nil)
  open var custodianLogo: Observable<UIImage?> = Observable(nil)
  open var custodianName: Observable<String?> = Observable(nil)
  open var transactions: MutableObservable2DArray<String, Transaction> = MutableObservable2DArray([])
}

struct ManageShiftCardPresenterConfig {
  let name: String?
  let imageUrl: String?
  let showActivateCardButton: Bool?
}

class ManageShiftCardPresenter: ManageShiftCardEventHandler {
  // swiftlint:disable implicitly_unwrapped_optional
  var view: ManageShiftCardViewProtocol!
  var interactor: ManageShiftCardInteractorProtocol!
  weak var router: ManageShiftCardRouterProtocol!
  // swiftlint:enable implicitly_unwrapped_optional
  let viewModel: ManageShiftCardViewModel
  private let rowsPerPage = 20
  private var lastTransactionId: String?
  private let config: ManageShiftCardPresenterConfig

  init(config: ManageShiftCardPresenterConfig) {
    self.config = config
    self.viewModel = ManageShiftCardViewModel()
  }

  func viewLoaded() {
    refreshInfo()
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
    router.cardSettingsTappedInManageShiftCardViewer()
  }

  func transactionSelected(indexPath: IndexPath) {
    router.showTransactionDetails(transaction: viewModel.transactions.item(at: indexPath))
  }

  func activateCardTapped() {
    view.showLoadingSpinner()
    interactor.activateCard { result in
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
    refreshCard {
      self.view.hideLoadingSpinner()
    }
  }

  func reloadTapped() {
    refreshInfo()
  }

  func moreTransactionsTapped(completion: @escaping (_ noMoreTransactions: Bool) -> Void) {
    getMoreTransactions { transactionsLoaded in
      completion(transactionsLoaded == 0)
    }
  }

  fileprivate func refreshInfo() {
    view.showLoadingSpinner()
    refreshCard {
      self.refreshTransactions { _ in
        self.view.hideLoadingSpinner()
      }
    }
  }

  fileprivate func refreshCard(completion: @escaping () -> Void) {
    interactor.provideCard { [weak self] result in
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
    viewModel.pan.next(card.pan)
    viewModel.cvv.next(card.cvv)
    viewModel.cardHolder.next(card.cardHolder)
    let expiration = card.expiration.split(separator: "-")
    if var year = UInt(expiration[0]), let month = UInt(expiration[1]) {
      if year > 99 { year = year - 2000 }
      viewModel.expirationMonth.next(month)
      viewModel.expirationYear.next(year)
    }
    viewModel.lastFour.next(card.lastFourDigits)
    viewModel.cardNetwork.next(card.cardNetwork)
    viewModel.fundingSource.next(card.fundingSource)
    viewModel.spendableToday.next(card.spendableToday)
    viewModel.nativeSpendableToday.next(card.nativeSpendableToday)
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
  }

  fileprivate func refreshTransactions(completion: @escaping (_ transactionsLoaded: Int) -> Void) {
    viewModel.transactions.removeAllItemsAndSections()
    lastTransactionId = nil
    getMoreTransactions(completion: completion)
  }

  fileprivate func getMoreTransactions(completion: @escaping (_ transactionsLoaded: Int) -> Void) {
    interactor.provideTransactions(rows: rowsPerPage, lastTransactionId: lastTransactionId) { [weak self] result in
      switch result {
      case .failure(let error):
        self?.view.show(error: error)
        completion(0)
      case .success(let transactions):
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
}
