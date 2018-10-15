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
  private var dataConfirmationModule: DataConfirmationModuleProtocol?
  private var projectConfiguration: ProjectConfiguration! // swiftlint:disable:this implicitly_unwrapped_optional

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
        self.projectConfiguration = contextConfiguration.projectConfiguration
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
    externalOAuthModule.onOAuthSucceeded = { [unowned self] _, custodian in
      self.showDataConfirmationIfNeededAndConfirm(custodian: custodian)
    }

    return externalOAuthModule
  }

  private func showDataConfirmationIfNeededAndConfirm(custodian: Custodian) {
    guard let credentials = custodian.externalCredentials,
          case let .oauth(oauthCredentials) = credentials,
          let userData = oauthCredentials.userData else {
      // If no data to confirm we just succeed
      saveBalanceStore(custodian: custodian)
      return
    }
    let module = serviceLocator.moduleLocator.dataConfirmationModule(userData: userData)
    module.onClose = { [unowned self] _ in
      self.popModule {
        self.dataConfirmationModule = nil
      }
    }
    module.onBack = { [unowned self] _ in
      self.popModule {
        self.dataConfirmationModule = nil
      }
    }
    module.onFinish = { [unowned self] _ in
      self.dataConfirmationModule = nil
      userData.removeDataPointsOf(type: self.projectConfiguration.primaryAuthCredential)
      self.shiftSession.updateUserData(userData) { _ in
        self.saveBalanceStore(custodian: custodian)
      }
    }
    self.dataConfirmationModule = module
    push(module: module) { _ in }
  }

  private func saveBalanceStore(custodian: Custodian) {
    showLoadingSpinner()
    shiftCardSession.setBalanceStore(self.application.id, custodian: custodian) { [weak self] result in
      self?.hideLoadingSpinner()
      switch result {
      case .failure(let error):
        self?.show(error: error)
      case .success(let balanceStoreResult):
        self?.process(result: balanceStoreResult)
      }
    }
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
