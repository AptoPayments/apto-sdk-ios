//
//  ShiftCardSettingsPresenter.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 25/03/2018.
//
//

import Foundation
import Stripe
import Bond

struct ShiftCardSettingsPresenterConfig {
  let showAddFundingSourceButton: Bool?
  let cardholderAgreement: Content?
  let privacyPolicy: Content?
  let termsAndCondition: Content?
  let faq: Content?
}

class ShiftCardSettingsPresenter: ShiftCardSettingsPresenterHandler {
  // swiftlint:disable implicitly_unwrapped_optional
  var view: ShiftCardSettingsViewProtocol!
  var interactor: ShiftCardSettingsInteractorProtocol!
  weak var router: ShiftCardSettingsRouterProtocol!
  // swiftlint:enable implicitly_unwrapped_optional
  var viewModel: ShiftCardSettingsViewModel
  private let card: Card
  private let rowsPerPage = 20
  private let enableCardAction: EnableCardAction
  private let disableCardAction: DisableCardAction
  private let showCardInfoAction: ShowCardInfoAction
  private let reportLostCardAction: ReportLostCardAction

  init(shiftCardSession: ShiftCardSession,
       card: Card,
       config: ShiftCardSettingsPresenterConfig,
       emailRecipients: [String?],
       uiConfig: ShiftUIConfig) {
    self.card = card
    self.viewModel = ShiftCardSettingsViewModel()
    self.enableCardAction = EnableCardAction(shiftCardSession: shiftCardSession,
                                             card: self.card,
                                             uiConfig: uiConfig)
    self.disableCardAction = DisableCardAction(shiftCardSession: shiftCardSession,
                                               card: self.card,
                                               uiConfig: uiConfig)
    self.reportLostCardAction = ReportLostCardAction(session: shiftCardSession,
                                                         card: card,
                                                         emailRecipients: emailRecipients,
                                                         uiConfig: uiConfig)
    self.showCardInfoAction = ShowCardInfoAction()
    self.viewModel.showAddFundingSourceButton.next(config.showAddFundingSourceButton)
    self.viewModel.cardHolderAgreement.next(config.cardholderAgreement)
    self.viewModel.termsAndConditions.next(config.termsAndCondition)
    self.viewModel.privacyPolicy.next(config.privacyPolicy)
    self.viewModel.faq.next(config.faq)
  }

  func viewLoaded() {
    refreshData()
  }

  func lockCardChanged(switcher: UISwitch) {
    if switcher.isOn {
      self.disableCardAction.run { result in
        switch result {
        case .failure:
          self.viewModel.locked.next(false)
          switcher.isOn = false
        case .success:
          self.viewModel.locked.next(true)
          self.router.cardStateChanged()
        }
      }
    }
    else {
      self.enableCardAction.run { result in
        switch result {
        case .failure:
          self.viewModel.locked.next(true)
        case .success:
          self.viewModel.locked.next(false)
          self.router.cardStateChanged()
        }
      }
    }
  }

  func showCardInfoChanged(switcher: UISwitch) {
    if switcher.isOn {
      self.showCardInfoAction.run { accessGranted in
        if !accessGranted {
          self.viewModel.showCardInfo.next(false)
        }
        else {
          self.router.showCardInfo()
        }
      }
    }
    else {
      viewModel.showCardInfo.next(false)
      router.hideCardInfo()
    }
  }

  fileprivate func refreshData() {
    view.showLoadingSpinner()
    viewModel.locked.next(card.state != .active)
    viewModel.showCardInfo.next(router.isCardInfoVisible())
    interactor.provideFundingSources(rows: rowsPerPage) { result in
      switch result {
      case .failure(let error):
        self.view.show(error: error)
      case .success(let fundingSources):
        self.interactor.activeCardFundingSource { result in
          self.view.hideLoadingSpinner()
          switch result {
          case .failure(let error):
            self.view.show(error: error)
          case .success(let activeFundingSource):
            self.viewModel.fundingSources.next(fundingSources)
            self.viewModel.activeFundingSource.next(activeFundingSource)
            if let idx = fundingSources.index(where: { $0.fundingSourceId == activeFundingSource?.fundingSourceId }) {
              self.viewModel.activeFundingSourceIdx.next(idx)
            }
            else {
              self.viewModel.activeFundingSourceIdx.next(nil)
            }
          }
        }
      }
    }
  }

  func previousTapped() {
    router.backFromShiftCardSettings()
  }

  func closeTapped() {
    router.closeFromShiftCardSettings()
  }

  func fundingSourceSelected(index: Int) {
    guard index != viewModel.activeFundingSourceIdx.value else {
      return
    }
    if index < viewModel.fundingSources.value.count {
      interactor.setActive(fundingSource: viewModel.fundingSources.value[index]) { _ in
        self.refreshData()
        self.router.fundingSourceChanged()
      }
    }
  }

  func addFundingSourceTapped() {
    router.addFundingSource { _ in
      self.refreshData()
    }
  }

  func lostCardTapped() {
    reportLostCardAction.run { [unowned self] result in
      switch result {
      case .failure(let error):
        if let serviceError = error as? ServiceError, serviceError.code == ServiceError.ErrorCodes.aborted.rawValue {
          // User aborted, do nothing
          return
        }
        self.view.show(error: error)
      case .success:
        self.viewModel.locked.next(true)
        self.router.cardStateChanged()
      }
    }
  }

  func changePinTapped() {
    router.changeCardPin()
  }

  func show(content: Content, title: String) {
    router.show(content: content, title: title)
  }
}
