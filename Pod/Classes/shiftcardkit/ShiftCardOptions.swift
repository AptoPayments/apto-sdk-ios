//
//  ShiftCardOptions.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 30/07/2018.
//

@objc public enum ShiftCardOptionsKeys: Int {
  case showAddFundingSourceButton
  case showActivateCardButton
  case useBalanceVersionV2
}

@objc public class ShiftCardOptions: NSObject {
  var features: [ShiftCardOptionsKeys: Bool]
  override init() {
    self.features = [
      .showAddFundingSourceButton: true,
      .showActivateCardButton: true,
      .useBalanceVersionV2: false
    ]
    super.init()
  }
  public convenience init(features: [ShiftCardOptionsKeys: Bool]) {
    self.init()
    for key in features.keys {
      self.features[key] = features[key]
    }
  }
}
