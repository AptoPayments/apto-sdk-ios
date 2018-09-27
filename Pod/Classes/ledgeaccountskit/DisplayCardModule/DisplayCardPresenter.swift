//
//  DisplayCardPresenter.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 24/10/2017.
//
//

import Foundation
import Stripe

protocol DisplayCardRouterProtocol {
  func backFromCardViewer()
  func doneFromCardViewer()
}

protocol DisplayCardViewProtocol: ViewControllerProtocol {
  func set(cardNetwork: CardNetwork?,
           cardHolder: String?,
           pan: String?,
           cvv: String?,
           expirationMonth: UInt,
           expirationYear: UInt,
           cardBalance: Amount?,
           cardState: FinancialAccountState)
  func showLoadingSpinner()
}

protocol DisplayCardInteractorProtocol {
  func provideCard(_ callback:@escaping Result<Card, NSError>.Callback)
}

class DisplayCardPresenter: DisplayCardEventHandler {

  var view: DisplayCardViewProtocol!
  var interactor: DisplayCardInteractorProtocol!
  var router: DisplayCardRouterProtocol!

  func viewLoaded() {
    view.showLoadingSpinner()
    interactor.provideCard { [weak self] result in
      switch result {
      case .failure(let error):
        self?.view.show(error:error)
      case .success(let card):
        self?.view.hideLoadingSpinner()
        var monthShown: UInt = 1
        var yearShown: UInt = 1
        let expiration = card.expiration.split(separator: "-")
        if var year = UInt(expiration[0]), let month = UInt(expiration[1]) {
          if year > 99 { year = year - 2000 }
          monthShown = month
          yearShown = year
        }
        self?.view.set(cardNetwork: card.cardNetwork,
                       cardHolder: card.cardHolder,
                       pan: card.pan,
                       cvv: card.cvv,
                       expirationMonth: monthShown,
                       expirationYear: yearShown,
                       cardBalance: card.fundingSource?.balance,
                       cardState: card.state)
      }
    }
  }

  func previousTapped() {
    router.backFromCardViewer()
  }

  func closeTapped() {

  }

  func addToWalletTapped() {

  }

}
