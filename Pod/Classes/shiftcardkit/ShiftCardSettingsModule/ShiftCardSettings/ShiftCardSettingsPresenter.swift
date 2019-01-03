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
  let cardholderAgreement: Content?
  let privacyPolicy: Content?
  let termsAndCondition: Content?
  let faq: Content?
}

class ShiftCardSettingsPresenter: ShiftCardSettingsPresenterProtocol {
  // swiftlint:disable implicitly_unwrapped_optional
  var view: ShiftCardSettingsViewProtocol!
  var interactor: ShiftCardSettingsInteractorProtocol!
  weak var router: ShiftCardSettingsRouterProtocol!
  // swiftlint:enable implicitly_unwrapped_optional
  let viewModel: ShiftCardSettingsViewModel
  private let card: Card
  private let rowsPerPage = 20
  private let enableCardAction: EnableCardAction
  private let disableCardAction: DisableCardAction
  private let showCardInfoAction: ShowCardInfoAction
  private let reportLostCardAction: ReportLostCardAction
  private let helpAction: HelpAction
  private let config: ShiftCardSettingsPresenterConfig

  init(shiftCardSession: ShiftCardSession,
       card: Card,
       config: ShiftCardSettingsPresenterConfig,
       emailRecipients: [String?],
       uiConfig: ShiftUIConfig) {
    self.card = card
    self.config = config
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
    self.helpAction = HelpAction(emailRecipients: emailRecipients)
    let legalDocuments = LegalDocuments(cardHolderAgreement: config.cardholderAgreement,
                                        faq: config.faq,
                                        termsAndConditions: config.termsAndCondition,
                                        privacyPolicy: config.privacyPolicy)
    self.viewModel.legalDocuments.next(legalDocuments)
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
    viewModel.showChangePin.next(card.features?.changePin == .enabled)
    viewModel.showGetPin.next(card.features?.ivr?.status == .enabled)
    viewModel.locked.next(card.state != .active)
    viewModel.showCardInfo.next(router.isCardInfoVisible())
  }

  func previousTapped() {
    router.backFromShiftCardSettings()
  }

  func closeTapped() {
    router.closeFromShiftCardSettings()
  }

  func helpTapped() {
    helpAction.run()
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

  func getPinTapped() {
    guard let url = PhoneHelper.sharedHelper().callURL(from: card.features?.ivr?.phone) else {
      return
    }

    router.call(url: url) { [unowned self] in
      self.router.cardStateChanged()
    }
  }

  func show(content: Content, title: String) {
    router.show(content: content, title: title)
  }
}
