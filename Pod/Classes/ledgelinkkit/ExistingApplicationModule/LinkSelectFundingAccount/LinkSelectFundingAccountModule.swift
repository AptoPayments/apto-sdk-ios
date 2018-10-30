//
//  LinkSelectFundingAccountModule.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 17/11/2017.
//

import UIKit

class LinkSelectFundingAccountModule: UIModule {

  fileprivate var application: LoanApplication
  fileprivate var linkLoanFundedModule: LinkLoanFundedModule?

  init(serviceLocator: ServiceLocatorProtocol, application: LoanApplication) {
    self.application = application

    super.init(serviceLocator: serviceLocator)
  }

  override func initialize(completion: @escaping Result<UIViewController, NSError>.Callback) {
    let module = SelectFinancialAccountModule(serviceLocator: self.serviceLocator, dataProvider: self)
    module.onBack = { module in
      self.clear()
      self.back()
    }
    module.onClose = { module in
      self.clear()
      self.close()
    }
    module.onAccountSelected = { module, account in
      self.set(fundingAccount: account)
    }
    addChild(module: module, completion: completion)
  }

  fileprivate func set(fundingAccount: FinancialAccount) {
    showLoadingSpinner()
    shiftSession.linkSession.setApplicationAccount(financialAccount: fundingAccount, accountType: .funding, application: application) { result in
      switch result {
      case .failure(let error):
        self.show(error: error)
      case .success(let application):
        self.hideLoadingSpinner()
        application.fundingAccount = fundingAccount
        self.application = application
        self.showLoanFundedFor(application: application)
      }
    }
  }

  fileprivate func showLoanFundedFor(application: LoanApplication) {
    let module = LinkLoanFundedModule(serviceLocator: serviceLocator, application: application)
    module.onClose = { module in
      self.close()
    }
    module.onClose = { module in
      self.close()
    }
    linkLoanFundedModule = module
    push(module:module) { result in }
  }

  fileprivate func clear() {
    linkLoanFundedModule = nil
  }

}

extension LinkSelectFundingAccountModule: SelectFinancialAccountModuleDataProvider {

  func titleForAccoultList() -> String {
    return "Funding Account"
  }

  func subtitleForAccountList() -> String {
    return "Where do you want your loan deposited?"
  }

  func titleForSelectAccountType() -> String {
    return "Fund Loan"
  }

  func subtitleForSelectAccountType() -> String {
    return "How do you want to fund your loan?"
  }

}
