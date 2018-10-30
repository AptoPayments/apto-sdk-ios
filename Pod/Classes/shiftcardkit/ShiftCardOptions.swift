//
//  ShiftCardOptions.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 30/07/2018.
//
@objc public enum ShiftCardOptionsKeys: Int {
  case showBalancesSection
  case showActivateCardButton
  case useBalanceVersionV2
}

@objc public class ShiftCardOptions: NSObject {
  var features: [ShiftCardOptionsKeys: Bool]
  var fontCustomizationOptions: FontCustomizationOptions?

  override init() {
    self.features = [
      .showBalancesSection: true,
      .showActivateCardButton: true,
      .useBalanceVersionV2: false
    ]
    self.fontCustomizationOptions = nil
    super.init()
  }

  public convenience init(features: [ShiftCardOptionsKeys: Bool],
                          fontCustomizationOptions: FontCustomizationOptions? = nil) {
    self.init()
    for (key, value) in features {
      self.features[key] = value
    }
    self.fontCustomizationOptions = fontCustomizationOptions
  }

  @objc public convenience init(features: NSDictionary, fontDescriptors: ThemeFontDescriptors) {
    self.init()
    updateFeatures(with: features)
    self.fontCustomizationOptions = .fontDescriptors(fontDescriptors)
  }

  @objc public convenience init(features: NSDictionary, fontProvider: UIFontProviderProtocol) {
    self.init()
    updateFeatures(with: features)
    self.fontCustomizationOptions = .fontProvider(fontProvider)
  }

  private func updateFeatures(with dictionary: NSDictionary) {
    for (key, value) in dictionary {
      if let intKey = key as? Int, let optionsKey = ShiftCardOptionsKeys(rawValue: intKey),
         let boolValue = value as? Bool {
        self.features[optionsKey] = boolValue
      }
    }
  }
}
