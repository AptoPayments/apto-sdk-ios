//
//  LinkOfferListModule.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 17/10/2016.
//
//

import Foundation

class LinkOfferListModule: UIModule {

  var linkSession: LinkSession {
    return shiftSession.linkSession
  }
  var offerLoaderPresenter: LinkOfferLoaderPresenter!
  var applicationSummaryViewController: UIViewController?
  open var onOfferApplied: ((_ offerListModule: LinkOfferListModule, _ offer: LoanOffer) -> Void)?

  override func initialize(completion: @escaping Result<UIViewController, NSError>.Callback) {
    linkSession.shiftSession.contextConfiguration { result in
      switch result {
      case .failure (let error):
        completion(.failure(error))
      case .success(let contextConfiguration):
        self.uiConfig = ShiftUIConfig(projectConfiguration: contextConfiguration.projectConfiguration)
        let viewController = self.buildOfferLoaderViewController(self.uiConfig!)
        self.addChild(viewController: viewController, completion: completion)
      }
    }
  }

  // MARK: - Offer Loader Handling

  fileprivate func buildOfferLoaderViewController(_ uiConfig:ShiftUIConfig) -> UIViewController {
    offerLoaderPresenter = LinkOfferLoaderPresenter()
    let interactor = LinkOfferLoaderInteractor(linkSession:linkSession)
    let viewController = LinkOfferLoaderViewController(uiConfiguration: uiConfig, eventHandler: offerLoaderPresenter)
    offerLoaderPresenter.view = viewController
    offerLoaderPresenter.interactor = interactor
    offerLoaderPresenter.router = self
    return viewController
  }

  // MARK: - Offer List Handling

  fileprivate func buildOfferListViewController(_ offerListStyle: OfferListStyle, offerRequestId:String, nameDataPoint: PersonalName, initialOffers:[LoanOffer]) -> UIViewController {
    let presenter = LinkOfferListPresenter()
    let interactor = LinkOfferListInteractor(linkSession:linkSession, nameDataPoint:nameDataPoint, dataReceiver: presenter, offerRequestId: offerRequestId, initialLoanOffers: initialOffers)
    var offerListView: LinkOfferListView
    switch offerListStyle {
    case .list:
      offerListView = LinkOfferListViewController(uiConfiguration: self.uiConfig!, eventHandler: presenter)
      break
    case .carousel:
      offerListView = LinkOfferListCarouselViewController(uiConfiguration: self.uiConfig!, eventHandler: presenter)
      break
    }
    presenter.view = offerListView
    presenter.interactor = interactor
    presenter.router = self
    return (offerListView as? UIViewController)!
  }

  // MARK: - Offer Summary Handling

  func showApplicationSummaryFor(offer:LoanOffer) {
    showLoadingSpinner()
    linkSession.shiftSession.currentUser { result in
      switch result {
      case .failure(let error):
        self.show(error: error)
        return
      case .success(let currentUser):
        self.linkSession.linkConfiguration(callback: { result in
          switch result {
          case .failure(let error):
            self.show(error: error)
            return
          case .success(let linkConfiguration):
            self.hideLoadingSpinner()
            let applicationSummaryViewController = self.buildApplicationSummaryViewController(
              linkConfiguration: linkConfiguration,
              loanData: self.linkSession.loanData,
              userData: currentUser.userData,
              offer: offer)
            self.applicationSummaryViewController = applicationSummaryViewController
            self.push(viewController: applicationSummaryViewController) {}
          }
        })

      }
    }
  }

  fileprivate func buildApplicationSummaryViewController(linkConfiguration:LinkConfiguration, loanData:AppLoanData, userData:DataPointList, offer:LoanOffer) -> UIViewController {
    let presenter = LinkApplicationSummaryPresenter(config: linkConfiguration, uiConfig: self.uiConfig!)
    let interactor = LinkApplicationSummaryInteractor(linkSession:linkSession, loanData:loanData, userData:userData, offer:offer, dataReceiver: presenter)
    let viewController = LinkApplicationSummaryViewController(uiConfiguration: self.uiConfig!)
    presenter.view = viewController
    presenter.interactor = interactor
    presenter.router = self
    viewController.presenter = presenter
    return viewController
  }

}

// MARK: - LinkOfferLoaderRouterProtocol

extension LinkOfferListModule: LinkOfferLoaderRouterProtocol {

  func offerListReceived(_ offerRequestId:String, initialOffers:[LoanOffer]) {
    linkSession.shiftSession.currentUser() { result in
      switch result {
      case .failure(let error):
        self.show(error: error)
        return
      case .success(let currentUser):
        let nameDataPoint = currentUser.userData.nameDataPoint
        self.linkSession.linkConfiguration { result in
          switch result {
          case .failure(let error):
            self.show(error: error)
            return
          case .success(let linkConfiguration):
            self.push(viewController: self.buildOfferListViewController(linkConfiguration.offerListStyle, offerRequestId:offerRequestId, nameDataPoint:nameDataPoint, initialOffers: initialOffers)) {}
          }
        }
      }
    }
  }

  func back(_ animated: Bool?) {
    onBack?(self)
  }

  func close(_ animated: Bool?) {
    onClose?(self)
  }

}

// MARK: - LinkOfferListRouterProtocol

extension LinkOfferListModule: LinkOfferListRouterProtocol {

  func refreshOffers() {
    self.popViewController() {}
    offerLoaderPresenter.retryTapped()
  }

  func applyTo(offer: LoanOffer) {
    if offer.showApplicationSummary {
      self.showApplicationSummaryFor(offer:offer)
    }
    else {
      onOfferApplied?(self, offer)
    }
  }

}

// MARK: - LinkApplicationSummaryRouterProtocol

extension LinkOfferListModule: LinkApplicationSummaryRouterProtocol {

  func backFromAppSummary(_ animated:Bool?) {
    self.popViewController(animated: animated) {}
  }

  func appSummaryAgreed(offer: LoanOffer) {
    self.popViewController(animated: false) {
      self.applicationSummaryViewController = nil
      switch offer.applicationMethod {
      case .api:
        self.onOfferApplied?(self, offer)
      case .url:
        self.externalApplyTo(offer: offer) {}
      }
    }
  }

  fileprivate func externalApplyTo(offer:LoanOffer, completion:@escaping (()->Void)) {
    UIApplication.topViewController()!.askPermissionToOpenExternalUrl { [weak self] result in
      switch result {
      case .failure (let error):
        UIApplication.topViewController()!.show(error:error)
        completion()
      case .success(let show):
        if show {
          self?.linkSession.shiftSession.getExternalApplicationUrl(offer) { result in
            switch result {
            case .failure(let error):
              self?.show(error: error)
              break
            case .success(let url):
              self?.linkSession.shiftSession.getAuthorisationHeaders() { result in
                switch result {
                case .failure(let error):
                  self?.show(error: error)
                  break
                case .success(let headers):
                  self?.showExternal(url: url, headers:headers, useSafari: false)
                }
              }
            }
            completion()
          }
        }
        else {
          completion()
        }
      }
    }
  }

}
