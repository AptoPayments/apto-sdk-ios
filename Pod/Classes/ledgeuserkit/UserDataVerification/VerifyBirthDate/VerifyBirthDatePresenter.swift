//
//  VerifyBirthDatePresenter.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 28/09/2016.
//
//

import Bond

protocol VerifyBirthDateRouterProtocol: class {
  func closeTappedInVerifyBirthDate()
  func birthDateVerificationPassed(verification: Verification)
}

protocol VerifyBirthDateInteractorProtocol {
  func provideBirthDate()
  func submit(birthDate: Date)
}

protocol VerifyBirthDateViewControllerProtocol: ViewControllerProtocol {
  func showWrongBirthDateErrorMessage()
  func showLoadingSpinner()
}

class VerifyBirthDatePresenter: VerifyBirthDateEventHandler, VerifyBirthDateDataReceiver {
  // swiftlint:disable implicitly_unwrapped_optional
  var interactor: VerifyBirthDateInteractorProtocol!
  weak var router: VerifyBirthDateRouterProtocol!
  var view: VerifyBirthDateViewControllerProtocol!
  // swiftlint:enable implicitly_unwrapped_optional

  func viewLoaded() {
    view.showLoadingSpinner()
    interactor.provideBirthDate()
  }

  func verificationReceived(_ verification: Verification) {
    view.hideLoadingSpinner()
  }

  func verificationStartError(_ error: NSError) {
    view.hideLoadingSpinner()
    view.show(error: error)
  }

  func submitTapped(_ birthDate: Date) {
    view.showLoadingSpinner()
    interactor.submit(birthDate: birthDate)
  }

  func closeTapped() {
    router.closeTappedInVerifyBirthDate()
  }

  func submitBirthDateError(_ error: NSError) {
    view.hideLoadingSpinner()
    view.show(error: error)
  }

  func verificationSucceeded(_ verification: Verification) {
    view.hideLoadingSpinner()
    router.birthDateVerificationPassed(verification: verification)
  }

  func verificationFailed() {
    view.hideLoadingSpinner()
    view.showWrongBirthDateErrorMessage()
  }
}
