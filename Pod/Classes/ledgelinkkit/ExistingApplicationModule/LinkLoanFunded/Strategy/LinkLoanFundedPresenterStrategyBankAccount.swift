//
//  LinkLoanFundedPresenterStrategyBankAccount.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 18/11/2016.
//
//

import Foundation

class LinkLoanFundedPresenterStrategyBankAccount: LinkLoanFundedPresenterStrategy {

  override func setup(contextConfiguration:ContextConfiguration, viewModel:LinkLoanFundedViewModel, uiConfig:ShiftUIConfig, application: LoanApplication) {

    // Image
    viewModel.cloudImage.next(UIImage.imageFromPodBundle("loanFundedIcon.png"))

    // Description
    viewModel.descriptionText.next("loan-funded.description.bank-account".podLocalized().replace(["{{financial_account}}" : application.fundingAccount!.quickDescription()]))

    // Primary Action
    viewModel.showAction.next(false)

    // Secondary Action
    viewModel.showSecondaryAction.next(false)

  }

}
