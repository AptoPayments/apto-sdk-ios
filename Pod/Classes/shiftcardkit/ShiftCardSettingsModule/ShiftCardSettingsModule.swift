//
//  ShiftCardSettingsModule.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 25/03/2018.
//

import UIKit

class ShiftCardSettingsModule: UIModule {
  private let card: Card
  private let caller: PhoneCallerProtocol
  private var projectConfiguration: ProjectConfiguration! // swiftlint:disable:this implicitly_unwrapped_optional
  private var externalOAuthModule: ExternalOAuthModule?
  private var presenter: ShiftCardSettingsPresenter?
  private var changePinAction: ChangeCardPINAction?
  private var contentPresenterModule: ContentPresenterModuleProtocol?

  weak var delegate: ShiftCardSettingsModuleDelegate?

  public init(serviceLocator: ServiceLocatorProtocol, card: Card, phoneCaller: PhoneCallerProtocol) {
    self.card = card
    self.caller = phoneCaller
    super.init(serviceLocator: serviceLocator)
  }

  override func initialize(completion: @escaping Result<UIViewController, NSError>.Callback) {
    shiftSession.contextConfiguration { result in
      switch result {
      case .failure(let error):
        completion(.failure(error))
      case .success(let contextConfiguration):
        self.shiftSession.shiftCardSession.shiftCardConfiguration { result in
          switch result {
          case .failure(let error):
            completion(.failure(error))
          case .success(let shiftCardConfiguration):
            self.projectConfiguration = contextConfiguration.projectConfiguration
            let viewController = self.buildShiftCardSettingsViewController(
              self.uiConfig,
              shiftCardConfiguration: shiftCardConfiguration,
              card: self.card)
            self.addChild(viewController: viewController, completion: completion)
          }
        }
      }
    }
  }

  fileprivate func buildShiftCardSettingsViewController(_ uiConfig: ShiftUIConfig,
                                                        shiftCardConfiguration: ShiftCardConfiguration,
                                                        card: Card) -> ShiftCardSettingsViewController {
    let showBalancesSection = shiftCardConfiguration.isFeatureEnabled(.showBalancesSection)
    let cardProduct = shiftCardConfiguration.cardProduct
    let presenterConfig = ShiftCardSettingsPresenterConfig(showBalancesSection: showBalancesSection,
                                                           cardholderAgreement: cardProduct.cardholderAgreement,
                                                           privacyPolicy: cardProduct.privacyPolicy,
                                                           termsAndCondition: cardProduct.termsAndConditions,
                                                           faq: cardProduct.faq)
    let presenter = ShiftCardSettingsPresenter(shiftCardSession: shiftSession.shiftCardSession,
                                               card: card,
                                               config: presenterConfig,
                                               emailRecipients: [self.projectConfiguration.supportEmailAddress],
                                               uiConfig: uiConfig)
    let interactor = ShiftCardSettingsInteractor(shiftSession: shiftSession, card: card)
    let viewController = ShiftCardSettingsViewController(uiConfiguration: uiConfig, presenter: presenter)
    presenter.router = self
    presenter.interactor = interactor
    presenter.view = viewController
    self.presenter = presenter
    return viewController
  }
}

extension ShiftCardSettingsModule: ShiftCardSettingsRouterProtocol {
  func backFromShiftCardSettings() {
    back()
  }

  func closeFromShiftCardSettings() {
    close()
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
      guard let wself = self else {
        return
      }
      wself.showLoadingSpinner()
      wself.shiftSession.addFinancialAccountFundingSource(accountId: wself.card.accountId,
                                                          custodian: custodian) { result in
        switch result {
        case .failure(let error):
          UIApplication.topViewController()?.show(error: error)
        case .success(let fundingSource):
          self?.hideLoadingSpinner()
          self?.popModule {
            self?.externalOAuthModule = nil
            completion(fundingSource)
          }
        }
      }
    }
    externalOAuthModule.onBack = { module in
      self.popModule {
        self.externalOAuthModule = nil
      }
    }
    self.externalOAuthModule = externalOAuthModule
    push(module: externalOAuthModule) { _ in }
  }

  func changeCardPin() {
    let action = ChangeCardPINAction(shiftCardSession: shiftSession.shiftCardSession,
                                     card: card,
                                     uiConfig: self.uiConfig)
    action.run()
    self.changePinAction = action
  }

  func call(url: URL, completion: @escaping () -> Void) {
    caller.call(phoneNumberURL: url, from: self, completion: completion)
  }

  func showCardInfo() {
    delegate?.showCardInfo()
  }

  func hideCardInfo() {
    delegate?.hideCardInfo()
  }

  func isCardInfoVisible() -> Bool {
    return delegate?.isCardInfoVisible() ?? false
  }

  func cardStateChanged() {
    delegate?.cardStateChanged()
  }

  func show(content: Content, title: String) {
    let module = serviceLocator.moduleLocator.contentPresenterModule(content: content, title: title)
    module.onClose = { [unowned self] _ in
      self.dismissModule {
        self.contentPresenterModule = nil
      }
    }
    contentPresenterModule =  module
    present(module: module, leftButtonMode: .close) { _ in }
  }

  func fundingSourceChanged() {
    delegate?.fundingSourceChanged()
  }
}
