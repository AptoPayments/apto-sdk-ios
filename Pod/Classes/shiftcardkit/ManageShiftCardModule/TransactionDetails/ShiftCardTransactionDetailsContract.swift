//
//  ShiftCardTransactionDetailsContract.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 14/08/2018.
//

import UIKit
import Bond

typealias ShiftCardTransactionDetailsViewControllerProtocol = ShiftViewController & ShiftCardTransactionDetailsViewProtocol

protocol ShiftCardTransactionDetailsPresenterProtocol: class {
  // swiftlint:disable implicitly_unwrapped_optional
  var view: ShiftCardTransactionDetailsViewProtocol! { get set }
  var interactor: ShiftCardTransactionDetailsInteractorProtocol! { get set }
  var router: ShiftCardTransactionDetailsRouterProtocol! { get set }
  // swiftlint:enable implicitly_unwrapped_optional
  var viewModel: ShiftCardTransactionDetailsViewModel { get }
  func viewLoaded()
  func previousTapped()
  func mapTapped()
}

protocol ShiftCardTransactionDetailsRouterProtocol {
  func backFromTransactionDetails()
  func openMapsCenteredIn(latitude: Double, longitude: Double)
}

protocol ShiftCardTransactionDetailsViewProtocol: class, ViewControllerProtocol {
  func finishUpdates()
  func showLoadingSpinner()
  func show(error: Error)
}

protocol ShiftCardTransactionDetailsInteractorProtocol {
  func provideTransaction(callback: @escaping Result<Transaction, NSError>.Callback)
}

open class ShiftCardTransactionDetailsViewModel {
  // Map
  public let latitude: Observable<Double?> = Observable(nil)
  public let longitude: Observable<Double?> = Observable(nil)
  public let mccIcon: Observable<MCCIcon?> = Observable(nil)
  // Header
  public let fiatAmount: Observable<String?> = Observable(nil)
  public let nativeAmount: Observable<String?> = Observable(nil)
  public let description: Observable<String?> = Observable(nil)
  // Address
  public let address: Observable<String?> = Observable(nil)
  // Basic Data
  public let transactionDate: Observable<String?> = Observable(nil)
  public let transactionStatus: Observable<String?> = Observable(nil)
  public let category: Observable<String?> = Observable(nil)
  public let fundingSource: Observable<String?> = Observable(nil)
  public let fee: Observable<String?> = Observable(nil)
  public let currencyExchange: Observable<String?> = Observable(nil)
  public let exchangeRate: Observable<String?> = Observable(nil)
  // Detailed Data
  public let deviceType: Observable<String?> = Observable(nil)
  public let transactionClass: Observable<String?> = Observable(nil)
  public let transactionId: Observable<String?> = Observable(nil)
  public let adjustments: MutableObservableArray<TransactionAdjustment> = MutableObservableArray([])
}
