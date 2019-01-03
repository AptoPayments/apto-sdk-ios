//
//  TransactionAdjustmentViewTheme1.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 09/05/2018.
//

import UIKit

class TransactionAdjustmentViewTheme1: UIView {

  let titleLabel: UILabel
  let idLabel: UILabel
  let exchangeRateLabel: UILabel
  let amountLabel: UILabel
  let uiConfiguration: ShiftUIConfig
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  init(uiConfiguration: ShiftUIConfig) {
    
    self.uiConfiguration = uiConfiguration
    self.titleLabel = ComponentCatalog.mainItemRegularLabelWith(text: "", uiConfig: uiConfiguration)
    self.idLabel = ComponentCatalog.instructionsLabelWith(text: "",
                                                          textAlignment: .left,
                                                          uiConfig: uiConfiguration)
    self.exchangeRateLabel = ComponentCatalog.instructionsLabelWith(text: "",
                                                                    textAlignment: .left,
                                                                    uiConfig: uiConfiguration)
    self.amountLabel = ComponentCatalog.amountSmallLabelWith(text: "",
                                                             textAlignment: .right,
                                                             uiConfig: uiConfiguration)
    self.amountLabel.textColor = uiConfiguration.textSecondaryColor
    super.init(frame: .zero)

    let leftView = UIView()
    leftView.backgroundColor = .clear
    self.addSubview(leftView)
    leftView.snp.makeConstraints { make in
      make.left.top.bottom.equalTo(self)
    }
    
    leftView.addSubview(titleLabel)
    titleLabel.snp.makeConstraints { make in
      make.left.top.right.equalTo(leftView)
    }
    
    leftView.addSubview(idLabel)
    idLabel.snp.makeConstraints { make in
      make.left.right.equalTo(leftView)
      make.top.equalTo(titleLabel.snp.bottom).offset(4)
    }

    leftView.addSubview(exchangeRateLabel)
    exchangeRateLabel.snp.makeConstraints { make in
      make.left.right.equalTo(leftView)
      make.top.equalTo(idLabel.snp.bottom)
      make.bottom.equalTo(self)
    }
    
    self.addSubview(amountLabel)
    amountLabel.backgroundColor = .clear
    amountLabel.snp.makeConstraints { make in
      make.top.right.equalTo(self)
      make.left.equalTo(leftView.snp.right)
    }

  }
  
  func set(title: String?, id: String?, exchangeRate: String?, amount: Amount?, adjustmentType: TransactionAdjustmentType) {
    titleLabel.text = title
    idLabel.text = id
    exchangeRateLabel.text = exchangeRate
    amountLabel.text = amount?.text
  }

}
