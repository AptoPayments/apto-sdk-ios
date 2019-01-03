//
//  OfferLoaderPresenter.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 12/02/16.
//
//

import Foundation

protocol LinkOfferLoaderRouterProtocol {
  func close(_ animated: Bool)
  func back(_ animated: Bool)
  func offerListReceived(_ offerRequestId:String, initialOffers:[LoanOffer])
}

protocol LinkOfferLoaderInteractorProtocol {
  func loadOfferList(_ callback: @escaping Result<OfferRequest,NSError>.Callback)
}

protocol LinkOfferLoaderViewProtocol {
  func showLoadingState()
  func showEmptyCaseState()
  func showErrorState(_ errorMessage:String)
}

class LinkOfferLoaderPresenter: LinkOfferLoaderEventHandler {

  var view: LinkOfferLoaderViewProtocol!
  var router: LinkOfferLoaderRouterProtocol!
  var interactor: LinkOfferLoaderInteractorProtocol!

  // MARK: - OfferLoaderEventHandler

  func viewLoaded() {
    view.showLoadingState()
  }

  func viewShown() {
    self.loadOfferList()
  }

  func retryTapped() {
    view.showLoadingState()
    self.loadOfferList()
  }

  func closeTapped() {
    router.close(true)
  }

  func updateRequestTapped() {
    router.back(true)
  }

  func shouldShowRefreshOffersButton() -> Bool {
    return true
  }

  func shouldShowTOSButton() -> Bool {
    return true
  }

  func refreshOffersTapped() {
    self.retryTapped()
  }

  // MARK: - Private methods

  fileprivate func loadOfferList() {
    self.interactor.loadOfferList { [weak self] result in
      switch result {
      case .failure:
        self?.view.showErrorState("general.something-went-wrong".podLocalized())
      case .success(let offerRequest):
        guard offerRequest.offers.count > 0  else {
          self?.view.showEmptyCaseState()
          return
        }
        self?.router.offerListReceived(offerRequest.id, initialOffers: offerRequest.offers)
      }
    }
  }

}
