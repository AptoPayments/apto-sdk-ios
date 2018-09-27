//
//  AccountSettingsModule.swift
//  ShiftSDK
//
//  Created by Takeichi Kanzaki on 17/08/2018.
//

import UIKit

class AccountSettingsModule: UIModule {
  private var projectConfiguration: ProjectConfiguration! // swiftlint:disable:this implicitly_unwrapped_optional
  private var mailSender: MailSender?
  private var presenter: AccountSettingsPresenterProtocol?

  override func initialize(completion: @escaping Result<UIViewController, NSError>.Callback) {
    shiftSession.contextConfiguration { result in
      switch result {
      case .failure(let error):
        completion(.failure(error))
      case .success(let contextConfiguration):
        let config = ShiftUIConfig(projectConfiguration: contextConfiguration.projectConfiguration)
        self.uiConfig = config
        self.projectConfiguration = contextConfiguration.projectConfiguration
        let viewController = self.buildAccountSettingsViewController(config)
        self.addChild(viewController: viewController, completion: completion)
      }
    }
  }

  fileprivate func buildAccountSettingsViewController(_ uiConfig: ShiftUIConfig) -> AccountSettingsViewProtocol {
    let presenter = serviceLocator.presenterLocator.accountSettingsPresenter()
    let interactor = serviceLocator.interactorLocator.accountSettingsInteractor()
    let viewController = serviceLocator.viewLocator.accountsSettingsView(uiConfig: uiConfig, presenter: presenter)
    presenter.router = self
    presenter.interactor = interactor
    presenter.view = viewController
    self.presenter = presenter
    return viewController
  }
}

extension AccountSettingsModule: AccountSettingsRouterProtocol {
  func backFromAccountSettings() {
    back()
  }

  func closeFromAccountSettings() {
    close()
  }

  func contactTappedInAccountSettings() {
    let mailSender = MailSender()
    self.mailSender = mailSender
    mailSender.sendMessageWith(subject: "email.support.subject".podLocalized(),
                               message: "",
                               recipients: [self.projectConfiguration.supportEmailAddress])
  }
}
