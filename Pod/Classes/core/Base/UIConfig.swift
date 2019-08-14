//
//  UIConfig.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 12/10/2016.
//
//

import Foundation

public enum UITheme: String, Equatable {
  case theme1 = "theme_1"
  case theme2 = "theme_2"
}

public enum StatusBarStyle: String, Equatable {
  case light
  case dark
  case auto
}

@objc open class UIConfig: NSObject {

  // General

  open lazy var uiBackgroundPrimaryColor = UIColor.white
  open lazy var uiBackgroundSecondaryColor = UIColor.white
  open lazy var tintColor = UIColor.white
  open lazy var noteTextColor = UIColor.colorFromHex(0xA0A0A0)
  open lazy var noteBackgroundColor = UIColor.clear
  open lazy var defaultTextColor = UIColor.colorFromHex(0x000000)

  // UI colors

  private let uiColorDisabledAlpha: CGFloat = 0.2
  open lazy var uiPrimaryColor = UIColor.colorFromHex(0x419743)
  open lazy var uiPrimaryColorDisabled = uiPrimaryColor.withAlphaComponent(uiColorDisabledAlpha)
  open lazy var uiSecondaryColor = UIColor.colorFromHex(0x2b2d35)
  open lazy var uiSecondaryColorDisabled = uiSecondaryColor.withAlphaComponent(uiColorDisabledAlpha)
  open lazy var uiTertiaryColor = UIColor.colorFromHex(0xd5d5d7)
  open lazy var uiSuccessColor = UIColor.colorFromHex(0x161d24)
  open lazy var uiErrorColor = UIColor.colorFromHex(0xdb1d0e)
  open lazy var uiToastMessagesColor = uiPrimaryColor.withAlphaComponent(0.15)

  // Navigation bar

  private let navBarDisabledAlpha: CGFloat = 0.4
  open lazy var uiNavigationPrimaryColor = uiPrimaryColor
  open lazy var uiNavigationSecondaryColor = uiPrimaryColor
  open lazy var textTopBarPrimaryColor = UIColor.white
  open lazy var disabledTextTopPrimaryBarColor = textTopBarPrimaryColor.withAlphaComponent(navBarDisabledAlpha)
  open lazy var textTopBarSecondaryColor = UIColor.white
  open lazy var disabledTextTopBarSecondaryColor = textTopBarSecondaryColor.withAlphaComponent(navBarDisabledAlpha)

  // Icon colors

  open lazy var iconPrimaryColor = UIColor.colorFromHex(0x419743)
  open lazy var iconSecondaryColor = UIColor.colorFromHex(0xa9aaaf)
  open lazy var iconTertiaryColor = UIColor.white

  // Text colors

  private let textDisabledAlpha: CGFloat = 0.3
  open lazy var textLinkColor = UIColor.colorFromHex(0x419743)
  open lazy var textPrimaryColor = UIColor.colorFromHex(0x2b2d35)
  open lazy var textPrimaryColorDisabled = textPrimaryColor.withAlphaComponent(textDisabledAlpha)
  open lazy var textSecondaryColor = UIColor.colorFromHex(0x54565f)
  open lazy var textSecondaryColorDisabled = textSecondaryColor.withAlphaComponent(textDisabledAlpha)
  open lazy var textTertiaryColor = UIColor.colorFromHex(0xbbbdbd)
  @available(*, deprecated, renamed: "textTopBarPrimaryColor")
  open lazy var textTopBarColor = UIColor.white
  @available(*, deprecated, renamed: "disabledTextTopPrimaryBarColor")
  open lazy var disabledTextTopBarColor = textTopBarColor.withAlphaComponent(navBarDisabledAlpha)
  open lazy var textMessageColor = UIColor.white
  open lazy var textButtonColor = UIColor.white
  open lazy var underlineLinks = true

  // Stats

  open lazy var statsDifferenceIncreaseBackgroundColor = UIColor.colorFromHex(0x61CA00)
  open lazy var statsDifferenceDecreaseBackgroundColor = UIColor.colorFromHex(0x326700)

  // Toast

  open lazy var showToastTitle = true

  // Transaction details

  open lazy var transactionDetailsShowDetailsSectionTitle = true

  // Disclaimer

  open lazy var disclaimerBackgroundColor = UIColor.colorFromHex(0xf2f3f4)

  // Fonts

  open var fontProvider: UIFontProviderProtocol = UITheme1FontProvider()

  open lazy var shiftNoteFont = UIFont.systemFont(ofSize: 13)
  open lazy var shiftTitleFont = UIFont.systemFont(ofSize: 26)
  open lazy var shiftFont = UIFont.systemFont(ofSize: 18)

  private let overlayBackgroundAlpha: Double = 0.65
  open lazy var overlayBackgroundColor = UIColor.colorFromHex(0x3C4A5B, alpha: overlayBackgroundAlpha)

  // Form customization

  open lazy var fieldCornerRadius: CGFloat = 12

  open lazy var buttonCornerRadius: CGFloat = {
    switch uiTheme {
    case .theme1:
      return 25
    case .theme2:
      return 12
    }
  }()

  open lazy var smallButtonCornerRadius: CGFloat = {
    switch uiTheme {
    case .theme1:
      return 18
    case .theme2:
      return 12
    }
  }()

  open lazy var buttonHeight: CGFloat = {
    switch uiTheme {
    case .theme1:
      return 50
    case .theme2:
      return 56
    }
  }()

  open lazy var smallButtonHeight: CGFloat = {
    switch uiTheme {
    case .theme1:
      return 32
    case .theme2:
      return 48
    }
  }()

