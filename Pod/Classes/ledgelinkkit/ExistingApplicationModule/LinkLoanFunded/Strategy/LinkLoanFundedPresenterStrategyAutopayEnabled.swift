//
//  LinkLoanFundedPresenterStrategyAutopayEnabled.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 18/11/2016.
//
//

import Foundation

class LinkLoanFundedPresenterStrategyAutopayEnabled: LinkLoanFundedPresenterStrategy {

  override func setup(contextConfiguration:ContextConfiguration, viewModel:LinkLoanFundedViewModel, uiConfig:ShiftUIConfig, application: LoanApplication) {

    // Image
    viewModel.cloudImage.next(UIImage.imageFromPodBundle("loanFundedIcon.png"))

    // Description
    viewModel.descriptionText.next("loan-funded.description.autopay-enabled".podLocalized())

    // Primary Action
    viewModel.actionTitle.next("loan-funded.button.exit".podLocalized())
    viewModel.actionHandler = {
      self.delegate.closeTapped()
    } as (() -> Void)
    viewModel.showAction.next(true)

    // Secondary Action
    viewModel.showSecondaryAction.next(true)

  }

}
