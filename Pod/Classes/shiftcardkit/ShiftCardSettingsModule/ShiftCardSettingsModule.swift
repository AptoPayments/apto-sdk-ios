//
//  ShiftCardSettingsModule.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 25/03/2018.
//

import UIKit

class ShiftCardSettingsModule: UIModule, ShiftCardSettingsModuleProtocol {
  private let card: Card
  private let caller: PhoneCallerProtocol
  private var projectConfiguration: ProjectConfiguration! // swiftlint:disable:this implicitly_unwrapped_optional
  private var presenter: ShiftCardSettingsPresenterProtocol?
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
                                                        card: Card) -> ShiftViewController {
    let cardProduct = shiftCardConfiguration.cardProduct
    let presenterConfig = ShiftCardSettingsPresenterConfig(cardholderAgreement: cardProduct.cardholderAgreement,
                                                           privacyPolicy: cardProduct.privacyPolicy,
                                                           termsAndCondition: cardProduct.termsAndConditions,
                                                           faq: cardProduct.faq)
    let recipients = [self.projectConfiguration.supportEmailAddress]
    let presenter = serviceLocator.presenterLocator.cardSettingsPresenter(cardSession: shiftSession.shiftCardSession,
                                                                          card: card,
                                                                          config: presenterConfig,
                                                                          emailRecipients: recipients,
                                                                          uiConfig: uiConfig)
    let interactor = serviceLocator.interactorLocator.cardSettingsInteractor()
    let viewController = serviceLocator.viewLocator.cardSettingsView(presenter: presenter)
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
}
