//
//  FormRowButtonView.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 01/02/16.
//
//

import UIKit

class FormRowImageView: FormRowView {
  
  let imageView: UIImageView
  
  init(imageView: UIImageView, height:CGFloat) {
    self.imageView = imageView
    super.init(showSplitter: false, height:height)
    self.contentView.addSubview(self.imageView)
    self.imageView.snp.makeConstraints { make in
      make.height.equalTo(height)
      make.top.left.right.bottom.equalTo(self.contentView);
    }
  }

  required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }

}
