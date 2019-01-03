//
// ManageShiftCardTestDoubles.swift
// ShiftSDK
//
// Created by Takeichi Kanzaki on 23/11/2018.
//

@testable import ShiftSDK

class ManageShiftCardModuleSpy: UIModuleSpy, ManageShiftCardRouterProtocol {
  private(set) var updateCardCalled = false
  private(set) var lastCardUpdated: Card?
  func update(card newCard: Card) {
    updateCardCalled = true
    lastCardUpdated = newCard
  }

  private(set) var backFromManageShiftCardViewerCalled = false
  func backFromManageShiftCardViewer() {
    backFromManageShiftCardViewerCalled = true
  }

  private(set) var closeFromManageShiftCardViewerCalled = false
  func closeFromManageShiftCardViewer() {
    closeFromManageShiftCardViewerCalled = true
  }

  private(set) var accountSettingsTappedInManageShiftCardViewerCalled = false
  func accountSettingsTappedInManageShiftCardViewer() {
    accountSettingsTappedInManageShiftCardViewerCalled = true
  }

  private(set) var cardSettingsTappedInManageShiftCardViewerCalled = false
  func cardSettingsTappedInManageShiftCardViewer() {
    cardSettingsTappedInManageShiftCardViewerCalled = true
  }

  private(set) var balanceTappedInManageShiftCardViewerCalled = false
  func balanceTappedInManageShiftCardViewer() {
    balanceTappedInManageShiftCardViewerCalled = true
  }

  private(set) var showTransactionDetailsCalled = false
  private(set) var lastTransactionShown: Transaction?
  func showTransactionDetails(transaction: Transaction) {
    showTransactionDetailsCalled = true
    lastTransactionShown = transaction
  }

  private(set) var physicalActivationSucceedCalled = false
  func physicalActivationSucceed() {
    physicalActivationSucceedCalled = true
  }
}

class ManageShiftCardInteractorSpy: ManageShiftCardInteractorProtocol {
  private(set) var provideFundingSourceCalled = false
  private(set) var lastProvideFundingSourceForceRefresh: Bool?
  func provideFundingSource(forceRefresh: Bool, callback: @escaping Result<Card, NSError>.Callback) {
    provideFundingSourceCalled = true
    lastProvideFundingSourceForceRefresh = forceRefresh
  }

  private(set) var reloadCardCalled = false
  func reloadCard(_ callback: @escaping Result<Card, NSError>.Callback) {
    reloadCardCalled = true
  }

  private(set) var loadCardInfoCalled = false
  func loadCardInfo(_ callback: @escaping Result<CardDetails, NSError>.Callback) {
    loadCardInfoCalled = true
  }

  private(set) var activateCardCalled = false
  func activateCard(_ callback: @escaping Result<Card, NSError>.Callback) {
    activateCardCalled = true
  }

  private(set) var provideTransactionsCalled = false
  private(set) var lastNumberOfRows: Int?
  private(set) var lastTransactionId: String?
  private(set) var lastProvideTransactionForceRefresh: Bool?
  func provideTransactions(rows: Int,
                           lastTransactionId: String?,
                           forceRefresh: Bool,
                           callback: @escaping Result<[Transaction], NSError>.Callback) {
    provideTransactionsCalled = true
    lastNumberOfRows = rows
    self.lastTransactionId = lastTransactionId
    lastProvideTransactionForceRefresh = forceRefresh
  }

  private(set) var activatePhysicalCardCalled = false
  private(set) var lastPhysicalCardActivationCode: String?
  func activatePhysicalCard(code: String, callback: @escaping Result<Void, NSError>.Callback) {
    activatePhysicalCardCalled = true
    lastPhysicalCardActivationCode = code
  }

  private(set) var loadFundingSourcesCalled = false
  func loadFundingSources(callback: @escaping Result<[FundingSource], NSError>.Callback) {
    loadFundingSourcesCalled = true
  }
}

class ManageShiftCardInteractorFake: ManageShiftCardInteractorSpy {
  var nextProvideFundingSourceResult: Result<Card, NSError>?
  override func provideFundingSource(forceRefresh: Bool, callback: @escaping Result<Card, NSError>.Callback) {
    super.provideFundingSource(forceRefresh: forceRefresh, callback: callback)

    if let result = nextProvideFundingSourceResult {
      callback(result)
    }
  }

  var nextReloadCardResult: Result<Card, NSError>?
  override func reloadCard(_ callback: @escaping Result<Card, NSError>.Callback) {
    super.reloadCard(callback)

    if let result = nextReloadCardResult {
      callback(result)
    }
  }

  var nextLoadCardInfoResult: Result<CardDetails, NSError>?
  override func loadCardInfo(_ callback: @escaping Result<CardDetails, NSError>.Callback) {
    super.loadCardInfo(callback)

    if let result = nextLoadCardInfoResult {
      callback(result)
    }
  }

