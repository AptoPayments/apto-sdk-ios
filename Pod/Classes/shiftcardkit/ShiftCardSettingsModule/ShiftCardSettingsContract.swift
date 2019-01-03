//
//  ShiftCardSettingsContract.swift
//  ShiftSDK
//
//  Created by Takeichi Kanzaki on 17/08/2018.
//
//

import Bond

protocol ShiftCardSettingsModuleDelegate: class {
  func showCardInfo()
  func hideCardInfo()
  func isCardInfoVisible() -> Bool
  func cardStateChanged()
}

protocol ShiftCardSettingsRouterProtocol: class {
  func backFromShiftCardSettings()
  func closeFromShiftCardSettings()
  func changeCardPin()
  func call(url: URL, completion: @escaping () -> Void)
  func showCardInfo()
  func hideCardInfo()
  func isCardInfoVisible() -> Bool
  func cardStateChanged()
  func show(content: Content, title: String)
}

protocol ShiftCardSettingsModuleProtocol: UIModuleProtocol {
  var delegate: ShiftCardSettingsModuleDelegate? { get set }
}

protocol ShiftCardSettingsViewProtocol: ViewControllerProtocol {
  func showLoadingSpinner()
  func show(error: Error)
}

typealias ShiftCardSettingsViewControllerProtocol = ShiftViewController & ShiftCardSettingsViewProtocol

protocol ShiftCardSettingsInteractorProtocol {
}

public struct LegalDocuments {
  public let cardHolderAgreement: Content?
  public let faq: Content?
  public let termsAndConditions: Content?
  public let privacyPolicy: Content?
}

extension LegalDocuments {
  init() {
    self.init(cardHolderAgreement: nil, faq: nil, termsAndConditions: nil, privacyPolicy: nil)
  }
}

open class ShiftCardSettingsViewModel {
  public let locked: Observable<Bool?> = Observable(nil)
  public let showCardInfo: Observable<Bool?> = Observable(nil)
  public let legalDocuments: Observable<LegalDocuments> = Observable(LegalDocuments())
  public let showChangePin: Observable<Bool> = Observable(false)
  public let showGetPin: Observable<Bool> = Observable(false)
}

protocol ShiftCardSettingsPresenterProtocol: class {
  // swiftlint:disable implicitly_unwrapped_optional
  var view: ShiftCardSettingsViewProtocol! { get set }
  var interactor: ShiftCardSettingsInteractorProtocol! { get set }
  var router: ShiftCardSettingsRouterProtocol! { get set }
  // swiftlint:enable implicitly_unwrapped_optional
  var viewModel: ShiftCardSettingsViewModel { get }

  func viewLoaded()
  func previousTapped()
  func closeTapped()
  func helpTapped()
  func lostCardTapped()
  func changePinTapped()
  func getPinTapped()
  func lockCardChanged(switcher: UISwitch)
  func showCardInfoChanged(switcher: UISwitch)
  func show(content: Content, title: String)
}
