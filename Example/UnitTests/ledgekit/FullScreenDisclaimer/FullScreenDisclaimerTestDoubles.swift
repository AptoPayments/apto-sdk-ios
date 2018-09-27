//
//  FullScreenDisclaimerTestDoubles.swift
//  ShiftSDK
//
//  Created by Takeichi Kanzaki on 09/06/2018.
//
//

@testable import ShiftSDK

final class FullScreenDisclaimerPresenterSpy: FullScreenDisclaimerPresenterProtocol {
  let viewModel = FullScreenDisclaimerViewModel()
  weak var router: FullScreenDisclaimerRouterProtocol!
  var interactor: FullScreenDisclaimerInteractorProtocol!

  private(set) var viewLoadedCalled = false
  func viewLoaded() {
    viewLoadedCalled = true
  }

  private(set) var closeTappedCalled = false
  func closeTapped() {
    closeTappedCalled = true
  }

  private(set) var agreeTappedCalled = false
  func agreeTapped() {
    agreeTappedCalled = true
  }

  private(set) var linkTappedCalled = false
  private(set) var lastURL: URL?
  func linkTapped(_ url: URL) {
    lastURL = url
    linkTappedCalled = true
  }

  private(set) var setCalled = false
  private(set) var lastDisclaimer: Content?
  func set(disclaimer: Content) {
    lastDisclaimer = disclaimer
    setCalled = true
  }
}

final class FullScreenDisclaimerRouterSpy: FullScreenDisclaimerRouterProtocol {
  private(set) var closeCalled = false
  func close() {
    closeCalled = true
  }

  private(set) var showExternalCalled = false
  private(set) var lastURL: URL?
  private(set) var lastHeaders: [String: String]?
  private(set) var lastUseSafari: Bool?
  func showExternal(url: URL, headers: [String: String]?, useSafari: Bool?) {
    lastURL = url
    lastHeaders = headers
    lastUseSafari = useSafari
    showExternalCalled = true
  }

  private(set) var agreeTappedCalled = false
  func agreeTapped() {
    agreeTappedCalled = true
  }
}

class FullScreenDisclaimerInteractorSpy: FullScreenDisclaimerInteractorProtocol, Equatable {
  private(set) var provideDisclaimerCalled = false
  private(set) var lastProvideDisclaimerCompletion: ((_ disclaimer: Content) -> Void)?
  func provideDisclaimer(completion: @escaping((_ disclaimer: Content) -> Void)) {
    provideDisclaimerCalled = true
    lastProvideDisclaimerCompletion = completion
  }

  static func == (lhs: FullScreenDisclaimerInteractorSpy, rhs: FullScreenDisclaimerInteractorSpy) -> Bool {
    return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
  }
}

final class FullScreenDisclaimerInteractorFake: FullScreenDisclaimerInteractorSpy {
  let disclaimer: Content = .plainText("Disclaimer")

  override func provideDisclaimer(completion: @escaping ((Content) -> Void)) {
    super.provideDisclaimer(completion: completion)
    completion(disclaimer)
  }
}

final class FullScreenDisclaimerModuleSpy: UIModuleSpy, FullScreenDisclaimerModuleProtocol {
  var onDisclaimerAgreed: ((FullScreenDisclaimerModuleProtocol) -> Void)?
}
