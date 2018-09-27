//
//  ExternalOAuthModuleTestDoubles.swift
//  ShiftSDK
//
//  Created by Takeichi Kanzaki on 04/07/2018.
//
//

@testable import ShiftSDK

class ExternalOAuthPresenterSpy: ExternalOAuthPresenterProtocol {
  // swiftlint:disable implicitly_unwrapped_optional
  var router: ExternalOAuthRouterProtocol!
  var interactor: ExternalOAuthInteractorProtocol!
  // swiftlint:enable implicitly_unwrapped_optional
  private(set) var viewModel = ExternalOAuthViewModel()

  private(set) var showErrorCalled = false
  private(set) var lastErrorShown: Error?
  func show(error: NSError) {
    showErrorCalled = true
    lastErrorShown = error
  }

  private(set) var showUrlCalled = false
  private(set) var lastUrlShown: URL?
  func show(url: URL) {
    showUrlCalled = true
    lastUrlShown = url
  }

  private(set) var custodianSelectedCalled = false
  private(set) var lastCustodianSelected: Custodian?
  func custodianSelected(_ custodian: Custodian) {
    custodianSelectedCalled = true
    lastCustodianSelected = custodian
  }

  private(set) var backTappedCalled = false
  func backTapped() {
    backTappedCalled = true
  }

  private(set) var custodianTappedCalled = false
  private(set) var lastCustodianTypeTapped: CustodianType?
  func custodianTapped(custodianType: CustodianType) {
    custodianTappedCalled = true
    lastCustodianTypeTapped = custodianType
  }
}

class ExternalOAuthModuleSpy: UIModuleSpy, ExternalOAuthModuleProtocol {
  var onOAuthSucceeded: ((_ externalOAuthModule: ExternalOAuthModuleProtocol, _ custodian: Custodian) -> Void)?

  override init(serviceLocator: ServiceLocatorProtocol) {
    super.init(serviceLocator: serviceLocator)
  }

  private(set) var backInExternalOAuthCalled = false
  private(set) var lastBackAnimated: Bool?
  func backInExternalOAuth(_ animated: Bool?) {
    backInExternalOAuthCalled = true
    lastBackAnimated = animated
  }

  private(set) var oauthSucceededCalled = false
  private(set) var lastOauthCustodian: Custodian?
  func oauthSucceeded(_ custodian: Custodian) {
    oauthSucceededCalled = true
    lastOauthCustodian = custodian
  }

  private(set) var showUrlCalled = false
  private(set) var lastUrlShown: URL?
  private(set) var lastShowUrlCompletion: (() -> ())?
  func show(url: URL, completion: @escaping () -> ()) {
    showUrlCalled = true
    lastUrlShown = url
    lastShowUrlCompletion = completion
  }

  func showLoadingSpinner() {
    showLoadingSpinner(position: .center)
  }
}

class ExternalOAuthModuleFake: ExternalOAuthModuleSpy {
  override func show(url: URL, completion: @escaping () -> ()) {
    super.show(url: url, completion: completion)

    completion()
  }

  override func oauthSucceeded(_ custodian: Custodian) {
    super.oauthSucceeded(custodian)

    onOAuthSucceeded?(self, custodian)
  }
}

class ExternalOAuthInteractorSpy: ExternalOAuthInteractorProtocol {
  var presenter: ExternalOAuthPresenterProtocol! // swiftlint:disable:this implicitly_unwrapped_optional

  private(set) var custodianSelectedCalled = false
  private(set) var lastCustodianTypeSelected: CustodianType?
  func custodianSelected(custodianType: CustodianType) {
    custodianSelectedCalled = true
    lastCustodianTypeSelected = custodianType
  }

  private(set) var custodianAuthenticationSucceedCalled = false
  func custodianAuthenticationSucceed() {
    custodianAuthenticationSucceedCalled = true
  }
}
