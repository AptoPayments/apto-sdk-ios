//
//  UIFontProvider.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 29/10/2018.
//

import UIKit

public enum FontCustomizationOptions {
    case fontDescriptors(ThemeFontDescriptors)
    case fontProvider(UIFontProviderProtocol)
}

@objc public class ThemeFontDescriptors: NSObject {
    public let regular: UIFontDescriptor
    public let medium: UIFontDescriptor
    public let semibold: UIFontDescriptor
    public let bold: UIFontDescriptor

    @objc public init(regular: UIFontDescriptor,
                      medium: UIFontDescriptor,
                      semibold: UIFontDescriptor,
                      bold: UIFontDescriptor)
    {
        self.regular = regular
        self.medium = medium
        self.semibold = semibold
        self.bold = bold
        super.init()
    }
}

@objc public protocol UIFontProviderProtocol {
    var formFieldFont: UIFont { get }
    var formLabelFont: UIFont { get }
    var formListFont: UIFont { get }
    var formTextLink: UIFont { get }

    var primaryCallToActionFont: UIFont { get }
    var primaryCallToActionFontSmall: UIFont { get }

    var amountBigFont: UIFont { get }
    var amountMediumFont: UIFont { get }
    var amountSmallFont: UIFont { get }
    var sectionTitleFont: UIFont { get }
    var starredSectionTitleFont: UIFont { get }
    var subCurrencyFont: UIFont { get }

    var itemDescriptionFont: UIFont { get }
    var mainItemLightFont: UIFont { get }
    var mainItemRegularFont: UIFont { get }
    var instructionsFont: UIFont { get }
    var timestampFont: UIFont { get }
    var textLinkFont: UIFont { get }

    var topBarAmountFont: UIFont { get }
    var topBarTitleFont: UIFont { get }
    var topBarTitleBigFont: UIFont { get }
    var topBarItemFont: UIFont { get }
    var topBarTitleHugeFont: UIFont { get }

    var largeTitleFont: UIFont { get }

    var errorTitleFont: UIFont { get }
    var errorMessageFont: UIFont { get }
    var boldMessageFont: UIFont { get }

    var cardLabelFont: UIFont { get }
    var cardSmallValueFont: UIFont { get }
    var cardLargeValueFont: UIFont { get }

    var keyboardFont: UIFont { get }
    var cardDetailsTextFont: UIFont { get }

    var footerTextFont: UIFont { get }
}

public class UITheme1FontProvider: UIFontProviderProtocol {
    public lazy var formFieldFont = UIFont.systemFont(ofSize: 24, weight: .light)
    public lazy var formLabelFont = UIFont.systemFont(ofSize: 16, weight: .medium)
    public lazy var formListFont = UIFont.systemFont(ofSize: 16, weight: .regular)
    public lazy var formTextLink = UIFont.systemFont(ofSize: 13, weight: .regular)
    public lazy var footerTextFont = UIFont.systemFont(ofSize: 13, weight: .regular)

    public lazy var primaryCallToActionFont = UIFont.systemFont(ofSize: 17, weight: .semibold)
    public lazy var primaryCallToActionFontSmall = UIFont.systemFont(ofSize: 14, weight: .semibold)

    public lazy var amountBigFont = UIFont.systemFont(ofSize: 24, weight: .light)
    public lazy var amountMediumFont = UIFont.systemFont(ofSize: 20, weight: .regular)
    public lazy var amountSmallFont = UIFont.systemFont(ofSize: 18, weight: .light)
    public lazy var sectionTitleFont = UIFont.systemFont(ofSize: 14, weight: .bold)
    public lazy var starredSectionTitleFont = UIFont.systemFont(ofSize: 14, weight: .medium)
    public lazy var subCurrencyFont = UIFont.systemFont(ofSize: 13, weight: .semibold)

    public lazy var itemDescriptionFont = UIFont.systemFont(ofSize: 13, weight: .medium)
    public lazy var mainItemLightFont = UIFont.systemFont(ofSize: 18, weight: .thin)
    public lazy var mainItemRegularFont = UIFont.systemFont(ofSize: 18, weight: .regular)
    public lazy var instructionsFont = UIFont.systemFont(ofSize: 13, weight: .regular)
    public lazy var timestampFont = UIFont.systemFont(ofSize: 12, weight: .regular)
    public lazy var textLinkFont = UIFont.systemFont(ofSize: 15, weight: .medium)

    public lazy var topBarAmountFont = UIFont.systemFont(ofSize: 20, weight: .light)
    public lazy var topBarTitleFont = UIFont.systemFont(ofSize: 17, weight: .medium)
    public lazy var topBarTitleBigFont = UIFont.systemFont(ofSize: 20, weight: .regular)
    public lazy var topBarItemFont = UIFont.systemFont(ofSize: 10, weight: .regular)
    public lazy var topBarTitleHugeFont = UIFont.systemFont(ofSize: 34, weight: .regular)

    public lazy var largeTitleFont = UIFont.systemFont(ofSize: 28, weight: .black)

    public lazy var errorTitleFont = UIFont.systemFont(ofSize: 24, weight: .medium)
    public lazy var errorMessageFont = UIFont.systemFont(ofSize: 16, weight: .regular)
    public lazy var boldMessageFont = UIFont.systemFont(ofSize: 15, weight: .bold)

