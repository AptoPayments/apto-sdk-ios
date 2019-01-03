//
// VerifyBirthDateContract.swift
// ShiftSDK
//
// Created by Takeichi Kanzaki on 12/11/2018.
//

protocol VerifyBirthDateModuleProtocol: UIModuleProtocol {
  var onVerificationPassed: ((_ verifyBirthDateModule: VerifyBirthDateModule,
                              _ verification: Verification) -> Void)? { get set }
}

protocol VerifyBirthDateRouterProtocol: class {
  func closeTappedInVerifyBirthDate()
  func birthDateVerificationPassed(verification: Verification)
}

protocol VerifyBirthDateInteractorProtocol {
  func provideBirthDate()
  func submit(birthDate: Date)
}

protocol VerifyBirthDateEventHandler: class {
  func viewLoaded()
  func submitTapped(_ birthDate: Date)
  func closeTapped()
}

protocol VerifyBirthDateDataReceiver: class {
  func submitBirthDateError(_ error: NSError)
  func verificationStartError(_ error: NSError)
  func verificationReceived(_ verification: Verification)
  func verificationSucceeded(_ verification: Verification)
  func verificationFailed()
}

protocol VerifyBirthDatePresenterProtocol: VerifyBirthDateEventHandler, VerifyBirthDateDataReceiver {
  // swiftlint:disable implicitly_unwrapped_optional
  var interactor: VerifyBirthDateInteractorProtocol! { get set }
  var router: VerifyBirthDateRouterProtocol! { get set }
  var view: VerifyBirthDateViewProtocol! { get set }
  // swiftlint:enable implicitly_unwrapped_optional
}

protocol VerifyBirthDateViewProtocol: ViewControllerProtocol {
  func showWrongBirthDateErrorMessage()
  func showLoadingSpinner()
  func show(error: Error)
}

typealias VerifyBirthDateViewControllerProtocol = VerifyBirthDateViewProtocol & ShiftViewController
