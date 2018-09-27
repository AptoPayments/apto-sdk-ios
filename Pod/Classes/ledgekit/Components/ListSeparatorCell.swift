//
//  ListSeparatorCell.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 16/02/16.
//
//

import Foundation

class ListSeparatorCell : UITableViewCell {
  
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    self.selectionStyle = .none
  }

  required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
  
}
