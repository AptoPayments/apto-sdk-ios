//
// FullScreenDisclaimerContract.swift
// ShiftSDK
//
// Created by Takeichi Kanzaki on 15/11/2018.
//

import Bond

protocol FullScreenDisclaimerRouterProtocol: class {
  func close()
  func showExternal(url: URL, headers: [String:String]?, useSafari: Bool?)
  func agreeTapped()
}

protocol FullScreenDisclaimerInteractorProtocol {
  func provideDisclaimer(completion: @escaping((_ disclaimer: Content) -> Void))
}

class FullScreenDisclaimerViewModel {
  var disclaimer: Observable<Content?> = Observable(nil)
}

protocol FullScreenDisclaimerEventHandler: class {
  var viewModel: FullScreenDisclaimerViewModel { get }
  func viewLoaded()
  func closeTapped()
  func agreeTapped()
  func linkTapped(_ url: URL)
}

protocol FullScreenDisclaimerPresenterProtocol: FullScreenDisclaimerEventHandler {
  var router: FullScreenDisclaimerRouterProtocol! { get set }
  var interactor: FullScreenDisclaimerInteractorProtocol! { get set }
}

protocol FullScreenDisclaimerModuleProtocol: UIModuleProtocol {
  var onDisclaimerAgreed: ((_ fullScreenDisclaimerModule: FullScreenDisclaimerModuleProtocol) -> Void)? { get set }
}
