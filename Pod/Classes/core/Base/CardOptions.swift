//
//  CardOptions.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 30/07/2018.
//

@objc public enum FeatureKey: Int {
    case showActivateCardButton
    case showStatsButton
    case showNotificationPreferences
    case showDetailedCardActivityOption
    case hideFundingSourcesReconnectButton
    case showAccountSettingsButton
    case showMonthlyStatementsOption
    case authenticateOnStartUp
    case supportDarkMode
}

@objc public enum PCIAuthType: Int {
    case pinOrBiometrics
    case biometrics
    case none
}

@objc public class CardOptions: NSObject {
    var features: [FeatureKey: Bool]
    public var fontCustomizationOptions: FontCustomizationOptions?

    public var authenticateOnPCI: PCIAuthType

    override init() {
        features = [
            .showActivateCardButton: true,
            .showStatsButton: false,
            .showNotificationPreferences: false,
            .showDetailedCardActivityOption: false,
            .hideFundingSourcesReconnectButton: false,
            .showAccountSettingsButton: true,
            .showMonthlyStatementsOption: true,
            .authenticateOnStartUp: false,
            .supportDarkMode: false,
        ]
        fontCustomizationOptions = nil
        authenticateOnPCI = .none
        super.init()
    }

    public convenience init(features: [FeatureKey: Bool],
                            fontCustomizationOptions: FontCustomizationOptions? = nil,
                            authenticateOnPCI: PCIAuthType = .none)
    {
        self.init()
        for (key, value) in features {
            self.features[key] = value
        }
        self.fontCustomizationOptions = fontCustomizationOptions
        self.authenticateOnPCI = authenticateOnPCI
    }

    @objc public convenience init(features: NSDictionary, fontDescriptors: ThemeFontDescriptors) {
        self.init()
        updateFeatures(with: features)
        fontCustomizationOptions = .fontDescriptors(fontDescriptors)
    }

    @objc public convenience init(features: NSDictionary, fontProvider: UIFontProviderProtocol) {
        self.init()
        updateFeatures(with: features)
        fontCustomizationOptions = .fontProvider(fontProvider)
    }

    private func updateFeatures(with dictionary: NSDictionary) {
        for (key, value) in dictionary {
            if let intKey = key as? Int, let featureKey = FeatureKey(rawValue: intKey),
               let boolValue = value as? Bool
            {
                features[featureKey] = boolValue
            }
        }
    }
}
