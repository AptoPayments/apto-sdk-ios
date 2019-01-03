//
//  IssueCardPresenter.swift
//  Pods
//
//  Created by Takeichi Kanzaki on 29/06/2018.
//
//

import Bond


class IssueCardPresenter: IssueCardPresenterProtocol {
  private unowned let router: IssueCardRouter
  private let interactor: IssueCardInteractorProtocol
  private let configuration: IssueCardActionConfiguration?
  let viewModel = IssueCardViewModel(state: .loading)

  init(router: IssueCardRouter, interactor: IssueCardInteractorProtocol, configuration: IssueCardActionConfiguration?) {
    self.router = router
    self.interactor = interactor
    self.configuration = configuration
  }

  func viewLoaded() {
    if let configuration = self.configuration {
      self.viewModel.state.next(IssueCardViewState.showLegalNotice(content: configuration.legalNotice))
    }
    else {
      issueCard()
    }
  }

  func requestCardTapped() {
    issueCard()
  }

  func retryTapped() {
    issueCard()
  }

  func backTapped() {
    router.backTapped()
  }

  func show(url: URL) {
    router.show(url: url)
  }

  private func issueCard() {
    viewModel.state.next(IssueCardViewState.loading)
    interactor.issueCard { result in
      switch result {
      case .failure:
        self.viewModel.state.next(.error)
      case .success(let card):
        self.viewModel.state.next(.done)
        self.router.cardIssued(card)
      }
    }
  }
}
