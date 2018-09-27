//
//  KYCPresenter.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 09/04/2017.
//
//

import Foundation
import Stripe
import Bond

protocol KYCRouterProtocol: class {
  func backFromKYC()
  func closeFromKYC()
  func kycPassed()
}

protocol KYCViewProtocol: ViewControllerProtocol {}

protocol KYCInteractorProtocol {
  func provideKYCInfo(_ callback: @escaping Result<KYCState?, NSError>.Callback)
}

open class KYCViewModel {
  open var kycState: Observable<KYCState?> = Observable(nil)
}

class KYCPresenter: KYCEventHandler {
  // swiftlint:disable implicitly_unwrapped_optional
  var view: KYCViewProtocol!
  var interactor: KYCInteractorProtocol!
  weak var router: KYCRouterProtocol!
  // swiftlint:enable implicitly_unwrapped_optional
  var viewModel: KYCViewModel

  init() {
    self.viewModel = KYCViewModel()
  }

  func viewLoaded() {
    interactor.provideKYCInfo { result in
      switch result {
      case .failure(let error):
        self.view.show(error: error)
      case .success(let kyc):
        self.viewModel.kycState.next(kyc)
      }
    }
  }

  func previousTapped() {
    router.backFromKYC()
  }

  func closeTapped() {
    router.closeFromKYC()
  }

  func refreshTapped() {
    interactor.provideKYCInfo { result in
      switch result {
      case .failure(let error):
        self.view.show(error: error)
      case .success(let kyc):
        self.viewModel.kycState.next(kyc)
        if let kyc = kyc {
          switch kyc {
          case .passed:
            self.router.kycPassed()
          default:
            break
          }
        }
      }
    }
  }
}
