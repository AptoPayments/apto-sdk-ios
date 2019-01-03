//
// ManageShiftCardContract.swift
// ShiftSDK
//
// Created by Takeichi Kanzaki on 23/11/2018.
//

import Bond

protocol ManageShiftCardRouterProtocol: class {
  func update(card newCard: Card)
  func backFromManageShiftCardViewer()
  func closeFromManageShiftCardViewer()
  func accountSettingsTappedInManageShiftCardViewer()
  func cardSettingsTappedInManageShiftCardViewer()
  func balanceTappedInManageShiftCardViewer()
  func showTransactionDetails(transaction: Transaction)
  func physicalActivationSucceed()
}

protocol ManageShiftCardViewProtocol: ViewControllerProtocol {
  func showLoadingSpinner()
  func show(error: Error)
  func requestPhysicalActivationCode(completion: @escaping (_ code: String) -> Void)
}

typealias ManageShiftCardViewControllerProtocol = ShiftViewController & ManageShiftCardViewProtocol

protocol ManageShiftCardInteractorProtocol {
  func provideFundingSource(forceRefresh: Bool, callback: @escaping Result<Card, NSError>.Callback)
  func reloadCard(_ callback: @escaping Result<Card, NSError>.Callback)
  func loadCardInfo(_ callback: @escaping Result<CardDetails, NSError>.Callback)
  func activateCard(_ callback: @escaping Result<Card, NSError>.Callback)
  func provideTransactions(rows: Int,
                           lastTransactionId: String?,
                           forceRefresh: Bool,
                           callback: @escaping Result<[Transaction], NSError>.Callback)
  func activatePhysicalCard(code: String, callback: @escaping Result<Void, NSError>.Callback)
  func loadFundingSources(callback: @escaping Result<[FundingSource], NSError>.Callback)
}

protocol ManageShiftCardEventHandler: class {
  var viewModel: ManageShiftCardViewModel { get }
  func viewLoaded()
  func previousTapped()
  func closeTapped()
  func nextTapped()
  func cardTapped()
  func cardSettingsTapped()
  func balanceTapped()
  func activateCardTapped()
  func refreshCard()
  func showCardInfo()
  func hideCardInfo()
  func reloadTapped(showSpinner: Bool)
  func moreTransactionsTapped(completion: @escaping (_ noMoreTransactions: Bool) -> Void)
  func transactionSelected(indexPath: IndexPath)
  func activatePhysicalCardTapped()
}

open class ManageShiftCardViewModel {
  public let state: Observable<FinancialAccountState?> = Observable(nil)
  public let isActivateCardFeatureEnabled: Observable<Bool?> = Observable(nil)
  public let cardInfoVisible: Observable<Bool?> = Observable(false)
  public let pan: Observable<String?> = Observable(nil)
  public let cvv: Observable<String?> = Observable(nil)
  public let cardHolder: Observable<String?> = Observable(nil)
  public let expirationMonth: Observable<UInt?> = Observable(nil)
  public let expirationYear: Observable<UInt?> = Observable(nil)
  public let lastFour: Observable<String?> = Observable(nil)
  public let cardNetwork: Observable<CardNetwork?> = Observable(nil)
  public let orderedStatus: Observable<OrderedStatus> = Observable(.received)
  public let fundingSource: Observable<FundingSource?> = Observable(nil)
  public let spendableToday: Observable<Amount?> = Observable(nil)
  public let nativeSpendableToday: Observable<Amount?> = Observable(nil)
  public let custodianLogo: Observable<UIImage?> = Observable(nil)
  public let custodianName: Observable<String?> = Observable(nil)
  public let transactions: MutableObservable2DArray<String, Transaction> = MutableObservable2DArray([])
  public let transactionsLoaded: Observable<Bool> = Observable(false)
  public let cardStyle: Observable<CardStyle?> = Observable(nil)
  public let cardLoaded: Observable<Bool> = Observable(false)
}

protocol ManageShiftCardPresenterProtocol: ManageShiftCardEventHandler {
  // swiftlint:disable implicitly_unwrapped_optional
  var view: ManageShiftCardViewProtocol! { get set }
  var interactor: ManageShiftCardInteractorProtocol! { get set }
  var router: ManageShiftCardRouterProtocol! { get set }
  // swiftlint:enable implicitly_unwrapped_optional
  var viewModel: ManageShiftCardViewModel { get }
}

struct ManageShiftCardPresenterConfig {
  let name: String?
  let imageUrl: String?
  let showActivateCardButton: Bool?
}
