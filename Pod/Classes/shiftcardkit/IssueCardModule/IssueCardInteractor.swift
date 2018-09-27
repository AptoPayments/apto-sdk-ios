//
//  IssueCardInteractor.swift
//  Pods
//
//  Created by Takeichi Kanzaki on 29/06/2018.
//
//


class IssueCardInteractor: IssueCardInteractorProtocol {
  private let shiftCardSession: ShiftCardSession
  private let application: CardApplication

  init(shiftCardSession: ShiftCardSession, application: CardApplication) {
    self.shiftCardSession = shiftCardSession
    self.application = application
  }

  func issueCard(completion: @escaping Result<Card, NSError>.Callback) {
    shiftCardSession.issueCard(application.id, callback: completion)
  }
}
