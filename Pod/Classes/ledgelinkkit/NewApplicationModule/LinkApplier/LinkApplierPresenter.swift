//
//  ApplicationFeedbackPresenter.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 19/03/16.
//
//

import Bond

protocol LinkApplierRouterProtocol: URLHandlerProtocol {
  func offerApplied(application: LoanApplication)
  func close(_ animated: Bool)
}

protocol LinkApplierInteractorProtocol {
  func applyToOffer(callback: @escaping Result<LoanApplication,NSError>.Callback)
}

protocol LinkApplicationFeedbackViewProtocol {
  func showLoadingState()
  func showErrorState(_ errorMessage:String)
}

class LinkApplierPresenter: LinkApplierEventHandlerProtocol {

  let uiConfiguration: ShiftUIConfig
  var view: LinkApplicationFeedbackViewProtocol!
  var router: LinkApplierRouterProtocol!
  var interactor: LinkApplierInteractorProtocol!

  init(uiConfiguration: ShiftUIConfig) {
    self.uiConfiguration = uiConfiguration
  }

  // MARK: - ApplicationFeedbackEventHandler

  func viewLoaded() {
    applyToOffer()
  }

  func retryTapped() {
    applyToOffer()
  }

  func closeTapped() {
    router.close(true)
  }

  // MARK: - Private methods

  fileprivate func applyToOffer() {
    view.showLoadingState()
    interactor.applyToOffer() { result in
      let delayTime = DispatchTime.now() + Double(Int64(1.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
      DispatchQueue.main.asyncAfter(deadline: delayTime) { [weak self] in
        switch result {
        case .failure(let error):
          self?.view.showErrorState(error.localizedDescription)
        case .success(let application):
          self?.router.offerApplied(application: application)
        }
      }
    }
  }

}
