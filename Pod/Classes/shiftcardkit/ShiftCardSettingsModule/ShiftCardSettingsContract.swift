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
  func call(url: URL, completion: @escaping () -> Void)
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
  open var expendableBalance: Observable<Amount?> = Observable(nil)
  open var fundingSources: Observable<[FundingSource]> = Observable([])
  open var fundingSourcesLoaded: Observable<Bool> = Observable(false)
  open var activeFundingSource: Observable<FundingSource?> = Observable(nil)
  open var activeFundingSourceIdx: Observable<Int?> = Observable(nil)
  open var showBalancesSection: Observable<Bool?> = Observable(nil)
  open var locked: Observable<Bool?> = Observable(nil)
  open var showCardInfo: Observable<Bool?> = Observable(nil)
  open var legalDocuments: Observable<LegalDocuments> = Observable(LegalDocuments())
  open var showChangePin: Observable<Bool> = Observable(false)
  open var showGetPin: Observable<Bool> = Observable(false)
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
  func getPinTapped()
  func lockCardChanged(switcher: UISwitch)
  func showCardInfoChanged(switcher: UISwitch)
  func show(content: Content, title: String)
}
