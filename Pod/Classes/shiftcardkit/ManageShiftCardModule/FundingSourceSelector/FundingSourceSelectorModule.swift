//
// FundingSourceSelectorModule.swift
// ShiftSDK
//
// Created by Takeichi Kanzaki on 18/12/2018.
//

import Foundation

class FundingSourceSelectorModule: UIModule, FundingSourceSelectorModuleProtocol {
  private let card: Card
  private var presenter: FundingSourceSelectorPresenterProtocol?
  private var externalOAuthModule: ExternalOAuthModule?

  init(serviceLocator: ServiceLocatorProtocol, card: Card) {
    self.card = card
    super.init(serviceLocator: serviceLocator)
  }

  override func initialize(completion: @escaping Result<UIViewController, NSError>.Callback) {
    completion(.success(buildViewController()))
  }

  func fundingSourceChanged() {
    self.onFinish?(self)
  }

  func addFundingSource(completion: @escaping (FundingSource) -> Void) {
    guard let allowedBalanceTypes = card.features?.allowedBalanceTypes, !allowedBalanceTypes.isEmpty else {
      return
    }
    let oauthModuleConfig = ExternalOAuthModuleConfig(title: "Coinbase", allowedBalanceTypes: allowedBalanceTypes)
    let externalOAuthModule = ExternalOAuthModule(serviceLocator: serviceLocator,
                                                  config: oauthModuleConfig,
                                                  uiConfig: uiConfig)
    externalOAuthModule.onOAuthSucceeded = { [weak self] _, custodian in
      guard let self = self else { return }
      self.showLoadingSpinner()
      self.shiftSession.addFinancialAccountFundingSource(accountId: self.card.accountId,
                                                         custodian: custodian) { [weak self] result in
        switch result {
        case .failure(let error):
          self?.show(error: error)
        case .success(let fundingSource):
          self?.hideLoadingSpinner()
          self?.dismissModule {
            self?.externalOAuthModule = nil
            completion(fundingSource)
          }
        }
      }
    }
    externalOAuthModule.onBack = { module in
      self.dismissModule {
        self.externalOAuthModule = nil
      }
    }
    externalOAuthModule.onClose = { module in
      self.dismissModule {
        self.externalOAuthModule = nil
      }
    }
    self.externalOAuthModule = externalOAuthModule
    present(module: externalOAuthModule) { _ in }
  }

  // MARK: - Private methods
  private func buildViewController() -> ShiftViewController {
    let presenter = serviceLocator.presenterLocator.fundingSourceSelectorPresenter()
    let interactor = serviceLocator.interactorLocator.fundingSourceSelector(card: card)
    let viewController = serviceLocator.viewLocator.fundingSourceSelectorView(presenter: presenter)
    navigationController?.modalPresentationStyle = .overCurrentContext
    viewController.modalPresentationStyle = .overCurrentContext
    presenter.router = self
    presenter.interactor = interactor
    self.presenter = presenter
    return viewController
  }
}
