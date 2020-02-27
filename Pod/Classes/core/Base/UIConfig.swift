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
  // Branding
  private let lightBranding: ParsedProjectBranding
  private let darkBranding: ParsedProjectBranding

  // General

  public lazy var uiBackgroundPrimaryColor = UIColor.dynamicColor(light: lightBranding.uiBackgroundPrimaryColor,
                                                                  dark: darkBranding.uiBackgroundPrimaryColor)
  public lazy var uiBackgroundSecondaryColor = UIColor.dynamicColor(light: lightBranding.uiBackgroundSecondaryColor,
                                                                    dark: darkBranding.uiBackgroundSecondaryColor)

  // UI colors

  private let uiColorDisabledAlpha: CGFloat = 0.2

  public lazy var uiPrimaryColor = UIColor.dynamicColor(light: lightBranding.uiPrimaryColor,
                                                        dark: darkBranding.uiPrimaryColor)
  public var uiPrimaryColorDisabled: UIColor { uiPrimaryColor.withAlphaComponent(uiColorDisabledAlpha) }
  public lazy var uiSecondaryColor = UIColor.dynamicColor(light: lightBranding.uiSecondaryColor,
                                                          dark: darkBranding.uiSecondaryColor)
  public var uiSecondaryColorDisabled: UIColor { uiSecondaryColor.withAlphaComponent(uiColorDisabledAlpha) }
  public lazy var uiTertiaryColor = UIColor.dynamicColor(light: lightBranding.uiTertiaryColor,
                                                         dark: darkBranding.uiTertiaryColor)
  public lazy var uiSuccessColor = UIColor.dynamicColor(light: lightBranding.uiSuccessColor,
                                                        dark: darkBranding.uiSuccessColor)
  public lazy var uiErrorColor = UIColor.dynamicColor(light: lightBranding.uiErrorColor,
                                                      dark: darkBranding.uiErrorColor)
  public var uiToastMessagesColor: UIColor { uiPrimaryColor.withAlphaComponent(0.15) }

  // Navigation bar

  private let navBarDisabledAlpha: CGFloat = 0.4
  public lazy var uiNavigationPrimaryColor = UIColor.dynamicColor(light: lightBranding.uiNavigationPrimaryColor,
                                                                  dark: darkBranding.uiNavigationPrimaryColor)
  public lazy var uiNavigationSecondaryColor = UIColor.dynamicColor(light: lightBranding.uiNavigationSecondaryColor,
                                                                    dark: darkBranding.uiNavigationSecondaryColor)
  public lazy var textTopBarPrimaryColor = UIColor.dynamicColor(light: lightBranding.textTopBarPrimaryColor,
                                                                dark: darkBranding.textTopBarPrimaryColor)
  public var disabledTextTopPrimaryBarColor: UIColor { textTopBarPrimaryColor.withAlphaComponent(navBarDisabledAlpha) }
  public lazy var textTopBarSecondaryColor = UIColor.dynamicColor(light: lightBranding.textTopBarSecondaryColor,
                                                                  dark: darkBranding.textTopBarSecondaryColor)
  public var disabledTextTopBarSecondaryColor: UIColor {
    textTopBarSecondaryColor.withAlphaComponent(navBarDisabledAlpha)
  }

  // Icon colors

  public lazy var iconPrimaryColor = UIColor.dynamicColor(light: lightBranding.iconPrimaryColor,
                                                          dark: darkBranding.iconPrimaryColor)
  public lazy var iconSecondaryColor = UIColor.dynamicColor(light: lightBranding.iconSecondaryColor,
                                                            dark: darkBranding.iconSecondaryColor)
  public lazy var iconTertiaryColor = UIColor.dynamicColor(light: lightBranding.iconTertiaryColor,
                                                           dark: darkBranding.iconTertiaryColor)

  // Text colors

  private let textDisabledAlpha: CGFloat = 0.3
  public lazy var textLinkColor = UIColor.dynamicColor(light: lightBranding.textLinkColor,
                                                       dark: darkBranding.textLinkColor)
  public lazy var textPrimaryColor = UIColor.dynamicColor(light: lightBranding.textPrimaryColor,
                                                          dark: darkBranding.textPrimaryColor)
  public var textPrimaryColorDisabled: UIColor { textPrimaryColor.withAlphaComponent(textDisabledAlpha) }
  public lazy var textSecondaryColor = UIColor.dynamicColor(light: lightBranding.textSecondaryColor,
                                                            dark: darkBranding.textSecondaryColor)
  public var textSecondaryColorDisabled: UIColor { textSecondaryColor.withAlphaComponent(textDisabledAlpha) }
  public lazy var textTertiaryColor = UIColor.dynamicColor(light: lightBranding.textTertiaryColor,
                                                           dark: darkBranding.textTertiaryColor)
  public lazy var textMessageColor = UIColor.dynamicColor(light: lightBranding.textMessageColor,
                                                          dark: darkBranding.textMessageColor)
  public lazy var textButtonColor = UIColor.dynamicColor(light: lightBranding.textButtonColor,
                                                         dark: darkBranding.textButtonColor)
  public lazy var underlineLinks: Bool = lightBranding.underlineLinks

  // Stats

  public lazy var statsDifferenceIncreaseBackgroundColor = UIColor.dynamicColor(
    light: lightBranding.statsDifferenceIncreaseBackgroundColor,
    dark: darkBranding.statsDifferenceIncreaseBackgroundColor
  )
  public lazy var statsDifferenceDecreaseBackgroundColor = UIColor.dynamicColor(
     light: lightBranding.statsDifferenceDecreaseBackgroundColor,
     dark: darkBranding.statsDifferenceDecreaseBackgroundColor
   )

  // Toast

  public lazy var showToastTitle = lightBranding.showToastTitle

  // Transaction details

  public lazy var transactionDetailsShowDetailsSectionTitle = lightBranding.transactionDetailsShowDetailsSectionTitle


  // Disclaimer

  public lazy var disclaimerBackgroundColor = UIColor.dynamicColor(light: lightBranding.disclaimerBackgroundColor,
                                                                   dark: darkBranding.disclaimerBackgroundColor)

  // Fonts

  open var fontProvider: UIFontProviderProtocol = UITheme1FontProvider()

  public lazy var overlayBackgroundColor = UIColor.dynamicColor(light: lightBranding.overlayBackgroundColor,
                                                                dark: darkBranding.overlayBackgroundColor)

  // Form customization

  open lazy var fieldCornerRadius: CGFloat = 12

  public lazy var buttonCornerRadius: CGFloat = lightBranding.buttonCornerRadius

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

  public lazy var uiStatusBarStyle: StatusBarStyle = lightBranding.uiStatusBarStyle

  // View theme

  public lazy var uiTheme = lightBranding.uiTheme

  // Deprecated properties
  @available(*, deprecated, message: "use the appropriate branding color")
  open lazy var tintColor = UIColor.white
  @available(*, deprecated, message: "use the appropriate branding color")
  open lazy var noteTextColor = UIColor.colorFromHex(0xA0A0A0)
  @available(*, deprecated, message: "use the appropriate branding color")
  open lazy var noteBackgroundColor = UIColor.clear
  @available(*, deprecated, message: "use the appropriate branding color")
  open lazy var defaultTextColor = UIColor.colorFromHex(0x000000)
  @available(*, deprecated, renamed: "textTopBarPrimaryColor")
  public lazy var textTopBarColor: UIColor = lightBranding.textTopBarColor
  @available(*, deprecated, renamed: "disabledTextTopPrimaryBarColor")
  public lazy var disabledTextTopBarColor: UIColor = textTopBarColor.withAlphaComponent(navBarDisabledAlpha)
  @available(*, deprecated, message: "use the appropriate branding font")
  open lazy var shiftNoteFont = UIFont.systemFont(ofSize: 13)
  @available(*, deprecated, message: "use the appropriate branding font")
  open lazy var shiftTitleFont = UIFont.systemFont(ofSize: 26)
  @available(*, deprecated, message: "use the appropriate branding font")
  open lazy var shiftFont = UIFont.systemFont(ofSize: 18)
  @available(*, deprecated, message: "use the appropriate branding color")
  open lazy var formSliderTrackColor = UIColor.colorFromHex(0xEBEBEB)

  public convenience init(projectConfiguration: ProjectConfiguration,
                          fontCustomizationOptions: FontCustomizationOptions? = nil) {
    self.init(branding: projectConfiguration.branding, fontCustomizationOptions: fontCustomizationOptions)
  }

  public init(branding: Branding, fontCustomizationOptions: FontCustomizationOptions? = nil) {
    self.lightBranding = ParsedProjectBranding(branding: branding.light)
    self.darkBranding = ParsedProjectBranding(branding: branding.dark)
    super.init()
    setFonts(fontCustomizationOptions: fontCustomizationOptions)
  }
}

