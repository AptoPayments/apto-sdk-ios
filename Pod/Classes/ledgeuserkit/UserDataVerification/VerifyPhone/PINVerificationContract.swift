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
}

open class PINVerificationViewModel {
  open var title: Observable<String?> = Observable(nil)
  open var subtitle: Observable<String?> = Observable(nil)
  open var datapointValue: Observable<String?> = Observable(nil)
  open var resendButtonTitle: Observable<String?> = Observable(nil)
}

protocol PINVerificationPresenter: class {
  var viewModel: PINVerificationViewModel { get }
  func viewLoaded()
  func submitTapped(_ pin: String)
  func resendTapped()
  func closeTapped()
}
