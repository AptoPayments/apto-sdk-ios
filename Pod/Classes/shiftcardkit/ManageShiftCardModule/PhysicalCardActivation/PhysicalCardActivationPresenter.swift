//
// PhysicalCardActivationPresenter.swift
// ShiftSDK
//
// Created by Takeichi Kanzaki on 2018-12-10.
//

import Foundation
import Bond

class PhysicalCardActivationPresenter: PhysicalCardActivationPresenterProtocol {
  let viewModel = PhysicalCardActivationViewModel()
  weak var router: PhysicalCardActivationModuleProtocol?
  var interactor: PhysicalCardActivationInteractorProtocol?
  private var card: Card?

  func viewLoaded() {
    router?.showLoadingView()
    interactor?.fetchCard { [weak self] result in
      guard let self = self else { return }
      self.router?.hideLoadingView()
      switch result {
      case .failure(let error):
        self.router?.show(error: error)
      case .success(let card):
        self.router?.showLoadingView()
        self.updateViewModel(with: card)
        self.card = card
        self.interactor?.fetchCurrentUser { [weak self] result in
          guard let self = self else { return }
          self.router?.hideLoadingView()
          switch result {
          case .failure(let error):
            self.router?.show(error: error)
          case .success(let user):
            self.updateViewModel(with: user)
          }
        }
      }
    }
  }

  func activateCardTapped() {
    guard let cardActivation = card?.features?.activation else { return }
    switch cardActivation.type {
    case .api:
      showPhysicalCardActivationByCode()
    case .ivr(let ivr):
      if let url = PhoneHelper.sharedHelper().callURL(from: ivr.phone) {
        router?.call(url: url) { [weak self] in
          self?.router?.cardActivationFinish()
        }
      }
    }
  }

  func show(url: URL) {
    router?.show(url: url)
  }

  // MARK: - Private methods
  private func updateViewModel(with card: Card) {
    viewModel.cardHolder.next(card.cardHolder)
    viewModel.lastFour.next(card.lastFourDigits)
    viewModel.cardStyle.next(card.cardStyle)
    viewModel.cardNetwork.next(card.cardNetwork)
  }

  private func updateViewModel(with user: ShiftUser) {
    viewModel.address.next(user.userData.addressDataPoint)
  }

  private func showPhysicalCardActivationByCode() {
    UIAlertController.prompt(title: "manage.shift.card.enter-code.title".podLocalized(),
                             message: "manage.shift.card.enter-code.message".podLocalized(),
                             placeholder: "manage.shift.card.enter-code.placeholder".podLocalized(),
                             keyboardType: .numberPad,
                             okTitle: "manage.shift.card.enter-code.submit".podLocalized(),
                             cancelTitle: "general.button.cancel".podLocalized()) { [unowned self] code in
      guard let code = code, !code.isEmpty else { return }
      self.activatePhysicalCard(code: code)
    }
  }

  private func activatePhysicalCard(code: String) {
    router?.showLoadingSpinner()
    interactor?.activatePhysicalCard(code: code) { [unowned self] result in
      self.router?.hideLoadingSpinner()
      switch result {
      case .failure(let error):
        self.router?.show(error: error)
      case .success:
        self.router?.cardActivationFinish()
      }
    }
  }
}
