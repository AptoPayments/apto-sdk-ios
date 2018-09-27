//
//  LinkLoanFundedPresenterStrategy.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 18/11/2016.
//
//

import Foundation

protocol LinkLoanFundedPresenterStrategyProtocol {
  init(application: LoanApplication, delegate: LinkLoanFundedPresenterStrategyDelegate)
  func setup(contextConfiguration:ContextConfiguration, viewModel:LinkLoanFundedViewModel, uiConfig:ShiftUIConfig, application: LoanApplication)
}

protocol LinkLoanFundedPresenterStrategyDelegate {
  func show(card: Card)
  func sendSMSTo(card:Card)
  func closeTapped()
}

class LinkLoanFundedPresenterStrategy: LinkLoanFundedPresenterStrategyProtocol {
  let application: LoanApplication
  let delegate: LinkLoanFundedPresenterStrategyDelegate
  required init(application: LoanApplication, delegate: LinkLoanFundedPresenterStrategyDelegate) {
    self.application = application
    self.delegate = delegate
  }
  func setup(contextConfiguration:ContextConfiguration, viewModel:LinkLoanFundedViewModel, uiConfig:ShiftUIConfig, application: LoanApplication) {}
}

extension LinkLoanFundedPresenterStrategyProtocol {

  func defaultLabel (_ uiConfig:ShiftUIConfig, label:String) -> UILabel {
    let retVal = UILabel()
    retVal.text = label
    retVal.font = uiConfig.fonth4
    retVal.textColor = uiConfig.defaultTextColor
    retVal.backgroundColor = uiConfig.applicationLabelBackgroundColor
    retVal.textAlignment = .left
    return retVal
  }

  func defaultRightLabel (_ uiConfig:ShiftUIConfig, label:String) -> UILabel {
    let retVal = UILabel()
    retVal.text = label
    retVal.font = uiConfig.fonth4
    retVal.textColor = uiConfig.defaultTextColor
    retVal.backgroundColor = uiConfig.applicationValueBackgroundColor
    retVal.textAlignment = .right
    return retVal
  }

}

class LinkLoanFundedPresenterStrategyFactory {
  static func strategyFor(_ application: LoanApplication, delegate: LinkLoanFundedPresenterStrategyDelegate) -> LinkLoanFundedPresenterStrategyProtocol {
    guard let fundingAccount = application.fundingAccount else {
      return LinkLoanFundedPresenterStrategyAutopayEnabled(application:application, delegate: delegate)
    }
    if let _ = fundingAccount as? BankAccount {
      return LinkLoanFundedPresenterStrategyBankAccount(application:application, delegate: delegate)
    }
    else {
      return LinkLoanFundedPresenterStrategyCard(application:application, delegate: delegate)
    }
  }
}
