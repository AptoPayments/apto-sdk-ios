//
//  ShiftCardTransactionDetailsPresenter.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 25/03/2018.
//
//

import Foundation
import Stripe
import Bond

open class ShiftCardTransactionDetailsViewModel {
  open var title: Observable<String?> = Observable("transation.details.title".podLocalized())
  open var topViewIcon: Observable<UIImage?> = Observable(nil)
  open var topViewAmount: Observable<String?> = Observable(nil)
  open var topViewDescription: Observable<String?> = Observable(nil)
  open var externalId: Observable<String?> = Observable(nil)
  open var state: Observable<String?> = Observable(nil)
  open var type: Observable<String?> = Observable(nil)
  open var transactionDate: Observable<Date?> = Observable(nil)
  open var settlementDate: Observable<Date?> = Observable(nil)
  open var transactionAmount: Observable<String?> = Observable(nil)
  open var currency: Observable<String?> = Observable(nil)
  open var holdAmount: Observable<String?> = Observable(nil)
  open var withdrawnAmount: Observable<String?> = Observable(nil)
  open var declinedAmount: Observable<String?> = Observable(nil)
  open var declineReason: Observable<String?> = Observable(nil)
  open var cashbackAmount: Observable<String?> = Observable(nil)
  open var exchangeRate: Observable<String?> = Observable(nil)
  open var location: Observable<String?> = Observable(nil)
  open var category: Observable<String?> = Observable(nil)
  open var merchantFee: Observable<String?> = Observable(nil)
  open var shiftAtmFee: Observable<String?> = Observable(nil)
  open var shiftIntAtmFee: Observable<String?> = Observable(nil)
  open var shiftIntFee: Observable<String?> = Observable(nil)
  open var shiftId: Observable<String?> = Observable(nil)
  open var fundingSourceId: Observable<String?> = Observable(nil)
  open var transactionType: Observable<TransactionType?> = Observable(nil)
  open var adjustments: MutableObservableArray<TransactionAdjustment> = MutableObservableArray([])
  open var latitude: Observable<Double?> = Observable(nil)
  open var longitude: Observable<Double?> = Observable(nil)
  open var mccIcon: Observable<MCCIcon?> = Observable(nil)
}

class ShiftCardTransactionDetailsPresenter: ShiftCardTransactionDetailsPresenterProtocol {

  weak var view: ShiftCardTransactionDetailsViewProtocol?
  var interactor: ShiftCardTransactionDetailsInteractorProtocol?
  var router: ShiftCardTransactionDetailsRouterProtocol?
  var viewModel: ShiftCardTransactionDetailsViewModel
  let rowsPerPage = 20

  init() {
    self.viewModel = ShiftCardTransactionDetailsViewModel()
  }

  func viewLoaded() {
    refreshData()
  }

  fileprivate func refreshData() {
    view?.showLoadingSpinner()
    interactor?.provideTransaction { result in
      switch result {
      case .failure(let error):
        self.view?.show(error: error)
      case .success(let transaction):
        self.viewModel.topViewIcon.next(transaction.merchant?.mcc?.iconTemplate())
        self.viewModel.topViewDescription.next(transaction.transactionDescription?.capitalized)
        self.viewModel.transactionType.next(transaction.transactionType)
        if transaction.transactionType == .decline {
          self.viewModel.topViewAmount.next("transaction-details.declined.text".podLocalized())
        }
        else if transaction.transactionType == .pending {
          self.viewModel.topViewAmount.next("transaction-details.pending.text".podLocalized())
        }
        else {
          self.viewModel.topViewAmount.next(transaction.localAmount?.text) // !
        }
        if transaction.transactionType == .decline {
          self.viewModel.transactionAmount.next(nil)
          self.viewModel.declinedAmount.next(
            transaction.localAmount?.text ?? "transaction-details.unavailable.text".podLocalized()
          )
          self.viewModel.declineReason.next(
            transaction.declineReason ?? "transaction-details.unavailable.text".podLocalized()
          )
        }
        else {
          self.viewModel.transactionAmount.next(
            transaction.localAmount?.text ?? "transaction-details.unavailable.text".podLocalized()
          )
          self.viewModel.declinedAmount.next(nil)
          self.viewModel.declineReason.next(nil)
        }
        self.viewModel.holdAmount.next(transaction.holdAmount?.text)
        self.viewModel.currency.next(transaction.localAmount?.currency.value)
        self.viewModel.type.next(transaction.transactionType.description())
        self.viewModel.location.next(transaction.store?.address?.addressDescription())
        self.viewModel.category.next(
          transaction.merchant?.mcc?.name ?? "transaction-details.unavailable.text".podLocalized()
        )
        self.viewModel.transactionDate.next(transaction.createdAt)
        self.viewModel.settlementDate.next(transaction.settlement?.createdAt)
        self.viewModel.merchantFee.next(transaction.feeAmount?.text)
        self.viewModel.cashbackAmount.next(transaction.cashbackAmount?.text)
        self.viewModel.shiftId.next(transaction.transactionId)
        self.viewModel.mccIcon.next(transaction.merchant?.mcc?.icon)
        if transaction.state != .pending {
          self.viewModel.externalId.next(transaction.externalTransactionId)
        }
        else {
          self.viewModel.externalId.next(nil)
        }
        self.viewModel.state.next(transaction.state?.description())
        self.viewModel.fundingSourceId.next(transaction.externalTransactionId)
        if let adjustments = transaction.adjustments {
          self.viewModel.adjustments.insert(contentsOf: adjustments, at: 0)
        }
        self.viewModel.latitude.next(transaction.store?.latitude)
        self.viewModel.longitude.next(transaction.store?.longitude)
        self.view?.finishUpdates()
        self.view?.hideLoadingSpinner()
      }
    }
  }

  func previousTapped() {
    router?.backFromTransactionDetails()
  }

  func mapTapped() {
    if let latitude = viewModel.latitude.value, let longitude = viewModel.longitude.value {
      router?.openMapsCenteredIn(latitude: latitude, longitude: longitude)
    }
  }

}
