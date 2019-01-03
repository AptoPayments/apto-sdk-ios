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

class KYCPresenter: KYCPresenterProtocol {
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

  func show(url: URL) {
    router.show(url: url)
  }
}
