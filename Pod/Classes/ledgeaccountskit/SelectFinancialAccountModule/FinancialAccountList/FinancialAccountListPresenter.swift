//
//  FinancialAccountListPresenter.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 17/10/2016.
//
//

import Foundation

protocol FinancialAccountListRouterProtocol {
  func back()
  func close()
  func accountSelected(_ financialAccount:FinancialAccount)
  func showAddAccountFlow()
}

protocol FinancialAccountListViewProtocol: ViewControllerProtocol {
  func showNewContents(_ newContents:[FinancialAccount])
  func set(subtitle:String)
}

protocol FinancialAccountListInteractorProtocol {
  func loadFinancialAccountList(_ callback:@escaping Result<[FinancialAccount],NSError>.Callback)
}

class FinancialAccountListPresenter: FinancialAccountListEventHandler {

  var view: FinancialAccountListViewProtocol!
  var interactor: FinancialAccountListInteractorProtocol!
  var router: FinancialAccountListRouterProtocol!
  var title: String
  var subtitle: String
  var financialAccounts: [FinancialAccount]?
  var selectedFinancialAccount:FinancialAccount?

  init(title:String, subtitle:String) {
    self.title = title
    self.subtitle = subtitle
  }

  func viewLoaded() {
    self.view.set(title:title)
    self.view.set(subtitle:subtitle)
    self.refreshListTapped()
  }

  func backTapped() {
    router.back()
  }

  func closeTapped() {
    router.close()
  }

  func addAccountTapped() {
    router.showAddAccountFlow()
  }

  func accountSelectedWith(index:Int) {
    guard let financialAccounts = self.financialAccounts else {
      self.selectedFinancialAccount = nil
      return
    }
    guard index >= 0 && index < financialAccounts.count else {
      self.selectedFinancialAccount = nil
      return
    }
    self.selectedFinancialAccount = financialAccounts[index]
  }

  func doneTapped() {
    guard let financialAccount = self.selectedFinancialAccount else {
      return
    }
    router.accountSelected(financialAccount)
  }

  func refreshListTapped() {
    self.interactor.loadFinancialAccountList() { [weak self] result in
      switch result {
      case .failure(let error):
        self?.view.show(error:error, uiConfig: nil)
      case .success(let financialAccounts):
        self?.financialAccounts = financialAccounts
        self?.view.showNewContents(financialAccounts)
      }
    }
  }

}
