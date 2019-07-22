//
//  CardOptions.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 30/07/2018.
//
@objc public enum FeatureKey: Int {
  case showActivateCardButton
  case useBalanceVersionV2
  case showStatsButton
  case showNotificationPreferences
  case showDetailedCardActivityOption
}

@objc public class CardOptions: NSObject {
  var features: [FeatureKey: Bool]
  public var fontCustomizationOptions: FontCustomizationOptions?

  override init() {
    self.features = [
      .showActivateCardButton: true,
      .useBalanceVersionV2: false,
      .showStatsButton: false,
      .showNotificationPreferences: false,
      .showDetailedCardActivityOption: false
    ]
    self.fontCustomizationOptions = nil
    super.init()
  }

  public convenience init(features: [FeatureKey: Bool], fontCustomizationOptions: FontCustomizationOptions? = nil) {
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
      if let intKey = key as? Int, let featureKey = FeatureKey(rawValue: intKey),
         let boolValue = value as? Bool {
        self.features[featureKey] = boolValue
      }
    }
  }
}
