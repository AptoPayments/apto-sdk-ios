//
//  ShiftCardTransactionDetailsPresenter.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 25/03/2018.
//
//

import Foundation
import Stripe
import Bond

class ShiftCardTransactionDetailsPresenter: ShiftCardTransactionDetailsPresenterProtocol {
  // swiftlint:disable implicitly_unwrapped_optional
  var view: ShiftCardTransactionDetailsViewProtocol!
  var interactor: ShiftCardTransactionDetailsInteractorProtocol!
  var router: ShiftCardTransactionDetailsRouterProtocol!
  // swiftlint:enable implicitly_unwrapped_optional
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
        self.refreshViewModelWith(transaction: transaction)
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

  private func refreshViewModelWith(transaction: Transaction) {
    viewModel.latitude.next(transaction.store?.latitude)
    viewModel.longitude.next(transaction.store?.longitude)
    viewModel.mccIcon.next(transaction.merchant?.mcc?.icon)
    viewModel.description.next(transaction.transactionDescription?.capitalized)
    viewModel.fiatAmount.next(transaction.localAmount?.text)
    viewModel.nativeAmount.next(transaction.nativeBalance?.text)
    //address
    viewModel.transactionDate.next(self.format(date: transaction.createdAt))
    viewModel.transactionStatus.next(transaction.state.description())
    viewModel.category.next(
      transaction.merchant?.mcc?.description() ?? "transaction_details.basic_info.category.unavailable".podLocalized()
    )
    // Funding source
    viewModel.fee.next(transaction.feeAmount?.text)
    // Currency exchange???
    if let (nativeAmount, fiatAmount) = computeExchangeRateFor(adjustments: transaction.adjustments),
      let nativeCurrencySymbol = nativeAmount.currencySymbol {
      viewModel.exchangeRate.next("1 \(nativeCurrencySymbol) ≈ \(fiatAmount.text)")
    }
    else {
      viewModel.exchangeRate.next(nil)
    }
    viewModel.deviceType.next(transaction.deviceType.description())
    viewModel.transactionClass.next(transaction.transactionClass.description())
    viewModel.transactionId.next(transaction.transactionId)
    if let adjustments = transaction.adjustments {
      viewModel.adjustments.insert(contentsOf: adjustments, at: 0)
    }
  }
}

private extension ShiftCardTransactionDetailsPresenter {
  static var dateFormatter = DateFormatter.customLocalizedDateFormatter(dateFormat: "MMMddhhmm")
  static var dateFormatterWithYear = DateFormatter.customLocalizedDateFormatter(dateFormat: "MMMddYYYYhhmm")

  func format(date: Date?) -> String? {
    guard let date = date else {
      return nil
    }
    let formattedDate: String
    if Date().year > date.year {
      formattedDate = ShiftCardTransactionDetailsPresenter.dateFormatterWithYear.string(from: date)
    }
    else {
      formattedDate = ShiftCardTransactionDetailsPresenter.dateFormatter.string(from: date)
    }
    return formattedDate
  }

  func computeExchangeRateFor(adjustments: [TransactionAdjustment]?) -> (Amount, Amount)? {
    guard let adjustments = adjustments else {
      return nil
    }
    var fiatAmount: Double = 0
    var nativeAmount: Double = 0
    for adjustment in adjustments {
      fiatAmount += adjustment.localAmount?.amount.value ?? 0
      nativeAmount += adjustment.nativeAmount?.amount.value ?? 0
    }
    return (Amount(value: nativeAmount / nativeAmount, currency: adjustments.first?.nativeAmount?.currency.value),
            Amount(value: fiatAmount / nativeAmount, currency: adjustments.first?.localAmount?.currency.value))
  }
}
