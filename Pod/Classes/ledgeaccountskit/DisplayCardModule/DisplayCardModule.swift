//
//  DisplayCardModule.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 25/10/2017.
//
//

import UIKit

class DisplayCardModule: UIModule {

  let card: Card
  let initialCardAmount: Amount?

  init(serviceLocator: ServiceLocatorProtocol, card:Card, initialCardAmount: Amount?) {
    self.card = card
    self.initialCardAmount = initialCardAmount
    super.init(serviceLocator: serviceLocator)
  }

  override func initialize(completion: @escaping Result<UIViewController, NSError>.Callback){
    shiftSession.contextConfiguration { result in
      switch result {
      case .failure (let error):
        completion(.failure(error))
      case .success(let contextConfiguration):
        self.uiConfig = ShiftUIConfig(projectConfiguration: contextConfiguration.projectConfiguration)
        let viewController = self.buildDisplayCardViewController(self.uiConfig!, card:self.card)
        self.addChild(viewController: viewController, completion: completion)
      }
    }
  }

  fileprivate func buildDisplayCardViewController(_ uiConfig:ShiftUIConfig, card:Card) -> UIViewController {
    let presenter = DisplayCardPresenter()
    let interactor = DisplayCardInteractor(shiftSession: shiftSession, accountId:card.accountId, initialCardAmount: initialCardAmount)
    let viewController = DisplayCardViewController(uiConfiguration: uiConfig, eventHandler: presenter)
    presenter.router = self
    presenter.interactor = interactor
    presenter.view = viewController
    return viewController
  }

}

extension DisplayCardModule: DisplayCardRouterProtocol {

  func backFromCardViewer() {
    self.back()
  }

  func doneFromCardViewer() {
    self.close()
  }

}
