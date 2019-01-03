//
// FundingSourceSelectorInteractor.swift
// ShiftSDK
//
// Created by Takeichi Kanzaki on 18/12/2018.
//

import Foundation

class FundingSourceSelectorInteractor: FundingSourceSelectorInteractorProtocol {
  private let card: Card
  private let cardSession: ShiftCardSession

  init(card: Card, cardSession: ShiftCardSession) {
    self.card = card
    self.cardSession = cardSession
  }

  func loadFundingSources(forceRefresh: Bool, callback: @escaping Result<[FundingSource], NSError>.Callback) {
    cardSession.cardFundingSources(card: card, page: nil, rows: nil, forceRefresh: forceRefresh, callback: callback)
  }

  func activeCardFundingSource(forceRefresh: Bool, callback: @escaping Result<FundingSource?, NSError>.Callback) {
    cardSession.getCardFundingSource(card: card, forceRefresh: forceRefresh, callback: callback)
  }

  func setActive(fundingSource: FundingSource, callback: @escaping Result<FundingSource, NSError>.Callback) {
    cardSession.setCardFundingSource(card: card, fundingSource: fundingSource, callback: callback)
  }
}
