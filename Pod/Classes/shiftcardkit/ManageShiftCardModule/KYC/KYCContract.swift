//
//  KYCContract.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 27/12/2018.
//

import Foundation
import Bond

typealias KYCViewControllerProtocol = ShiftViewController & KYCViewProtocol

protocol KYCViewProtocol: ViewControllerProtocol {
  func showLoadingSpinner()
  func show(error: Error)
}

protocol KYCInteractorProtocol {
  func provideKYCInfo(_ callback: @escaping Result<KYCState?, NSError>.Callback)
}

protocol KYCPresenterProtocol: class {
  // swiftlint:disable implicitly_unwrapped_optional
  var view: KYCViewProtocol! { get set }
  var interactor: KYCInteractorProtocol! { get set }
  var router: KYCRouterProtocol! { get set }
  // swiftlint:enable implicitly_unwrapped_optional
  var viewModel: KYCViewModel { get }

  func viewLoaded()
  func previousTapped()
  func closeTapped()
  func refreshTapped()
  func show(url: URL)
}

protocol KYCModuleProtocol: UIModuleProtocol {
  func show(url: URL)
  func call(url: URL, completion: @escaping () -> Void)
  func cardActivationFinish()
}

class KYCViewModel {
  public let kycState: Observable<KYCState?> = Observable(nil)
}

protocol KYCRouterProtocol: class {
  func backFromKYC()
  func closeFromKYC()
  func kycPassed()
  func show(url: URL)
}
