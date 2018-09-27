//
//  ApplicationListPresenter.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 04/03/16.
//
//

import Foundation

protocol LinkApplicationListRouterProtocol {
  func back(_ animated:Bool?)
  func close(_ animated:Bool?)
  func applicationSelected(applicationSummary: LoanApplicationSummary)
  func newApplicationSelected()
}

protocol LinkApplicationListInteractorProtocol {
  func loadNextApplications(_ completion: @escaping Result<[LoanApplicationSummary], NSError>.Callback)
}

protocol LinkApplicationListViewProtocol: ViewControllerProtocol {
  func showNewContents(_ newContents:[LoanApplicationSummary])
  func set(subtitle:String)
  func showLoadingSpinner()
}

class LinkApplicationListPresenter: LinkApplicationListEventHandler {

  var view: LinkApplicationListViewProtocol!
  var router: LinkApplicationListRouterProtocol!
  var interactor: LinkApplicationListInteractorProtocol!
  var applications: [LoanApplicationSummary]?

  // MARK: - OfferLoaderEventHandler

  func viewLoaded() {
    self.loadNextApplications()
  }

  func viewShown() {
  }

  // MARK: - OfferListReceiver

  func loadNextApplications() {
    self.view.showLoadingSpinner()
    interactor.loadNextApplications { result in
      self.view.hideLoadingSpinner()
      switch result {
      case .failure(let error):
        self.view.show(error:error)
      case .success(let newContents):
        self.applications = newContents
        self.view.set(subtitle: "link-application-list.subtitle".podLocalized())
        self.view.showNewContents(newContents)
      }
    }
  }

  func backTapped() {
    router.back(true)
  }

  func applicationSelectedWith(index: Int) {
    guard let applications = applications else {
      return
    }
    if index < applications.count {
      let applicationSummary = applications[index]
      router.applicationSelected(applicationSummary: applicationSummary)
    }
  }

  func newApplicationTapped() {
    router.newApplicationSelected()
  }

  func closeTapped() {
    router.close(true)
  }

}
