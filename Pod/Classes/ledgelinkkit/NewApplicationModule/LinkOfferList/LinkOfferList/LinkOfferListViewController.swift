//
//  OfferListViewController.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 18/01/16.
//  Copyright © 2018 Shift. All rights reserved.
//

import UIKit
import UIScrollView_InfiniteScroll

protocol LinkOfferListEventHandler: NavigationMenuListener {
  var linkHandler: LinkHandler? { get }
  func viewLoaded()
  func closeTapped()
  func moreOffersTapped()
  func applyToOfferTapped(_ offer:LoanOffer)
}

class LinkOfferListViewController : ShiftViewController, LinkOfferListView {

  var eventHandler: LinkOfferListEventHandler
  fileprivate let tableView: UITableView = UITableView()
  fileprivate var navigationMenu: NavigationMenu?

  init(uiConfiguration: ShiftUIConfig, eventHandler: LinkOfferListEventHandler) {
    self.eventHandler = eventHandler
    super.init(uiConfiguration: uiConfiguration)
  }

  override func viewDidLoad() {
    self.title = "offer-list.title".podLocalized()
    self.view.addSubview(tableView)
    tableView.snp.makeConstraints { make in
      make.left.right.top.bottom.equalTo(self.view)
    }
    tableView.dataSource = self
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 271
    tableView.separatorStyle = .none
    tableView.backgroundColor = self.uiConfiguration.backgroundColor
    navigationMenu = NavigationMenu(viewController: self, uiConfiguration: self.uiConfiguration, menuListener: eventHandler)
    navigationMenu?.install()
    showNavCancelButton(self.uiConfiguration.iconTertiaryColor)
    eventHandler.viewLoaded()
    edgesForExtendedLayout = UIRectEdge()
    extendedLayoutIncludesOpaqueBars = true
    tableView.addInfiniteScroll { (scrollView) -> Void in
        self.eventHandler.moreOffersTapped()
    }
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func closeTapped() {
    self.eventHandler.closeTapped()
  }

  // MARK: - OfferListViewProtocol

  fileprivate var cellControllers: [CellController] = []

  func showNewContents(_ newContents:[LoanOffer], append:Bool) {
    if !append {
      cellControllers.removeAll()
    }
    var newCellControllers: [CellController] = []
    if cellControllers.count == 0 {
      newCellControllers.append(ListSeparatorCellController(backgroundColor: UIColor.clear, height: 16))
    }
    var order = 1
    for offer in newContents {
      newCellControllers.append(OfferListCellController(offer: offer, order: order, uiConfiguration: uiConfiguration, delegate: self))
      newCellControllers.append(ListSeparatorCellController(backgroundColor: UIColor.clear, height: 16))
      order += 1
    }
    cellControllers.append(contentsOf: newCellControllers)
    tableView.reloadData()
    tableView.finishInfiniteScroll()
  }

  func set(borrowerName:String?) {
    // Nothing to do here
  }

}

extension LinkOfferListViewController: UITableViewDataSource {

  @objc func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  @objc func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return cellControllers.count
  }

  @objc func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard indexPath.row >= 0 && indexPath.row < cellControllers.count else {
      return UITableViewCell()
    }
    let cell = cellControllers[indexPath.row].cell(tableView)
    cell.tableView = tableView
    return cell
  }

}

extension LinkOfferListViewController: OfferListCellControllerDelegate {
  func applyButtonTappedFor(loanOffer:LoanOffer) {
    eventHandler.applyToOfferTapped(loanOffer)
  }
}
