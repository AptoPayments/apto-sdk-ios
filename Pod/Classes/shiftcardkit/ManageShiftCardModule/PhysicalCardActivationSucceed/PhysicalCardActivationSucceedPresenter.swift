//
//  PhysicalCardActivationSucceedPresenter.swift
//  ShiftSDK
//
// Created by Takeichi Kanzaki on 22/10/2018.
//

import Foundation

class PhysicalCardActivationSucceedPresenter: PhysicalCardActivationSucceedPresenterProtocol {
  let viewModel = PhysicalCardActivationSucceedViewModel()
  // swiftlint:disable implicitly_unwrapped_optional
  var interactor: PhysicalCardActivationSucceedInteractorProtocol!
  weak var router: PhysicalCardActivationSucceedRouter!
  // swiftlint:enable implicitly_unwrapped_optional

  func viewLoaded() {
    interactor.provideCard { [unowned self] card in
      if card.features?.ivr?.status == .enabled, let phoneNumber = card.features?.ivr?.phone {
        self.viewModel.showGetPinButton.next(true)
        self.viewModel.phoneNumber.next(phoneNumber)
      }
      else {
        self.viewModel.showGetPinButton.next(false)
        self.viewModel.phoneNumber.next(nil)
      }
    }
  }

  func getPinTapped() {
    // swiftlint:disable:next force_unwrapping
    if let url = PhoneHelper.sharedHelper().callURL(from: viewModel.phoneNumber.value) {
      router.call(url: url) { [unowned self] in
        self.router.getPinFinished()
      }
    }
    else {
      self.router.getPinFinished()
    }
  }

  func closeTapped() {
    if viewModel.showGetPinButton.value {
      router.close()
    }
    else {
      // If there is no get pin button closing trigger the finish flow
      router.getPinFinished()
    }
  }
}
