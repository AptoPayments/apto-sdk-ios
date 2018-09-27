//
//  OfferListCellController.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 15/02/16.
//
//

import Foundation

protocol OfferListCellControllerDelegate {
  func applyButtonTappedFor(loanOffer:LoanOffer)
}

enum OfferListCellControllerState {
  case noMoreInfo
  case moreInfoFolded
  case moreInfoUnfolded
  case moreInfoNotFoldable
}

class OfferListCellController: CellController {
  
  let offer: LoanOffer
  let order: Int
  let delegate: OfferListCellControllerDelegate
  let uiConfiguration: ShiftUIConfig
  var state: OfferListCellControllerState
  fileprivate var lenderLogoError = false
  
  init(offer:LoanOffer, order: Int, uiConfiguration: ShiftUIConfig, delegate:OfferListCellControllerDelegate) {
    self.offer = offer
    self.order = order
    self.uiConfiguration = uiConfiguration
    self.delegate = delegate
    if offer.customMessage != nil {
      if offer.interestRate == nil && offer.loanAmount == nil && offer.paymentAmount == nil {
        self.state = .moreInfoNotFoldable
      }
      else {
        self.state = .moreInfoFolded
      }
    }
    else {
      self.state = .noMoreInfo
    }
    super.init()
  }
  
  override func cellClass() -> AnyClass? {
    return OfferListCell.classForCoder()
  }
  
  override func reuseIdentificator() -> String? {
    return NSStringFromClass(OfferListCell.classForCoder())
  }
  
  override func setupCell(_ cell:UITableViewCell) {
    guard let cell = cell as? OfferListCell else {
      return
    }
    
    cell.setUIConfiguration(uiConfiguration)
    if offer.lender.smallIconUrl != nil && !self.lenderLogoError {
      cell.set(lenderIconUrl:offer.lender.smallIconUrl!, lenderName: offer.lender.name) { [weak self] result in
        switch result {
        case .failure:
          self?.lenderLogoError = true
        case .success:
          self?.lenderLogoError = false
        }
      }
    }
    else {
      cell.set(lenderName:offer.lender.name)
    }

    cell.startCellLayout()
    cell.showLenderHeader()

    if let interestRate = offer.interestRate {
      cell.set(interestRate: interestRate)
      cell.showInterestRateRow()
    }
    
    if let loanAmount = offer.loanAmount {
      cell.set(amountFinanced: loanAmount)
      cell.showAmountFinancedRow()
    }
    
    if let paymentAmount = offer.paymentAmount {
      cell.set(monthlyPayment: paymentAmount)
      cell.showMonthlyPaymentRow()
    }

    if let customMessage = offer.customMessage, customMessage != "" {
      
      cell.set(moreInfo: offer.customMessage)
      
      switch self.state {
      case .moreInfoFolded:
        cell.showMoreInfoFoldedRow()
      case .moreInfoUnfolded:
        cell.showMoreInfoUnfoldedRow()
        cell.showMoreInfoTextRow()
      case .moreInfoNotFoldable:
        cell.showMoreInfoTextRow()
      default:
        break
      }

    }
    cell.set(order: order)
    cell.finishCellLayout()
    cell.cellController = self
  }
  
  func applyButtonTapped() {
    self.delegate.applyButtonTappedFor(loanOffer: self.offer)
  }
  
  func unfoldMoreInfoTapped() {
    self.state = .moreInfoUnfolded
    self.cellInstance?.tableView?.reloadData()
  }
  
  func foldMoreInfoTapped() {
    self.state = .moreInfoFolded
    self.cellInstance?.tableView?.reloadData()
  }

}
