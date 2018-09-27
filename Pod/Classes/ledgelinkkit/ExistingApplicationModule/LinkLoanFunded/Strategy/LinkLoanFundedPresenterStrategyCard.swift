//
//  LinkLoanFundedPresenterStrategyCard.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 18/11/2016.
//
//

import Foundation

class LinkLoanFundedPresenterStrategyCard: LinkLoanFundedPresenterStrategy {

  override func setup(contextConfiguration:ContextConfiguration, viewModel:LinkLoanFundedViewModel, uiConfig:ShiftUIConfig, application: LoanApplication) {

    // Image
    if let projectLogo = contextConfiguration.projectConfiguration.branding.logoUrl,
      let projectLogoUrl = URL(string:projectLogo) {
      ImageCache.defaultCache().imageWithUrl(projectLogoUrl) { response in
        switch response {
        case .failure:
          viewModel.cloudImage.next(UIImage.imageFromPodBundle("loanFundedIcon.png"))
        case .success(let image):
          viewModel.cloudImage.next(image)
        }
      }
    }
    else {
      viewModel.cloudImage.next(UIImage.imageFromPodBundle("loanFundedIcon.png"))
    }

    // Description
    viewModel.descriptionText.next("loan-funded.description.card".podLocalized().replace(["{{financial_account}}" : application.fundingAccount!.quickDescription()]))

    // Primary action
    viewModel.actionTitle.next("loan-funded.button.view-card".podLocalized())
    viewModel.actionHandler = {
      guard let card = self.application.fundingAccount as? Card else {
        return
      }
      self.delegate.show(card:card)
      } as (() -> Void)
    viewModel.showAction.next(true)

  }

}
