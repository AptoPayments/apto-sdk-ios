//
//  IssueCardTestDoubles.swift
//  ShiftSDK
//
//  Created by Takeichi Kanzaki on 29/06/2018.
//
//

@testable import ShiftSDK

class IssueCardPresenterSpy: IssueCardPresenterProtocol {
  let viewModel = IssueCardViewModel(state: .loading)

  private(set) var viewLoadedCalled = false
  func viewLoaded() {
    viewLoadedCalled = true
  }

  private(set) var retryTappedCalled = false
  func retryTapped() {
    retryTappedCalled = true
  }
}

class IssueCardInteractorSpy: IssueCardInteractorProtocol {
  private(set) var issueCardCalled = false
  private(set) var lastIssueCardCompletion: Result<Card, NSError>.Callback?
  func issueCard(completion: @escaping Result<Card, NSError>.Callback) {
    issueCardCalled = true
    lastIssueCardCompletion = completion
  }
}

class IssueCardInteractorFake: IssueCardInteractorSpy {
  var nextIssueCardResult: Result<Card, NSError>?
  override func issueCard(completion: @escaping Result<Card, NSError>.Callback) {
    super.issueCard(completion: completion)

    if let result = nextIssueCardResult {
      completion(result)
    }
  }
}

class IssueCardModuleSpy: UIModuleSpy, IssueCardModuleProtocol {
  private(set) var cardIssuedCalled = false
  private(set) var lastCardIssued: Card?
  func cardIssued(_ card: Card) {
    cardIssuedCalled = true
    lastCardIssued = card
  }
}
