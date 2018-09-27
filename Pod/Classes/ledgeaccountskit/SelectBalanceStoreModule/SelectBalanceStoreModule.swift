//
//  SelectBalanceStoreModule.swift
//  ShiftSDK
//
//  Created by Takeichi Kanzaki on 26/06/2018.
//
//

protocol SelectBalanceStoreModuleProtocol: UIModuleProtocol {
}

class SelectBalanceStoreModule: UIModule, SelectBalanceStoreModuleProtocol {
  private let externalOAuthModuleConfig = ExternalOAuthModuleConfig(title: "select-balance-store.title".podLocalized())
  private let application: CardApplication

  private var shiftCardSession: ShiftCardSession {
    return shiftSession.shiftCardSession
  }

  init(serviceLocator: ServiceLocatorProtocol, application: CardApplication) {
    self.application = application
    super.init(serviceLocator: serviceLocator)
  }

  override func initialize(completion: @escaping Result<UIViewController, NSError>.Callback) {
    shiftSession.contextConfiguration { result in
      switch result {
      case .failure (let error):
        completion(.failure(error))
      case .success(let contextConfiguration):
        let uiConfig = ShiftUIConfig(projectConfiguration: contextConfiguration.projectConfiguration)
        self.uiConfig = uiConfig
        let module = self.buildExternalOAuthModule(uiConfig: uiConfig)
        self.addChild(module: module, completion: completion)
      }
    }
  }

  private func buildExternalOAuthModule(uiConfig: ShiftUIConfig) -> UIModuleProtocol {
    let externalOAuthModule = serviceLocator.moduleLocator.externalOAuthModule(config: externalOAuthModuleConfig,
                                                                               uiConfig: uiConfig)
    externalOAuthModule.onClose = { [unowned self] _ in
      self.close()
    }
    externalOAuthModule.onBack = { [unowned self] _ in
      self.back()
    }
    externalOAuthModule.onOAuthSucceeded = { _, custodian in
      self.showLoadingSpinner()
      self.shiftCardSession.setBalanceStore(self.application.id, custodian: custodian) { result in
        self.hideLoadingSpinner()
        switch result {
        case .failure(let error):
          self.show(error: error)
        case .success(let balanceStoreResult):
          self.process(result: balanceStoreResult)
        }
      }
    }

    return externalOAuthModule
  }

  private func process(result: SelectBalanceStoreResult) {
    if result.isSuccess {
      self.onFinish?(self)
    }
    else {
      let alert = UIAlertController(title: "external-oauth.coinbase.connect".podLocalized(),
                                    message: result.errorMessage,
                                    preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "general.button.ok".podLocalized(), style: .default))
      present(viewController: alert, animated: true) { }
    }
  }
}
