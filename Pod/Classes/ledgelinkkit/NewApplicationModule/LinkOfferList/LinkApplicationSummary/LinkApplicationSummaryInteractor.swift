//
//  ApplicationSummaryInteractor.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 23/08/16.
//
//

import Foundation

protocol LinkApplicationSummaryDataReceiver {
  func addNewData(_ linkSession:LinkSession, userData:DataPointList, loanData:AppLoanData, offer:LoanOffer)
  func continueApplicationWith(_ offer:LoanOffer)
}

class LinkApplicationSummaryInteractor: LinkApplicationSummaryInteractorProtocol {

  let dataReceiver: LinkApplicationSummaryDataReceiver
  let linkSession: LinkSession
  let loanData: AppLoanData
  let userData: DataPointList
  let offer: LoanOffer
  
  init(linkSession: LinkSession, loanData:AppLoanData, userData:DataPointList, offer: LoanOffer, dataReceiver: LinkApplicationSummaryDataReceiver) {
    self.linkSession = linkSession
    self.loanData = loanData
    self.userData = userData
    self.offer = offer
    self.dataReceiver = dataReceiver
  }
  
  func loadData() {
    dataReceiver.addNewData(linkSession, userData:userData, loanData:loanData, offer:offer)
  }
  
  func finalizeApplication() {
    dataReceiver.continueApplicationWith(offer)
  }
  
}