  open lazy var formRowHeight: CGFloat = {
    switch uiTheme {
    case .theme1:
      return 40
    case .theme2:
      return 56
    }
  }()

  open lazy var formFieldInternalPadding: CGRect = {
    switch uiTheme {
    case .theme2:
      return CGRect(x: 0, y: 0, width: 15, height: self.formRowHeight)
    case .theme1:
      return CGRect(x: 0, y: 0, width: 0, height: self.formRowHeight)
    }
  }()

  open lazy var formRowPadding: UIEdgeInsets = {
    switch uiTheme {
    case .theme1:
      return UIEdgeInsets(top: 5, left: 16, bottom: 5, right: 16)
    case .theme2:
      return UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    }
  }()

  public lazy var lineSpacing: CGFloat = 1.38

  public lazy var letterSpacing: CGFloat = 0.5

  // Status bar

  open lazy var uiStatusBarStyle: StatusBarStyle = .dark

  // View theme

  open lazy var uiTheme: UITheme = .theme1

  open lazy var formSliderTrackColor = UIColor.colorFromHex(0xEBEBEB)

  public init(projectConfiguration: ProjectConfiguration, fontCustomizationOptions: FontCustomizationOptions? = nil) {
    super.init()
    updateBranding(projectConfiguration.branding)
    setFonts(fontCustomizationOptions: fontCustomizationOptions)
  }

  public init(projectBranding: ProjectBranding, fontCustomizationOptions: FontCustomizationOptions? = nil) {
    super.init()
    updateBranding(projectBranding)
    setFonts(fontCustomizationOptions: fontCustomizationOptions)
  }
}

private extension UIConfig {
  func updateBranding(_ branding: ProjectBranding) {
    // swiftlint:disable force_unwrapping
    uiBackgroundPrimaryColor = UIColor.colorFromHexString(branding.uiBackgroundPrimaryColor)!
    uiBackgroundSecondaryColor = UIColor.colorFromHexString(branding.uiBackgroundSecondaryColor)!
    iconPrimaryColor = UIColor.colorFromHexString(branding.iconPrimaryColor)!
    iconSecondaryColor = UIColor.colorFromHexString(branding.iconSecondaryColor)!
    iconTertiaryColor = UIColor.colorFromHexString(branding.iconTertiaryColor)!
    textPrimaryColor = UIColor.colorFromHexString(branding.textPrimaryColor)!
    textSecondaryColor = UIColor.colorFromHexString(branding.textSecondaryColor)!
    textTertiaryColor = UIColor.colorFromHexString(branding.textTertiaryColor)!
    textTopBarColor = UIColor.colorFromHexString(branding.textTopBarPrimaryColor)!
    textTopBarPrimaryColor = UIColor.colorFromHexString(branding.textTopBarPrimaryColor)!
    textTopBarSecondaryColor = UIColor.colorFromHexString(branding.textTopBarSecondaryColor)!
    textLinkColor = UIColor.colorFromHexString(branding.textLinkColor)!
    underlineLinks = branding.textLinkUnderlined
    textButtonColor = UIColor.colorFromHexString(branding.textButtonColor)!
    buttonCornerRadius = CGFloat(branding.buttonCornerRadius)
    uiPrimaryColor = UIColor.colorFromHexString(branding.uiPrimaryColor)!
    uiSecondaryColor = UIColor.colorFromHexString(branding.uiSecondaryColor)!
    uiTertiaryColor = UIColor.colorFromHexString(branding.uiTertiaryColor)!
    uiErrorColor = UIColor.colorFromHexString(branding.uiErrorColor)!
    uiSuccessColor = UIColor.colorFromHexString(branding.uiSuccessColor)!
    uiNavigationPrimaryColor = UIColor.colorFromHexString(branding.uiNavigationPrimaryColor)!
    uiNavigationSecondaryColor = UIColor.colorFromHexString(branding.uiNavigationSecondaryColor)!
    overlayBackgroundColor = UIColor.colorFromHexString(branding.uiBackgroundOverlayColor,
                                                        alpha: overlayBackgroundAlpha)!
    textMessageColor = UIColor.colorFromHexString(branding.textMessageColor)!
    statsDifferenceIncreaseBackgroundColor = UIColor.colorFromHexString(branding.badgeBackgroundPositiveColor)!
    statsDifferenceDecreaseBackgroundColor = UIColor.colorFromHexString(branding.badgeBackgroundNegativeColor)!
    showToastTitle = branding.showToastTitle
    transactionDetailsShowDetailsSectionTitle = branding.transactionDetailsCollapsable
    disclaimerBackgroundColor = UIColor.colorFromHexString(branding.disclaimerBackgroundColor)!
    uiStatusBarStyle = StatusBarStyle(rawValue: branding.uiStatusBarStyle)!
    uiTheme = UITheme(rawValue: branding.uiTheme)!
    // swiftlint:enable force_unwrapping
  }

  func setFonts(fontCustomizationOptions: FontCustomizationOptions?) {
    switch self.uiTheme {
    case .theme1:
      self.fontProvider = UITheme1FontProvider()
    case .theme2:
      if let fontCustomizationOptions = fontCustomizationOptions {
        switch fontCustomizationOptions {
        case .fontDescriptors(let descriptors):
          self.fontProvider = UITheme2FontProvider(fontDescriptors: descriptors)
        case .fontProvider(let provider):
          self.fontProvider = provider
        }
      }
      else {
        self.fontProvider = UITheme2FontProvider(fontDescriptors: nil)
      }
    }
  }
}
