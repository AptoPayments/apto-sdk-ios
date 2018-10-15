//
//  ExternalOAuthContract.swift
//  ShiftSDK
//
//  Created by Takeichi Kanzaki on 25/09/2018.
//

import Bond

protocol ExternalOAuthModuleProtocol: UIModuleProtocol, ExternalOAuthRouterProtocol {
  var onOAuthSucceeded: ((_ externalOAuthModule: ExternalOAuthModuleProtocol,
                          _ custodian: Custodian) -> Void)? { get set }
}

protocol ExternalOAuthPresenterProtocol: class {
  // swiftlint:disable implicitly_unwrapped_optional
  var router: ExternalOAuthRouterProtocol! { get set }
  var interactor: ExternalOAuthInteractorProtocol! { get set }
  // swiftlint:enable implicitly_unwrapped_optional
  var viewModel: ExternalOAuthViewModel { get }
  func show(error: NSError)
  func show(url: URL)
  func custodianSelected(_ custodian: Custodian)
  func backTapped()
  func custodianTapped(custodianType: CustodianType)
}

protocol ExternalOAuthRouterProtocol: class {
  func backInExternalOAuth(_ animated: Bool?)
  func oauthSucceeded(_ custodian: Custodian)
  func show(url: URL, completion: @escaping () -> ())
  func showLoadingSpinner()
  func hideLoadingSpinner()
}

protocol ExternalOAuthInteractorProtocol {
  var presenter: ExternalOAuthPresenterProtocol! { get set } // swiftlint:disable:this implicitly_unwrapped_optional
  func custodianSelected(custodianType: CustodianType)
  func custodianAuthenticationSucceed()
}

protocol ExternalOAuthViewProtocol: ViewControllerProtocol {}

class ExternalOAuthViewModel {
  var title: Observable<String?> = Observable(nil)
  var imageName: Observable<String?> = Observable(nil)
  var provider: Observable<String?> = Observable(nil)
  var accessDescription: Observable<String?> = Observable(nil)
  var callToActionTitle: Observable<String?> = Observable(nil)
  var description: Observable<String?> = Observable(nil)
  var error: Observable<Error?> = Observable(nil)
}