  var nextActivateCardResult: Result<Card, NSError>?
  override func activateCard(_ callback: @escaping Result<Card, NSError>.Callback) {
    super.activateCard(callback)

    if let result = nextActivateCardResult {
      callback(result)
    }
  }

  var nextProvideTransactionsResult: Result<[Transaction], NSError>?
  override func provideTransactions(rows: Int,
                                    lastTransactionId: String?,
                                    forceRefresh: Bool,
                                    callback: @escaping Result<[Transaction], NSError>.Callback) {
    super.provideTransactions(rows: rows,
                              lastTransactionId: lastTransactionId,
                              forceRefresh: forceRefresh,
                              callback: callback)

    if let result = nextProvideTransactionsResult {
      callback(result)
    }
  }

  var nextActivatePhysicalCardResult: Result<Void, NSError>?
  override func activatePhysicalCard(code: String, callback: @escaping Result<Void, NSError>.Callback) {
    super.activatePhysicalCard(code: code, callback: callback)

    if let result = nextActivatePhysicalCardResult {
      callback(result)
    }
  }

  var nextLoadFundingSourcesResult: Result<[FundingSource], NSError>?
  override func loadFundingSources(callback: @escaping Result<[FundingSource], NSError>.Callback) {
    super.loadFundingSources(callback: callback)

    if let result = nextLoadFundingSourcesResult {
      callback(result)
    }
  }
}

class ManageShiftCardPresenterSpy: ManageShiftCardPresenterProtocol {
  // swiftlint:disable implicitly_unwrapped_optional
  var view: ManageShiftCardViewProtocol!
  var interactor: ManageShiftCardInteractorProtocol!
  var router: ManageShiftCardRouterProtocol!
  // swiftlint:enable implicitly_unwrapped_optional
  let viewModel = ManageShiftCardViewModel()

  private(set) var viewLoadedCalled = false
  func viewLoaded() {
    viewLoadedCalled = true
  }

  private(set) var previousTappedCalled = false
  func previousTapped() {
    previousTappedCalled = true
  }

  private(set) var closeTappedCalled = false
  func closeTapped() {
    closeTappedCalled = true
  }

  private(set) var nextTappedCalled = false
  func nextTapped() {
    nextTappedCalled = true
  }

  private(set) var cardTappedCalled = false
  func cardTapped() {
    cardTappedCalled = true
  }

  private(set) var cardSettingsTappedCalled = false
  func cardSettingsTapped() {
    cardSettingsTappedCalled = true
  }

  private(set) var balanceTappedCalled = false
  func balanceTapped() {
    balanceTappedCalled = true
  }

  private(set) var activateCardTappedCalled = false
  func activateCardTapped() {
    activateCardTappedCalled = true
  }

  private(set) var refreshCardCalled = false
  func refreshCard() {
    refreshCardCalled = true
  }

  private(set) var showCardInfoCalled = false
  func showCardInfo() {
    showCardInfoCalled = true
  }

  private(set) var hideCardInfoCalled = false
  func hideCardInfo() {
    hideCardInfoCalled = true
  }

  private(set) var reloadTappedCalled = false
  private(set) var lastShowSpinnerWhileReloading: Bool?
  func reloadTapped(showSpinner: Bool) {
    reloadTappedCalled = true
    lastShowSpinnerWhileReloading = showSpinner
  }

  private(set) var moreTransactionsTappedCalled = false
  func moreTransactionsTapped(completion: @escaping (Bool) -> Void) {
    moreTransactionsTappedCalled = true
  }

  private(set) var transactionSelectedCalled = false
  private(set) var lastTransactionSelectedIndexPath: IndexPath?
  func transactionSelected(indexPath: IndexPath) {
    transactionSelectedCalled = true
    lastTransactionSelectedIndexPath = indexPath
  }

  private(set) var activatePhysicalCardTappedCalled = false
  func activatePhysicalCardTapped() {
    activatePhysicalCardTappedCalled = true
  }
}

class ManageShiftCardViewSpy: ViewControllerSpy, ManageShiftCardViewProtocol {
  func show(error: Error) {
    show(error: error, uiConfig: ModelDataProvider.provider.uiConfig)
  }

  private(set) var requestPhysicalActivationCodeCalled = false
  func requestPhysicalActivationCode(completion: @escaping (_ code: String) -> Void) {
    requestPhysicalActivationCodeCalled = true
  }
}

class ManageShiftCardViewFake: ManageShiftCardViewSpy {
  var nextPhysicalCardActivationCode: String?
  override func requestPhysicalActivationCode(completion: @escaping (_ code: String) -> Void) {
    super.requestPhysicalActivationCode(completion: completion)

    if let code = nextPhysicalCardActivationCode {
      completion(code)
    }
  }
}
