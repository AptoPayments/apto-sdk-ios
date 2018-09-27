//
//  ListSeparatorCellController.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 16/02/16.
//
//

import Foundation

class ListSeparatorCellController: CellController {
  
  let backgroundColor: UIColor
  let height: CGFloat
  
  init(backgroundColor:UIColor, height:CGFloat) {
    self.backgroundColor = backgroundColor
    self.height = height
    super.init()
  }
  
  override func cellClass() -> AnyClass? {
    return ListSeparatorCell.classForCoder()
  }
  
  override func reuseIdentificator() -> String? {
    return NSStringFromClass(ListSeparatorCell.classForCoder())
  }
  
  override func setupCell(_ cell:UITableViewCell) {
    guard let cell = cell as? ListSeparatorCell else {
      return
    }
    cell.contentView.snp.makeConstraints { make in
      make.height.equalTo(self.height)
    }
    cell.backgroundColor = self.backgroundColor
    cell.contentView.backgroundColor = self.backgroundColor
  }

}
