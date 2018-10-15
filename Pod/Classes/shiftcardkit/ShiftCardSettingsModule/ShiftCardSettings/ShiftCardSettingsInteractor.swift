//
//  ShiftCardSettingsInteractor.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 25/03/2018.
//
//

import Foundation

class ShiftCardSettingsInteractor: ShiftCardSettingsInteractorProtocol {
  private let shiftSession: ShiftSession
  private let card: Card

  init(shiftSession: ShiftSession, card: Card) {
    self.shiftSession = shiftSession
    self.card = card
  }

  func provideFundingSources(rows: Int, callback: @escaping Result<[FundingSource], NSError>.Callback) {
    shiftSession.shiftCardSession.cardFundingSources(card: card, page: nil, rows: rows, callback: callback)
  }

  func activeCardFundingSource(callback: @escaping Result<FundingSource?, NSError>.Callback) {
    shiftSession.shiftCardSession.getCardFundingSource(card: card, callback: callback)
  }

  func setActive(fundingSource: FundingSource, callback: @escaping Result<FundingSource, NSError>.Callback) {
    shiftSession.shiftCardSession.setCardFundingSource(card: card, fundingSource: fundingSource, callback: callback)
  }
}