private extension UIConfig {
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

private struct ParsedProjectBranding {
  let uiBackgroundPrimaryColor: UIColor
  let uiBackgroundSecondaryColor: UIColor
  let iconPrimaryColor: UIColor
  let iconSecondaryColor: UIColor
  let iconTertiaryColor: UIColor
  let textPrimaryColor: UIColor
  let textSecondaryColor: UIColor
  let textTertiaryColor: UIColor
  let textTopBarColor: UIColor
  let textTopBarPrimaryColor: UIColor
  let textTopBarSecondaryColor: UIColor
  let textLinkColor: UIColor
  let underlineLinks: Bool
  let textButtonColor: UIColor
  let buttonCornerRadius: CGFloat
  let uiPrimaryColor: UIColor
  let uiSecondaryColor: UIColor
  let uiTertiaryColor: UIColor
  let uiErrorColor: UIColor
  let uiSuccessColor: UIColor
  let uiNavigationPrimaryColor: UIColor
  let uiNavigationSecondaryColor: UIColor
  let overlayBackgroundColor: UIColor
  let textMessageColor: UIColor
  let statsDifferenceIncreaseBackgroundColor: UIColor
  let statsDifferenceDecreaseBackgroundColor: UIColor
  let showToastTitle: Bool
  let transactionDetailsShowDetailsSectionTitle: Bool
  let disclaimerBackgroundColor: UIColor
  let uiStatusBarStyle: StatusBarStyle
  let uiTheme: UITheme

  init(branding: ProjectBranding) {
    let overlayBackgroundAlpha: Double = 0.65
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
}
