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
  func fundingSourceChanged()
}

protocol ShiftCardSettingsRouterProtocol: class {
  func backFromShiftCardSettings()
  func closeFromShiftCardSettings()
  func addFundingSource(completion: @escaping (FundingSource) -> Void)
  func changeCardPin()
  func showCardInfo()
  func hideCardInfo()
  func isCardInfoVisible() -> Bool
  func cardStateChanged()
  func show(content: Content, title: String)
  func fundingSourceChanged()
}

protocol ShiftCardSettingsViewProtocol: ViewControllerProtocol {
  func showLoadingSpinner()
}

protocol ShiftCardSettingsInteractorProtocol {
  func provideFundingSources(rows: Int, callback: @escaping Result<[FundingSource], NSError>.Callback)
  func activeCardFundingSource(callback: @escaping Result<FundingSource?, NSError>.Callback)
  func setActive(fundingSource: FundingSource, callback: @escaping Result<FundingSource, NSError>.Callback)
}

open class ShiftCardSettingsViewModel {
  open var expendableBalance: Observable<Amount?> = Observable(nil)
  open var fundingSources: Observable<[FundingSource]> = Observable([])
  open var activeFundingSource: Observable<FundingSource?> = Observable(nil)
  open var activeFundingSourceIdx: Observable<Int?> = Observable(nil)
  open var showBalancesSection: Observable<Bool?> = Observable(nil)
  open var locked: Observable<Bool?> = Observable(nil)
  open var showCardInfo: Observable<Bool?> = Observable(nil)
  open var cardHolderAgreement: Observable<Content?> = Observable(nil)
  open var faq: Observable<Content?> = Observable(nil)
  open var termsAndConditions: Observable<Content?> = Observable(nil)
  open var privacyPolicy: Observable<Content?> = Observable(nil)
}

protocol ShiftCardSettingsPresenterHandler: class {
  var viewModel: ShiftCardSettingsViewModel { get }
  func viewLoaded()
  func previousTapped()
  func closeTapped()
  func fundingSourceSelected(index: Int)
  func addFundingSourceTapped()
  func lostCardTapped()
  func changePinTapped()
  func lockCardChanged(switcher: UISwitch)
  func showCardInfoChanged(switcher: UISwitch)
  func show(content: Content, title: String)
}
