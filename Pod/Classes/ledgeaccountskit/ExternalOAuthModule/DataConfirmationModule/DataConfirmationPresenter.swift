//
//  DataConfirmationPresenter.swift
//  ShiftSDK
//
//  Created by Takeichi Kanzaki on 25/09/2018.
//
//

class DataConfirmationPresenter: DataConfirmationPresenterProtocol {
  let viewModel = DataConfirmationViewModel()
  var interactor: DataConfirmationInteractorProtocol! // swiftlint:disable:this implicitly_unwrapped_optional
  weak var router: DataConfirmationRouter! // swiftlint:disable:this implicitly_unwrapped_optional

  func viewLoaded() {
    interactor.provideUserData { [unowned self] userData in
      self.viewModel.userData.next(userData)
    }
  }

  func confirmDataTapped() {
    router.confirmData()
  }

  func closeTapped() {
    router.close()
  }

  func show(url: URL) {
    router.show(url: url)
  }
}
