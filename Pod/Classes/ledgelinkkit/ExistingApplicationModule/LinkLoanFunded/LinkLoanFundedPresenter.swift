//
//  LinkLoanFundedPresenter.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 18/11/2016.
//
//

import Bond

protocol LinkLoanFundedRouterProtocol {
  func show(financialAccount: FinancialAccount)
  func close()
}

class LinkLoanFundedViewModel {
  let cloudImage: Observable<UIImage?> = Observable(nil)
  let descriptionText: Observable<String> = Observable("")
  let showAction: Observable<Bool> = Observable(false)
  let actionTitle: Observable<String> = Observable("")
  var actionHandler: (()->Void)? = nil
  let showSecondaryAction: Observable<Bool> = Observable(false)
  let secondaryActionTitle: Observable<String> = Observable("")
  var secondaryActionHandler: (()->Void)? = nil
  init() {}
}

protocol LinkLoanFundedInteractorProtocol {
  func loadApplicationData(_ completion: @escaping Result<LoanApplication, NSError>.Callback)
}

protocol LinkLoanFundedViewProtocol: ViewControllerProtocol {
  func setupWith(viewModel:LinkLoanFundedViewModel)
  func presentActionSheet(_ actionSheet:UIAlertController)
}

class LinkLoanFundedPresenter: LinkLoanFundedEventHandler, LinkLoanFundedDataReceiver {

  let uiConfiguration: ShiftUIConfig
  let contextConfiguration: ContextConfiguration
  var view: LinkLoanFundedViewProtocol!
  var router: LinkLoanFundedRouterProtocol!
  var interactor: LinkLoanFundedInteractorProtocol!
  var strategy: LinkLoanFundedPresenterStrategyProtocol!
  let viewModel = LinkLoanFundedViewModel()

  init(uiConfiguration: ShiftUIConfig, contextConfiguration: ContextConfiguration) {
    self.uiConfiguration = uiConfiguration
    self.contextConfiguration = contextConfiguration
  }

  func viewLoaded() {
    loadApplicationData()
    view.setupWith(viewModel: viewModel)
  }

  func viewShown() {
  }

  func loadApplicationData() {
    interactor.loadApplicationData { [weak self] result in
      guard let wself = self else {
        return
      }
      switch result {
      case .failure(let error):
        wself.view.show(error:error, uiConfig: nil)
      case .success(let application):
        guard let wself = self else {
          return
        }
        wself.strategy = LinkLoanFundedPresenterStrategyFactory.strategyFor(application, delegate: wself)
        wself.strategy.setup(contextConfiguration: wself.contextConfiguration,
                             viewModel: wself.viewModel,
                             uiConfig: wself.uiConfiguration,
                             application: application)
      }
    }
  }

  func newDataReceived(_ application: LoanApplication, user:ShiftUser) {
    strategy = LinkLoanFundedPresenterStrategyFactory.strategyFor(application, delegate: self)
    strategy.setup(contextConfiguration: self.contextConfiguration,
                   viewModel: self.viewModel,
                   uiConfig: self.uiConfiguration,
                   application: application)
  }

  func presentActionSheet(_ actionSheet:UIAlertController) {
    self.view.presentActionSheet(actionSheet)
  }

  func closeTapped() {
    router.close()
  }

}

extension LinkLoanFundedPresenter: LinkLoanFundedPresenterStrategyDelegate {

  func show(card: Card) {
    router.show(financialAccount: card)
  }

  func sendSMSTo(card:Card) {
    view.showMessage("Coming soon", uiConfig: nil)
  }

}
