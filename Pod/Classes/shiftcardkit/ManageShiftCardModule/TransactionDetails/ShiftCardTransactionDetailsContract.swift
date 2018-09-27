//
//  ShiftCardTransactionDetailsContract.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 14/08/2018.
//

import UIKit

protocol ShiftCardTransactionDetailsPresenterProtocol {
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
}

protocol ShiftCardTransactionDetailsInteractorProtocol {
  func provideTransaction(callback: @escaping Result<Transaction, NSError>.Callback)
}
