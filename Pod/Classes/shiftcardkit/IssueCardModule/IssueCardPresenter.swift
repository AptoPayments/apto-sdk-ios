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
  let viewModel = IssueCardViewModel(state: .loading)

  init(router: IssueCardRouter, interactor: IssueCardInteractorProtocol) {
    self.router = router
    self.interactor = interactor
  }

  func viewLoaded() {
    issueCard()
  }

  func retryTapped() {
    issueCard()
  }

  private func issueCard() {
    viewModel.state.next(IssueCardViewState.loading)
    interactor.issueCard { result in
      switch result {
      case .failure:
        self.viewModel.state.next(.error)
      case .success(let card):
        self.router.cardIssued(card)
      }
    }
  }
}
