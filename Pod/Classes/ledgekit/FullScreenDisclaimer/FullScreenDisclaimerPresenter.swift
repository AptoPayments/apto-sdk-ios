//
//  FullScreenDisclaimerPresenter.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 17/02/16.
//
//

import Foundation
import ReactiveKit

class FullScreenDisclaimerPresenter: FullScreenDisclaimerPresenterProtocol {
  let viewModel = FullScreenDisclaimerViewModel()
  weak var router: FullScreenDisclaimerRouterProtocol!
  var interactor: FullScreenDisclaimerInteractorProtocol!

  func viewLoaded() {
    interactor.provideDisclaimer { [weak self] disclaimer in
      self?.set(disclaimer: disclaimer)
    }
  }

  private func set(disclaimer: Content) {
    viewModel.disclaimer.next(disclaimer)
  }

  func closeTapped() {
    router.close()
  }

  func agreeTapped() {
    router.agreeTapped()
  }

  func linkTapped(_ url: URL) {
    router.showExternal(url: url, headers: nil, useSafari: false)
  }
}
