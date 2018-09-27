//
//  FormRowCustomView.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 24/08/16.
//
//

import UIKit

class FormRowCustomView: FormRowView {

  let view: UIView
  
  init(
    view: UIView,
    showSplitter:Bool = false)
  {
    self.view = view
    super.init(showSplitter:showSplitter)
    self.contentView.addSubview(view)
    view.snp.makeConstraints { make in
      make.left.right.top.bottom.equalTo(self.contentView)
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

}
