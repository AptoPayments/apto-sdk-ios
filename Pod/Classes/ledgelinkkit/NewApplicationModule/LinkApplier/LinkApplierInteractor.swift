//
//  LinkApplierInteractor.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 19/03/16.
//
//

import Foundation

class LinkApplierInteractor: LinkApplierInteractorProtocol {

  let linkSession: LinkSession
  let offer: LoanOffer

  init(linkSession: LinkSession, offer:LoanOffer) {
    self.linkSession = linkSession
    self.offer = offer
  }

  func applyToOffer(callback: @escaping Result<LoanApplication,NSError>.Callback) {
    linkSession.applyToOffer(offer, callback: callback)
  }

}
