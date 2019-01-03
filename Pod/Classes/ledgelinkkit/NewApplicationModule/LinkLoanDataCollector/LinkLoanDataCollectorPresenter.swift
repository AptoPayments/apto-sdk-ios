//
//  LoanDataCollector.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 06/03/16.
//
//

import Foundation

protocol LinkLoanDataCollectorRouterProtocol: URLHandlerProtocol {
  func close()
  func back()
  func getLoanOffersTappedInLoanDataCollector()
  func applicationListTappedInLoanDataCollector()
  func nextTappedInLoanDataCollector()
  func profileTappedInLoanDataCollector()
}

protocol LinkLoanDataCollectorInteractorProtocol {
  func provideLoanDataCollectorData()
}

protocol LinkLoanDataCollectorViewProtocol: ViewControllerProtocol {
  func showNavProfileButton(_ tintColor: UIColor?)
  func showProgressBar()
  func hideProgressBar()
  func show(fields:[FormRowView])
}

class LinkLoanDataCollectorPresenter: LinkLoanDataCollectorDataReceiver, LinkLoanDataCollectorEventHandler {

  var uiConfig: ShiftUIConfig
  var stepHandler: LinkLoanDataColletorAmountStep!

  var view: LinkLoanDataCollectorViewProtocol!
  var interactor: LinkLoanDataCollectorInteractorProtocol!
  var router: LinkLoanDataCollectorRouterProtocol!
  var linkHandler: LinkHandler?
  var config: LinkLoanDataCollectorConfig!

  init(uiConfig: ShiftUIConfig) {
    self.uiConfig = uiConfig
  }

  func viewLoaded() {
    self.interactor.provideLoanDataCollectorData()
  }

  // MARK: - Private methods

  func set(loanData: AppLoanData,
                    config: LinkLoanDataCollectorConfig) {
    self.setupInterface(loanData, config:config)
  }

  // MARK: - Navigation buttons handling

  func closeTapped() {
    router.close()
  }

  func nextTapped() {
    switch self.config.mode {
    case .firstStep:
      router.nextTappedInLoanDataCollector()
    case .finalStep:
      router.profileTappedInLoanDataCollector()
    }
  }

  func previousTapped() {
    router.back()
  }

  // MARK: - Private methods

  func setupInterface(_ loanData: AppLoanData,
                      config: LinkLoanDataCollectorConfig) {

    linkHandler = LinkHandler(urlHandler: router)
    self.config = config

    // Setup step handler
    stepHandler = LinkLoanDataColletorAmountStep(loanData: loanData,
                                                 config: config,
                                                 uiConfig:uiConfig,
      getOffersTapHandler: { [weak self] in
        guard let wself = self else {
          return
        }
        wself.router.getLoanOffersTappedInLoanDataCollector()
        },
      showPendingApplicationsTapHandler: { [weak self] in
        guard let wself = self else {
          return
        }
        guard config.pendingApplications.count > 0 else {
          wself.view.showMessage("data-collector.no-pending-applications".podLocalized(), uiConfig: nil)
          return
        }
        wself.router.applicationListTappedInLoanDataCollector()
      }, linkHandler: linkHandler)

    view.set(title: stepHandler.title)
    view.show(fields: stepHandler.rows)

    switch config.mode {
    case .firstStep:
      configureNavForMissingDatapoints()
      view.showProgressBar()
    case .finalStep:
      configureNavForFulfilledDataPoints()
      view.hideProgressBar()
    }

  }

  func configureNavForMissingDatapoints() {
    self.view.showNavNextButton(tintColor: uiConfig.iconTertiaryColor)
    let _ = self.stepHandler.valid.observeNext { [weak self] validStep in
      if validStep { self?.view.activateNavNextButton(self?.uiConfig.tintColor) }
      else { self?.view.deactivateNavNextButton(self?.uiConfig.disabledTintColor) }
    }
  }

  func configureNavForFulfilledDataPoints() {
    self.view.showNavCancelButton(uiConfig.iconTertiaryColor)
    self.view.showNavProfileButton(uiConfig.iconTertiaryColor)
    self.view.activateNavNextButton(uiConfig.iconTertiaryColor)
  }


}