    public lazy var cardLabelFont = UIFont.systemFont(ofSize: 10, weight: .regular)
    // swiftlint:disable force_unwrapping
    public lazy var cardSmallValueFont = UIFont(name: "OCR A Extended", size: 17)!
    public lazy var cardLargeValueFont = UIFont(name: "OCR A Extended", size: 24)!
    // swiftlint:enable force_unwrapping

    public lazy var keyboardFont = UIFont.systemFont(ofSize: 32, weight: .regular)
    public lazy var cardDetailsTextFont = UIFont.systemFont(ofSize: 16, weight: .regular)
}

public class UITheme2FontProvider: UIFontProviderProtocol {
    private let fontDescriptors: ThemeFontDescriptors

    public lazy var formFieldFont = {
        UIFont(descriptor: fontDescriptors.regular, size: 18)
    }()

    public lazy var formLabelFont = {
        UIFont(descriptor: fontDescriptors.regular, size: 16)
    }()

    public lazy var formListFont = {
        UIFont(descriptor: fontDescriptors.regular, size: 18)
    }()

    public lazy var formTextLink = {
        UIFont(descriptor: fontDescriptors.semibold, size: 14)
    }()

    public lazy var footerTextFont = {
        UIFont(descriptor: fontDescriptors.regular, size: 13)
    }()

    public lazy var primaryCallToActionFont = {
        UIFont(descriptor: fontDescriptors.medium, size: 18)
    }()

    public lazy var primaryCallToActionFontSmall = {
        UIFont(descriptor: fontDescriptors.medium, size: 15)
    }()

    public lazy var amountBigFont = {
        UIFont(descriptor: fontDescriptors.bold, size: 26)
    }()

    public lazy var amountMediumFont = {
        UIFont(descriptor: fontDescriptors.medium, size: 18)
    }()

    public lazy var amountSmallFont = {
        UIFont(descriptor: fontDescriptors.medium, size: 17)
    }()

    public lazy var sectionTitleFont = {
        UIFont(descriptor: fontDescriptors.medium, size: 14)
    }()

    public lazy var starredSectionTitleFont = {
        UIFont(descriptor: fontDescriptors.regular, size: 12)
    }()

    public lazy var subCurrencyFont = {
        UIFont(descriptor: fontDescriptors.regular, size: 16)
    }()

    public lazy var itemDescriptionFont = {
        UIFont(descriptor: fontDescriptors.regular, size: 13)
    }()

    public lazy var mainItemLightFont = {
        UIFont(descriptor: fontDescriptors.medium, size: 16)
    }()

    public lazy var mainItemRegularFont = {
        UIFont(descriptor: fontDescriptors.medium, size: 16)
    }()

    public lazy var instructionsFont = {
        UIFont(descriptor: fontDescriptors.regular, size: 13)
    }()

    public lazy var timestampFont = {
        UIFont(descriptor: fontDescriptors.regular, size: 13)
    }()

    public lazy var textLinkFont = {
        UIFont(descriptor: fontDescriptors.medium, size: 14)
    }()

    public lazy var topBarAmountFont = {
        UIFont(descriptor: fontDescriptors.medium, size: 22)
    }()

    public lazy var topBarTitleFont = {
        UIFont(descriptor: fontDescriptors.bold, size: 18)
    }()

    public lazy var topBarTitleBigFont = {
        UIFont(descriptor: fontDescriptors.bold, size: 26)
    }()

    public lazy var topBarTitleHugeFont = {
        UIFont(descriptor: fontDescriptors.bold, size: 34)
    }()

    public lazy var topBarItemFont = {
        UIFont(descriptor: fontDescriptors.regular, size: 10)
    }()

    public lazy var largeTitleFont = {
        UIFont(descriptor: fontDescriptors.bold, size: 26)
    }()

    public lazy var errorTitleFont = {
        UIFont(descriptor: fontDescriptors.medium, size: 14)
    }()

    public lazy var errorMessageFont = {
        UIFont(descriptor: fontDescriptors.medium, size: 16)
    }()

    public lazy var boldMessageFont = {
        UIFont(descriptor: fontDescriptors.bold, size: 15)
    }()

    public lazy var cardLabelFont = UIFont.systemFont(ofSize: 10, weight: .regular)
    // swiftlint:disable force_unwrapping
    public lazy var cardSmallValueFont = UIFont(name: "OCR A Extended", size: 17)!
    public lazy var cardLargeValueFont = UIFont(name: "OCR A Extended", size: 24)!
    // swiftlint:enable force_unwrapping

    public lazy var keyboardFont = {
        UIFont(descriptor: fontDescriptors.regular, size: 32)
    }()

    public lazy var cardDetailsTextFont = {
        UIFont(descriptor: fontDescriptors.regular, size: 16)
    }()

    public init(fontDescriptors: ThemeFontDescriptors?) {
        let descriptors: ThemeFontDescriptors
        if let fontDescriptors = fontDescriptors {
            descriptors = fontDescriptors
        } else {
            descriptors = ThemeFontDescriptors(regular: UIFont.systemFont(ofSize: 0, weight: .regular).fontDescriptor,
                                               medium: UIFont.systemFont(ofSize: 0, weight: .medium).fontDescriptor,
                                               semibold: UIFont.systemFont(ofSize: 0, weight: .semibold).fontDescriptor,
                                               bold: UIFont.systemFont(ofSize: 0, weight: .bold).fontDescriptor)
        }
        self.fontDescriptors = descriptors
    }
}
