//
//  OfferListInteractor.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 15/02/16.
//
//

import Foundation

protocol LinkOfferListDataReceiver {
  func addNewData(_ offers:[LoanOffer], userName:String?)
  func showLoadingError(_ error:NSError)
}

class LinkOfferListInteractor: LinkOfferListInteractorProtocol {
  
  let linkSession: LinkSession
  let nameDataPoint: PersonalName
  let dataReceiver: LinkOfferListDataReceiver
  let offerRequestId: String
  var loanOffers: [LoanOffer]
  
  init(linkSession: LinkSession, nameDataPoint:PersonalName, dataReceiver: LinkOfferListDataReceiver, offerRequestId:String, initialLoanOffers:[LoanOffer]) {
    self.linkSession = linkSession
    self.nameDataPoint = nameDataPoint
    self.dataReceiver = dataReceiver
    self.offerRequestId = offerRequestId
    self.loanOffers = initialLoanOffers
  }

  // MARK: - OfferListDataProvider
  
  func provideInitialOffers() {
    dataReceiver.addNewData(self.loanOffers, userName: nameDataPoint.firstName.value)
  }
  
  func loadNextOffers() {
    let page = self.loanOffers.count / 10
    self.linkSession.nextOffers(offerRequestId, page:page, rows:10) { [weak self] result in
      guard let wself = self else {
        return
      }
      switch result {
      case .failure(let error):
        wself.dataReceiver.showLoadingError(error)
      case .success(let newOffers):
        let arrayPrefix = wself.loanOffers.prefix((wself.loanOffers.count / 10) * 10)
        wself.loanOffers = arrayPrefix + newOffers
        wself.dataReceiver.addNewData(wself.loanOffers, userName: wself.nameDataPoint.firstName.value)
      }
    }
  }
  
}
