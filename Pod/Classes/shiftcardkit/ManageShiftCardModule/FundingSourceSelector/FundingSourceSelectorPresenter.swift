//
// FundingSourceSelectorPresenter.swift
// ShiftSDK
//
// Created by Takeichi Kanzaki on 18/12/2018.
//

import Foundation

class FundingSourceSelectorPresenter: FundingSourceSelectorPresenterProtocol {
  // swiftlint:disable implicitly_unwrapped_optional
  weak var router: FundingSourceSelectorModuleProtocol!
  var interactor: FundingSourceSelectorInteractorProtocol!
  // swiftlint:enable implicitly_unwrapped_optional
  let viewModel = FundingSourceSelectorViewModel()

  func viewLoaded() {
    refreshData(forceRefresh: false)
  }

  func closeTapped() {
    router.close()
  }

  func refreshDataTapped() {
    refreshData(forceRefresh: true)
  }

  func fundingSourceSelected(index: Int) {
    guard index != viewModel.activeFundingSourceIdx.value else {
      return
    }
    let fundingSources = viewModel.fundingSources.value
    if index < fundingSources.count {
      viewModel.showLoadingSpinner.next(true)
      interactor.setActive(fundingSource: fundingSources[index]) { [weak self] result in
        guard let self = self else { return }
        self.viewModel.showLoadingSpinner.next(false)
        switch result {
        case .failure(_):
          self.router.show(message: "manage_card.funding_source_selector.error.message".podLocalized(),
                           title: "manage_card.funding_source_selector.error.title".podLocalized(),
                           isError: true)
          self.router.close()
        case .success(_):
          self.router.show(message: "manage_card.funding_source_selector.success.message".podLocalized(),
                           title: "manage_card.funding_source_selector.success.title".podLocalized(),
                           isError: false)
          self.router.fundingSourceChanged()
        }
      }
    }
  }

  func addFundingSourceTapped() {
    router.addFundingSource { _ in
      self.refreshData(forceRefresh: true)
    }
  }

  // MARK: - Private methods
  private func refreshData(forceRefresh: Bool) {
    viewModel.showLoadingSpinner.next(true)
    interactor.loadFundingSources(forceRefresh: forceRefresh) { [weak self] result in
      guard let self = self else { return }
      self.viewModel.showLoadingSpinner.next(false)
      switch result {
      case .failure(let error):
        self.router.show(error: error)
      case .success(let fundingSources):
        self.viewModel.showLoadingSpinner.next(true)
        self.interactor.activeCardFundingSource(forceRefresh: forceRefresh) { [weak self] result in
          guard let self = self else { return }
          self.viewModel.showLoadingSpinner.next(false)
          switch result {
          case .failure(let error):
            self.router.show(error: error)
          case .success(let fundingSource):
            self.viewModel.fundingSources.next(fundingSources)
            if let idx = fundingSources.index(where: { $0.fundingSourceId == fundingSource?.fundingSourceId }) {
              self.viewModel.activeFundingSourceIdx.next(idx)
            }
            else {
              self.viewModel.activeFundingSourceIdx.next(nil)
            }
            if self.viewModel.dataLoaded.value == false {
              self.viewModel.dataLoaded.next(true)
            }
          }
        }
      }
    }
  }
}
