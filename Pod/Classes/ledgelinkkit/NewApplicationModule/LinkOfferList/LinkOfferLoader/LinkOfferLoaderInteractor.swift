//
//  OfferLoaderInteractor.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 12/02/16.
//
//

import Foundation

class LinkOfferLoaderInteractor: LinkOfferLoaderInteractorProtocol {

  let linkSession: LinkSession

  init(linkSession: LinkSession) {
    self.linkSession = linkSession
  }
  
  // MARK: - OfferLoaderDataProvider
  
  func loadOfferList(_ callback: @escaping Result<OfferRequest,NSError>.Callback) {
    linkSession.requestOffers(callback)
  }
  
}
