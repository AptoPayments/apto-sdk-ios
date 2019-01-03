//
//  DataConfirmationContract.swift
//  ShiftSDK
//
//  Created by Takeichi Kanzaki on 25/09/2018.
//

import Bond

protocol DataConfirmationRouter: class {
  func confirmData()
  func close()
  func show(url: URL)
}

protocol DataConfirmationModuleProtocol: UIModuleProtocol, DataConfirmationRouter {
}

class DataConfirmationViewModel {
  var userData: Observable<DataPointList?> = Observable(nil)
}

protocol DataConfirmationPresenterProtocol: class {
  var viewModel: DataConfirmationViewModel { get }
  // swiftlint:disable implicitly_unwrapped_optional
  var interactor: DataConfirmationInteractorProtocol! { get set }
  var router: DataConfirmationRouter! { get set }
  // swiftlint:enable implicitly_unwrapped_optional

  func viewLoaded()
  func confirmDataTapped()
  func closeTapped()
  func show(url: URL)
}

protocol DataConfirmationInteractorProtocol {
  func provideUserData(completion: (_ userData: DataPointList) -> Void)
}
