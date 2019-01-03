//
//  UserDataVerificationContract.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 29/08/2018.
//

import UIKit
import Bond

protocol PINVerificationView: ViewControllerProtocol {
  func showLoadingSpinner()
  func showWrongPinError(error: Error)
  func show(error: Error)
}

typealias PINVerificationViewControllerProtocol = ShiftViewController & PINVerificationView

open class PINVerificationViewModel {
  public let title: Observable<String?> = Observable(nil)
  public let subtitle: Observable<String?> = Observable(nil)
  public let datapointValue: Observable<String?> = Observable(nil)
  public let footerTitle: Observable<String?> = Observable(nil)
  public let resendButtonTitle: Observable<String?> = Observable(nil)
}

protocol PINVerificationPresenter: class {
  var viewModel: PINVerificationViewModel { get }
  func viewLoaded()
  func submitTapped(_ pin: String)
  func resendTapped()
  func closeTapped()
}
