//
//  OfferListPresenter.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 15/02/16.
//
//

import Foundation

protocol LinkOfferListRouterProtocol: URLHandlerProtocol {
  func close(_ animated: Bool)
  func refreshOffers()
  func applyTo(offer:LoanOffer)
}

protocol LinkOfferListInteractorProtocol {
  func provideInitialOffers()
  func loadNextOffers()
}

protocol LinkOfferListView: ViewControllerProtocol {
  func showNewContents(_ newContents:[LoanOffer], append:Bool)
  func set(borrowerName:String?)
}

class LinkOfferListPresenter: LinkOfferListDataReceiver, LinkOfferListEventHandler {

  var view: LinkOfferListView!
  var router: LinkOfferListRouterProtocol!
  var interactor: LinkOfferListInteractorProtocol!
  var linkHandler: LinkHandler?

  // MARK: - OfferLoaderEventHandler

  func viewLoaded() {
    interactor.provideInitialOffers()
  }

  // MARK: - OfferListReceiver

  func addNewData(_ offers:[LoanOffer], userName:String?) {
    linkHandler = LinkHandler(urlHandler: router)
    view.showNewContents(offers, append: false)
    view.set(borrowerName: userName)
  }

  func showLoadingError(_ error:NSError) {
    view.show(error:error, uiConfig: nil)
  }

  func closeTapped() {
    router.close(true)
  }

  func moreOffersTapped() {
    interactor.loadNextOffers()
  }

  func shouldShowRefreshOffersButton() -> Bool {
    return true
  }

  func shouldShowTOSButton() -> Bool {
    return true
  }

  func refreshOffersTapped() {
    router.refreshOffers()
  }

  func applyToOfferTapped(_ offer:LoanOffer) {
    router.applyTo(offer: offer)
  }

}
