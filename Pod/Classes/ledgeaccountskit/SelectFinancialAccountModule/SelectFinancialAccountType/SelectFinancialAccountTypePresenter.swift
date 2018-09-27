//
//  SelectFinancialAccountTypePresenter.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 18/10/2016.
//
//

import Foundation

protocol SelectFinancialAccountTypeRouterProtocol {
  func backInFinancialAccountType(_ animated:Bool?)
  func showPlaidFlow(_ completion:@escaping Result<Void, NSError>.Callback)
  func showAddCardFlow()
  func accountSelected(_ financialAccount:FinancialAccount)
}

protocol SelectFinancialAccountTypeViewProtocol: ViewControllerProtocol {
  func set(subtitle:String)
  func showLoadingSpinner()
}

protocol SelectFinancialAccountTypeInteractorProtocol {
  func issueVirtualCard(_ callback:@escaping Result<Card,NSError>.Callback)
}

class SelectFinancialAccountTypePresenter: SelectFinancialAccountTypeEventHandler {

  var view: SelectFinancialAccountTypeViewProtocol!
  var interactor: SelectFinancialAccountTypeInteractorProtocol!
  var router: SelectFinancialAccountTypeRouterProtocol!
  var title: String
  var subtitle: String

  init(title:String, subtitle:String) {
    self.title = title
    self.subtitle = subtitle
  }

  func viewLoaded() {
    view.set(title: title)
    view.set(subtitle: subtitle)
  }

  func bankAccountTapped() {
    self.view.showLoadingSpinner()
    router.showPlaidFlow() { result in
      switch result {
      case .failure(let error):
        self.view.show(error:error)
      case .success():
        self.view.hideLoadingSpinner()
      }
    }
  }

  func cardTapped() {
    router.showAddCardFlow()
  }

  func virtualCardTapped() {
    view.showLoadingSpinner()
    interactor.issueVirtualCard { [weak self] result in
      self?.view.hideLoadingSpinner()
      switch result {
      case .failure(let error):
        self?.view.show(error:error)
      case .success (let card):
        self?.router.accountSelected(card)
      }
    }
  }

  func backTapped() {
    router.backInFinancialAccountType(true)
  }

}
