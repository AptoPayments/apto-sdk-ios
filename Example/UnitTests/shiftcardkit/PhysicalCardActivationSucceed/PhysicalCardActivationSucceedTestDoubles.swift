//
//  PhysicalCardActivationSucceedTestDoubles.swift
//  ShifSDK
//
//  Created by Takeichi Kanzaki on 22/10/2018.
//

@testable import ShiftSDK

class PhysicalCardActivationSucceedPresenterSpy: PhysicalCardActivationSucceedPresenterProtocol {
  let viewModel = PhysicalCardActivationSucceedViewModel()
  // swiftlint:disable implicitly_unwrapped_optional
  var interactor: PhysicalCardActivationSucceedInteractorProtocol!
  weak var router: PhysicalCardActivationSucceedRouter!
  // swiftlint:enable implicitly_unwrapped_optional

  private(set) var viewLoadedCalled = false
  func viewLoaded() {
    viewLoadedCalled = true
  }

  private(set) var getPinTappedCalled = false
  func getPinTapped() {
    getPinTappedCalled = true
  }

  private(set) var closeTappedCalled = false
  func closeTapped() {
    closeTappedCalled = true
  }
}

class PhysicalCardActivationSucceedInteractorSpy: PhysicalCardActivationSucceedInteractorProtocol {
  var card = ModelDataProvider.provider.cardWithIVR

  private(set) var provideCardCalled = false
  func provideCard(callback: (_ card: Card) -> Void) {
    provideCardCalled = true
  }
}

class PhysicalCardActivationSucceedInteractorFake: PhysicalCardActivationSucceedInteractorSpy {
  override func provideCard(callback: (_ card: Card) -> Void) {
    super.provideCard(callback: callback)
    callback(card)
  }
}

class PhysicalCardActivationSucceedModuleSpy: UIModuleSpy, PhysicalCardActivationSucceedModuleProtocol {
  private(set) var callURLCalled = false
  func call(url: URL, completion: () -> Void) {
    callURLCalled = true
  }

  private(set) var getPinFinishedCalled = false
  func getPinFinished() {
    getPinFinishedCalled = true
  }
}

class PhysicalCardActivationSucceedModuleFake: PhysicalCardActivationSucceedModuleSpy {
  override func call(url: URL, completion: () -> Void) {
    super.call(url: url, completion: completion)
    completion()
  }
}
