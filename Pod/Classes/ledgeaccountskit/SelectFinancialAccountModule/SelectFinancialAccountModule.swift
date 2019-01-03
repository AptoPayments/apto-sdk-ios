//
//  SelectFinancialAccountModule.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 17/10/2016.
//
//

import Foundation
import LinkKit

protocol SelectFinancialAccountModuleDataProvider {
  func titleForAccoultList() -> String
  func subtitleForAccountList() -> String
  func titleForSelectAccountType() -> String
  func subtitleForSelectAccountType() -> String
}

class SelectFinancialAccountModule: UIModule {

  let dataProvider: SelectFinancialAccountModuleDataProvider
  var financialAccountListViewController: FinancialAccountListViewController!
  var initiallyAvailableFinancialAccounts: Bool = false
  open var onAccountSelected: ((_ selectFinancialAccountModule: SelectFinancialAccountModule, _ financialAccount: FinancialAccount) -> Void)?

  init (serviceLocator: ServiceLocatorProtocol, dataProvider: SelectFinancialAccountModuleDataProvider) {
    self.dataProvider = dataProvider
    super.init(serviceLocator: serviceLocator)
  }

  override func initialize(completion: @escaping Result<UIViewController, NSError>.Callback) {
    shiftSession.nextFinancialAccounts(0, rows: 1) { [weak self] result in
      guard let wself = self else {
        return
      }
      completion(result.flatMap { financialAccounts -> Result<UIViewController, NSError> in
        wself.initiallyAvailableFinancialAccounts = financialAccounts.count > 0
        if wself.initiallyAvailableFinancialAccounts {
          wself.financialAccountListViewController = wself.buidFinancialAccountListViewController(wself.uiConfig)
          return .success(wself.financialAccountListViewController)
        }
        else {
          let viewController = wself.buidSelectFinancialAccountTypeViewController(wself.uiConfig)
          return .success(viewController)
        }
      })
    }
  }

  fileprivate func buidFinancialAccountListViewController(_ uiConfig:ShiftUIConfig) -> FinancialAccountListViewController {
    let presenter = FinancialAccountListPresenter(title:dataProvider.titleForAccoultList(),
                                                  subtitle: dataProvider.subtitleForAccountList())
    let interactor = FinancialAccountListInteractor(shiftSession:shiftSession)
    let viewController = FinancialAccountListViewController(uiConfiguration: uiConfig, eventHandler: presenter)
    presenter.view = viewController
    presenter.interactor = interactor
    presenter.router = self
    return viewController
  }

  fileprivate func buidSelectFinancialAccountTypeViewController(_ uiConfig:ShiftUIConfig) -> UIViewController {
    let presenter = SelectFinancialAccountTypePresenter(title:dataProvider.titleForSelectAccountType(),
                                                        subtitle: dataProvider.subtitleForSelectAccountType())
    let interactor = SelectFinancialAccountTypeInteractor(shiftSession:shiftSession)
    let viewController = SelectFinancialAccountTypeViewController(uiConfiguration: uiConfig, eventHandler: presenter)
    presenter.view = viewController
    presenter.interactor = interactor
    presenter.router = self
    return viewController
  }

  fileprivate func buildAddCardViewController(_ uiConfig:ShiftUIConfig) -> UIViewController {
    let presenter = AddCardPresenter(title:"Add Card")
    let interactor = AddCardInteractor(shiftSession:shiftSession)
    let viewController = AddCardViewController(uiConfiguration: uiConfig, eventHandler: presenter)
    presenter.view = viewController
    presenter.interactor = interactor
    presenter.router = self
    return viewController
  }

  fileprivate func setupPlaidLink(_ completion:@escaping Result<PLKConfiguration, NSError>.Callback) {
    self.shiftSession.bankOauthConfiguration { result in
      switch result {
      case .failure(let error):
        completion(.failure(error))
      case .success(let bankOauthConfiguration):
        let linkConfiguration = PLKConfiguration(key: bankOauthConfiguration.publicApiKey, env: bankOauthConfiguration.environment, product: bankOauthConfiguration.product)
        linkConfiguration.clientName = "Ledge"
        PLKPlaidLink.setup(with: linkConfiguration) { (success, error) in
          if (success) {
            completion(.success(linkConfiguration))
          }
          else if let error = error {
            completion(.failure(error as NSError))
          }
        }
      }
    }
  }
}

extension SelectFinancialAccountModule: FinancialAccountListRouterProtocol {

  func showAddAccountFlow() {
    self.push(viewController: buidSelectFinancialAccountTypeViewController(self.uiConfig)) {}
  }

  func accountSelected(_ financialAccount:FinancialAccount) {
    onAccountSelected?(self, financialAccount)
  }

}

extension SelectFinancialAccountModule: SelectFinancialAccountTypeRouterProtocol {

  func showAccountList() {
    self.financialAccountListViewController?.refreshList()

    if self.initiallyAvailableFinancialAccounts == true {
      self.popViewController() {}
    }
    else {
      self.popViewController(animated: true) {
        self.push(viewController: self.buidFinancialAccountListViewController(self.uiConfig), animated: false) {}
      }
    }
  }

  func showPlaidFlow(_ completion:@escaping Result<Void, NSError>.Callback) {
    setupPlaidLink { result in
      switch result {
      case .failure(let error):
        completion(.failure(error))
      case .success(let plaidConfiguration):
        let linkViewController = PLKPlaidLinkViewController(configuration: plaidConfiguration, delegate: self)
        if (UI_USER_INTERFACE_IDIOM() == .pad) {
          linkViewController.modalPresentationStyle = .formSheet;
        }
        self.present(viewController: linkViewController) {
          completion(.success(Void()))
        }
      }
    }
  }

  func showAddCardFlow() {
    self.push(viewController: buildAddCardViewController(self.uiConfig)) {}
  }

  func backInFinancialAccountType(_ animated: Bool) {
    if initiallyAvailableFinancialAccounts {
      self.popViewController() {}
    }
    else {
      self.back()
    }
  }

}

extension SelectFinancialAccountModule: PLKPlaidLinkViewDelegate {

  func linkViewController(_ linkViewController: PLKPlaidLinkViewController, didSucceedWithPublicToken publicToken: String, metadata: [String : Any]?) {
    dismissViewController(animated:true) {
      self.shiftSession.addBankAccounts(publicToken) { result in
        switch result {
        case .failure(let error):
          self.show(error:error)
        case .success:
          self.showAccountList()
        }
      }
    }
  }

  func linkViewController(_ linkViewController: PLKPlaidLinkViewController, didExitWithError error: Error?, metadata: [String : Any]?) {
    dismissViewController(animated:true) {
      if let error = error {
        NSLog("Failed to link account due to: \(error.localizedDescription)\nmetadata: \(metadata ?? [:])")
      }
      else {
        NSLog("Plaid link exited with metadata: \(metadata ?? [:])")
      }
    }
  }

}

extension SelectFinancialAccountModule: AddCardRouterProtocol {

  func backFromAddCard() {
    self.popViewController() {}
  }

}
