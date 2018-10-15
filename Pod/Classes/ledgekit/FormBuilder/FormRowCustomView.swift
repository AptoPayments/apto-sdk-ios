//
//  FormRowCustomView.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 24/08/16.
//
//

import UIKit
import SnapKit

class FormRowCustomView: FormRowView {
  let view: UIView

  init(view: UIView, showSplitter: Bool = false) {
    self.view = view
    super.init(showSplitter: showSplitter)
    setUpUI()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setUpUI() {
    contentView.addSubview(view)
    view.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
}
