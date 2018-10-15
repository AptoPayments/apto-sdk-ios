//
//  DataConfirmationTestDoubles.swift
//  ShiftSDK
//
//  Created by Takeichi Kanzaki on 25/09/2018.
//
//

@testable import ShiftSDK

class DataConfirmationModuleSpy: UIModuleSpy, DataConfirmationModuleProtocol {
  private(set) var confirmDataCalled = false
  func confirmData() {
    confirmDataCalled = true
  }
}

class DataConfirmationPresenterSpy: DataConfirmationPresenterProtocol {
  let viewModel = DataConfirmationViewModel()
  // swiftlint:disable implicitly_unwrapped_optional
  var interactor: DataConfirmationInteractorProtocol!
  var router: DataConfirmationRouter!
  // swiftlint:enable implicitly_unwrapped_optional

  private(set) var viewLoadedCalled = false
  func viewLoaded() {
    viewLoadedCalled = true
  }

  private(set) var confirmDataTappedCalled = false
  func confirmDataTapped() {
    confirmDataTappedCalled = true
  }

  private(set) var closeTappedCalled = false
  func closeTapped() {
    closeTappedCalled = true
  }
}

class DataConfirmationInteractorSpy: DataConfirmationInteractorProtocol {
  private(set) var provideUserDataCalled = false
  func provideUserData(completion: (_ userData: DataPointList) -> Void) {
    provideUserDataCalled = true
  }
}

class DataConfirmationInteractorFake: DataConfirmationInteractorSpy {
  var nextUserData: DataPointList?
  override func provideUserData(completion: (_ userData: DataPointList) -> Void) {
    super.provideUserData(completion: completion)

    if let nextUserData = nextUserData {
      completion(nextUserData)
    }
  }
}
