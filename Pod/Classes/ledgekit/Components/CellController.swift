//
//  CellController.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 15/02/16.
//
//

import Foundation

open class CellController {
  
  var cellInstance: UITableViewCell?
  
  func cell(_ tableView:UITableView) -> UITableViewCell {
    self.cellInstance = self.dequeueCellFrom(tableView:tableView)
    self.setupCell(self.cellInstance!)
    return self.cellInstance!
  }
  
  // MARK: - Private methods
  
  func dequeueCellFrom(tableView:UITableView) -> UITableViewCell {
    guard let identificator = self.reuseIdentificator() else {
      return UITableViewCell()
    }
    guard let cell = tableView.dequeueReusableCell(withIdentifier: identificator) else {
      self.registerCellInTableView(tableView: tableView)
      guard let cell = tableView.dequeueReusableCell(withIdentifier: identificator) else {
        return UITableViewCell()
      }
      return cell
    }
    return cell
  }
  
  func registerCellInTableView(tableView:UITableView) {
    guard let identificator = self.reuseIdentificator(),
      let clazz = self.cellClass() else {
      return
    }
    tableView.register(clazz, forCellReuseIdentifier: identificator)
  }
  
  // MARK: - Methods to be overriden by client classes
  
  func cellClass() -> AnyClass? {
    // Implement in subclasses
    return nil
  }
  
  func reuseIdentificator() -> String? {
    // Implement in subclasses
    return nil
  }
  
  func setupCell(_ cell:UITableViewCell) {
    // Implement in subclasses
    return
  }
  
}

private var tableViewAssociationKey: UInt8 = 0

extension UITableViewCell {
  weak var tableView: UITableView? {
    get {
      return objc_getAssociatedObject(self, &tableViewAssociationKey) as? UITableView
    }
    set(newValue) {
      objc_setAssociatedObject(self, &tableViewAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
    }
  }
}
