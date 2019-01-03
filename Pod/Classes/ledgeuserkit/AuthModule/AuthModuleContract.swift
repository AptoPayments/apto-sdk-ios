//
//  AuthModuleContract.swift
//  ShiftSDK
//
// Created by Takeichi Kanzaki on 30/10/2018.
//

protocol AuthRouterProtocol: class {
  func close()
  func back()
  func presentPhoneVerification(verificationType: VerificationParams<PhoneNumber, Verification>,
                                completion: (Result<Verification, NSError>.Callback)?)
  func presentEmailVerification(verificationType: VerificationParams<Email, Verification>,
                                completion: (Result<Verification, NSError>.Callback)?)
  func presentBirthdateVerification(verificationType: VerificationParams<BirthDate, Verification>,
                                    completion: (Result<Verification, NSError>.Callback)?)
  func returnExistingUser(_ user: ShiftUser)
}

protocol AuthInteractorProtocol {
  func provideAuthData()
  func nextTapped()
  func phoneVerificationSucceeded(_ verification: Verification)
  func phoneVerificationFailed()
  func emailVerificationSucceeded(_ verification: Verification)
  func emailVerificationFailed()
  func birthdateVerificationSucceeded(_ verification: Verification)
  func birthdateVerificationFailed()
}

protocol AuthViewProtocol {
  func setTitle(_ title: String)
  func show(fields: [FormRowView])
  func update(progress: Float)
  func showCancelButton()
  func showNextButton()
  func activateNextButton()
  func deactivateNextButton()
  func show(error: NSError)
  func showLoadingView()
  func hideLoadingView()
}

typealias AuthViewControllerProtocol = ShiftViewController & AuthViewProtocol

protocol AuthDataReceiver: class {
  func set(_ userData: DataPointList,
           primaryCredentialType: DataPointType,
           secondaryCredentialType: DataPointType)
  func show(error: NSError)
  func showPhoneVerification(verificationType: VerificationParams<PhoneNumber, Verification>)
  func showEmailVerification(verificationType: VerificationParams<Email, Verification>)
  func showBirthdateVerification(verificationType: VerificationParams<BirthDate, Verification>)
  func returnExistingUser(_ user: ShiftUser)
  func showLoadingView()
  func hideLoadingView()
}

protocol AuthEventHandler: class {
  func viewLoaded()
  func nextTapped()
  func closeTapped()
}

protocol AuthPresenterProtocol: AuthDataReceiver, AuthEventHandler {
  // swiftlint:disable implicitly_unwrapped_optional
  var viewController: AuthViewProtocol! { get set }
  var interactor: AuthInteractorProtocol! { get set }
  var router: AuthRouterProtocol! { get set }
  // swiftlint:enable implicitly_unwrapped_optional
}

protocol AuthModuleProtocol: UIModuleProtocol, AuthRouterProtocol {
  var onExistingUser: ((_ authModule: AuthModule, _ user: ShiftUser) -> Void)? { get set }
}
