//
//  VerifyPhonePresenter.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 28/09/2016.
//
//

import Bond

protocol VerifyPhoneRouterProtocol: class {
  func closeTappedInVerifyPhone()
  func phoneVerificationPassed(verification: Verification)
}

protocol VerifyPhoneInteractorProtocol: class {
  func providePhoneNumber()
  func resendPin()
  func submitPin(_ pin: String)
}

class VerifyPhonePresenter: PINVerificationPresenter, VerifyPhoneDataReceiver {
  // swiftlint:disable implicitly_unwrapped_optional
  var interactor: VerifyPhoneInteractorProtocol!
  weak var router: VerifyPhoneRouterProtocol!
  var view: PINVerificationView!
  // swiftlint:enable implicitly_unwrapped_optional
  let viewModel = PINVerificationViewModel()

  func viewLoaded() {
    viewModel.title.next("verify_phone.title".podLocalized())
    viewModel.subtitle.next("verify_phone.label.title".podLocalized())
    viewModel.resendButtonTitle.next("verify_phone.resend_button.title".podLocalized())
    interactor.providePhoneNumber()
  }

  func submitTapped(_ pin: String) {
    view.showLoadingSpinner()
    interactor.submitPin(pin)
  }

  func resendTapped() {
    view.showLoadingSpinner()
    interactor.resendPin()
  }

  func closeTapped() {
    router.closeTappedInVerifyPhone()
  }

  func phoneNumberReceived(_ phone: PhoneNumber) {
    guard let nationalNumber = phone.phoneNumber.value else {
      viewModel.datapointValue.next("??")
      return
    }
    let phoneNumber = PhoneHelper.sharedHelper().formatPhoneWith(countryCode: phone.countryCode.value,
                                                                 nationalNumber: nationalNumber)
    viewModel.datapointValue.next(phoneNumber)
  }

  func unknownPhoneNumber() {
    viewModel.datapointValue.next("")
  }

  func verificationReceived(_ verification: Verification) {
    view.hideLoadingSpinner()
  }

  func sendPinError(_ error: NSError) {
    view.show(error: error)
  }

  func sendPinSuccess() {
    view.hideLoadingSpinner()
  }

  func pinVerificationSucceeded(_ verification: Verification) {
    view.hideLoadingSpinner()
    router.phoneVerificationPassed(verification: verification)
  }

  func pinVerificationFailed() {
    view.hideLoadingSpinner()
    view.showWrongPinError(error: BackendError(code: .phoneVerificationFailed))
  }
}
