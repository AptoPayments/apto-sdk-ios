//
//  ContentPresenterContracts.swift
//  ShiftSDK
//
//  Created by Takeichi Kanzaki on 17/09/2018.
//

import Bond

protocol ContentPresenterRouter: class {
  func close()
  func show(url: URL)
}

protocol ContentPresenterModuleProtocol: UIModuleProtocol, ContentPresenterRouter {
}

protocol ContentPresenterInteractorProtocol {
  func provideContent(completion: (_ content: Content) -> Void)
}

class ContentPresenterViewModel {
  var content: Observable<Content?> = Observable(nil)
}

protocol ContentPresenterPresenterProtocol: class {
  var viewModel: ContentPresenterViewModel { get }
  // swiftlint:disable implicitly_unwrapped_optional
  var interactor: ContentPresenterInteractorProtocol! { get set }
  var router: ContentPresenterRouter! { get set }
  // swiftlint:enable implicitly_unwrapped_optional

  func viewLoaded()
  func closeTapped()
  func linkTapped(_ url: URL)
}
