//
//  ApplicationListInteractor.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 04/03/16.
//
//

import Foundation

class LinkApplicationListInteractor: LinkApplicationListInteractorProtocol {

  let linkSession: LinkSession
  var applications: [LoanApplicationSummary] = []
  var initialApplicationsReturned = false

  init(linkSession: LinkSession, initialApplications: [LoanApplicationSummary]) {
    self.linkSession = linkSession
    self.applications = initialApplications
  }

  // MARK: - OfferListDataProvider

  func loadNextApplications(_ completion: @escaping Result<[LoanApplicationSummary], NSError>.Callback) {
    if !initialApplicationsReturned {
      initialApplicationsReturned = true
      completion(.success(self.applications))
      return
    }
    let page = self.applications.count / 10
    self.linkSession.nextApplications(page, rows: 10) { [weak self] result in
      guard let wself = self else {
        return
      }
      switch result {
      case .failure(let error):
        completion(.failure(error))
      case .success(let newApplications):
        wself.applications.append(contentsOf: newApplications)
        completion(.success(wself.applications))
      }
    }
  }

}
