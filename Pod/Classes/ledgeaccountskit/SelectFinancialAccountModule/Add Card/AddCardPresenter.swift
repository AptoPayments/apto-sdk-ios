//
//  AddCardPresenter.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 20/10/2016.
//
//

import Foundation
import Stripe

protocol AddCardRouterProtocol {
  func backFromAddCard()
  func accountSelected(_ financialAccount:FinancialAccount)
  func showAccountList()
}

protocol AddCardViewProtocol: ViewControllerProtocol {
  func set(cardHolder:String?)
  func set(cardInfoShown:Bool)
  func showLoadingSpinner()
}

protocol AddCardInteractorProtocol {
  func cardHolderName(_ callback:@escaping Result<String?,NSError>.Callback)
  func addCard(cardNumber:String, cardNetwork:CardNetwork, expirationMonth:UInt, expirationYear:UInt, cvv:String, callback:@escaping Result<Card,NSError>.Callback)
}

class AddCardPresenter: AddCardTypeEventHandler {

  var view: AddCardViewProtocol!
  var interactor: AddCardInteractorProtocol!
  var router: AddCardRouterProtocol!
  var title: String

  init(title:String) {
    self.title = title
  }

  func viewLoaded() {
    self.view.set(title:title)
    self.view.set(cardInfoShown: true)
    interactor.cardHolderName { [weak self] result in
      switch result {
      case .failure:
        self?.view.set(cardHolder:nil)
      case .success(let cardHolder):
        self?.view.set(cardHolder:cardHolder)
      }
    }
  }

  func backTapped() {
    router.backFromAddCard()
  }

  func cardDataEntered(cardNumber:String, expirationMonth:UInt, expirationYear:UInt, cvv:String) {
    guard let cardNetwork = self.cardNetworkFrom(cardNumber: cardNumber) else {
      view.showMessage("Unsupported Card Type")
      return
    }
    view.showLoadingSpinner()
    interactor.addCard(cardNumber: cardNumber, cardNetwork:cardNetwork, expirationMonth: expirationMonth, expirationYear:expirationYear, cvv: cvv) { [weak self] result in
      self?.view.hideLoadingSpinner()
      switch result {
      case .failure (let error):
        self?.view.show(error:error)
      case .success(let card):
        self?.router.accountSelected(card)
      }
    }
  }

  func cardNetworkFrom(cardNumber:String) -> CardNetwork? {
    let stripeCardType = STPCardValidator.brand(forNumber: cardNumber)
    switch stripeCardType {
    case .visa:
      return CardNetwork.visa
    case .masterCard:
      return CardNetwork.mastercard
    case .amex:
      return CardNetwork.amex
    default:
      return nil
    }

  }

}
