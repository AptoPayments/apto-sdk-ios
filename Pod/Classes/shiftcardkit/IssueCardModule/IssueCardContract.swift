//
// IssueCardContract.swift
// ShiftSDK
//
// Created by Takeichi Kanzaki on 20/11/2018.
//

import Bond

enum IssueCardViewState: Equatable {
  case showLegalNotice(content: Content)
  case loading
  case error
  case done
}

class IssueCardViewModel {
  let state: Observable<IssueCardViewState>

  init(state: IssueCardViewState) {
    self.state = Observable(state)
  }
}

protocol IssueCardInteractorProtocol {
  func issueCard(completion: @escaping Result<Card, NSError>.Callback)
}

protocol IssueCardPresenterProtocol {
  var viewModel: IssueCardViewModel { get }
  func viewLoaded()
  func requestCardTapped()
  func retryTapped()
  func backTapped()
  func show(url: URL)
}

protocol IssueCardRouter: class {
  func cardIssued(_ card: Card)
  func show(error: Error)
  func backTapped()
  func show(url: URL)
}

protocol IssueCardModuleProtocol: UIModuleProtocol, IssueCardRouter {
}
