//
//  ShiftUIConfig.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 12/10/2016.
//
//

import Foundation

public enum UITheme: String, Equatable {
  case theme1 = "theme_1"
  case theme2 = "theme_2"
}

@objc open class ShiftUIConfig: NSObject {
  // General

  open lazy var backgroundColor = UIColor.white
  open lazy var tintColor = UIColor.white
  open lazy var disabledTintColor = UIColor.colorFromHex(0x17a94f, alpha: 0.5)
  open lazy var disabledColor = UIColor.colorFromHex(0xcccccc)
  open lazy var noteTextColor = UIColor.colorFromHex(0xA0A0A0)
  open lazy var noteBackgroundColor = UIColor.clear
  open lazy var defaultTextColor = UIColor.colorFromHex(0x000000)

  // UI colors

  open lazy var uiPrimaryColor = UIColor.colorFromHex(0x419743)
  open lazy var uiPrimaryColorDisabled = uiPrimaryColor.withAlphaComponent(0.2)
  open lazy var uiSecondaryColor = UIColor.colorFromHex(0x2b2d35)
  open lazy var uiSecondaryColorDisabled = uiSecondaryColor.withAlphaComponent(0.2)
  open lazy var uiTertiaryColor = UIColor.colorFromHex(0xd5d5d7)
  open lazy var uiSuccessColor = UIColor.colorFromHex(0x161d24)
  open lazy var uiErrorColor = UIColor.colorFromHex(0xdb1d0e)
  open lazy var uiToastMessagesColor = uiPrimaryColor.withAlphaComponent(0.15)

  // Icon colors

  open lazy var iconPrimaryColor = UIColor.colorFromHex(0x419743)
  open lazy var iconSecondaryColor = UIColor.colorFromHex(0xa9aaaf)
  open lazy var iconTertiaryColor = UIColor.white

  // Text colors

  open lazy var textLinkColor = UIColor.colorFromHex(0x419743)
  open lazy var textPrimaryColor = UIColor.colorFromHex(0x2b2d35)
  open lazy var textPrimaryColorDisabled = textPrimaryColor.withAlphaComponent(0.3)
  open lazy var textSecondaryColor = UIColor.colorFromHex(0x54565f)
  open lazy var textSecondaryColorDisabled = textSecondaryColor.withAlphaComponent(0.3)
  open lazy var textTertiaryColor = UIColor.colorFromHex(0xbbbdbd)
  open lazy var textTopBarColor = UIColor.white
  open lazy var disabledTextTopBarColor = textTopBarColor.withAlphaComponent(0.4)

  // Fonts

  open var fontProvider: UIFontProviderProtocol = UITheme1FontProvider()

  open lazy var fonth6 = UIFont(name: "HelveticaNeue-Light", size: 12)!
  open lazy var fonth5 = UIFont(name: "HelveticaNeue-Light", size: 14)!
  open lazy var fonth4 = UIFont(name: "HelveticaNeue-Light", size: 16)!
  open lazy var fonth3 = UIFont(name: "HelveticaNeue-Light", size: 18)!
  open lazy var fonth2 = UIFont(name: "HelveticaNeue-Light", size: 20)!
  open lazy var fonth1 = UIFont(name: "HelveticaNeue-Light", size: 24)!
  open lazy var fonth0 = UIFont(name: "HelveticaNeue-Light", size: 32)!

  open lazy var shiftNoteFont = UIFont.systemFont(ofSize: 13)
  open lazy var shiftTitleFont = UIFont.systemFont(ofSize: 26)
  open lazy var shiftFont = UIFont.systemFont(ofSize: 18)

  // Cards

  open lazy var cardLabelColor = UIColor.white.withAlphaComponent(0.7)

  // Form customization

  open lazy var buttonCornerRadius: CGFloat = {
    switch uiTheme {
    case .theme1:
      return 25
    case .theme2:
      return 12
    }
  }()

  // Status bar

  open lazy var statusBarStyle: UIStatusBarStyle = .default

  // View theme

  open lazy var uiTheme: UITheme = .theme1

  open lazy var formLabelWidth: CGFloat = 90
  open lazy var formSubtitleColor = UIColor.colorFromHex(0xA0A0A0)
  open lazy var formSubtitleBackgroundColor = UIColor.clear
  open lazy var formSliderTrackColor = UIColor.colorFromHex(0xEBEBEB)
  open lazy var formAuxiliarViewBackgroundColor = UIColor.colorFromHex(0xfafafa)
  open lazy var formSuperProminentLabelTextColor = UIColor.colorFromHex(0x006837)

  // Offer List customization

  open lazy var offerApplyButtonBackgroundColor = UIColor.clear
  open lazy var offerLabelBackgroundColor = UIColor.clear
  open lazy var offerValueBackgroundColor = UIColor.clear

  // Application List customization

  open lazy var applicationListHeaderBorderColor = UIColor.colorFromHex(0x9d9d9d)
  open lazy var applicationListNavigationBackgrundColor = UIColor.colorFromHex(0xffffff)
  open lazy var applicationListNavigationBorderColor = UIColor.colorFromHex(0xcccccc)
  open lazy var applicationLabelBackgroundColor = UIColor.clear
  open lazy var applicationValueBackgroundColor = UIColor.clear

  // Document uploader customization

  open lazy var docUploaderButtonBackgroundColor = UIColor.clear
  open lazy var docUploaderEnabledButtonColor = UIColor.colorFromHex(0x1b9af7)
  open lazy var docUploaderDisabledButtonColor = UIColor.colorFromHex(0x666666)
  open lazy var docUploaderEnabledNameLabelColor = UIColor.colorFromHex(0x1b9af7)
  open lazy var docUploaderDisabledNameLabelColor = UIColor.colorFromHex(0x666666)

  // Loan Consent customization

  open lazy var sectionTitleBackgroundColor = UIColor.colorFromHex(0xf1f1f1)
  open lazy var sectionTitleTextColor = UIColor.black
  open lazy var loanConsentSignLabelBackgroundColor = UIColor.clear

  public init(projectConfiguration: ProjectConfiguration, fontCustomizationOptions: FontCustomizationOptions? = nil) {
    super.init()
    // swiftlint:disable force_unwrapping
    self.iconPrimaryColor = UIColor.colorFromHexString(projectConfiguration.branding.iconPrimaryColor)!
    self.iconSecondaryColor = UIColor.colorFromHexString(projectConfiguration.branding.iconSecondaryColor)!
    self.iconTertiaryColor = UIColor.colorFromHexString(projectConfiguration.branding.iconTertiaryColor)!
    self.textPrimaryColor = UIColor.colorFromHexString(projectConfiguration.branding.textPrimaryColor)!
    self.textSecondaryColor = UIColor.colorFromHexString(projectConfiguration.branding.textSecondaryColor)!
    self.textTertiaryColor = UIColor.colorFromHexString(projectConfiguration.branding.textTertiaryColor)!
    self.textTopBarColor = UIColor.colorFromHexString(projectConfiguration.branding.textTopBarColor)!
    self.textLinkColor = UIColor.colorFromHexString(projectConfiguration.branding.textLinkColor)!
    self.uiPrimaryColor = UIColor.colorFromHexString(projectConfiguration.branding.uiPrimaryColor)!
    self.uiSecondaryColor = UIColor.colorFromHexString(projectConfiguration.branding.uiSecondaryColor)!
    self.uiTertiaryColor = UIColor.colorFromHexString(projectConfiguration.branding.uiTertiaryColor)!
    self.uiErrorColor = UIColor.colorFromHexString(projectConfiguration.branding.uiErrorColor)!
    self.uiSuccessColor = UIColor.colorFromHexString(projectConfiguration.branding.uiSuccessColor)!
    self.uiTheme = UITheme(rawValue: projectConfiguration.branding.uiTheme)!
    // swiftlint:enable force_unwrapping
    self.statusBarStyle = .lightContent
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
    registerCustomFonts()
  }

  private static var fontRegistered = false
  private static let queue = DispatchQueue(label: "com.shiftpayments.sdk.register.fonts")
}

private extension ShiftUIConfig {
  func registerCustomFonts() {
    ShiftUIConfig.queue.sync {
      guard !ShiftUIConfig.fontRegistered else {
        return
      }
      ShiftUIConfig.fontRegistered = true
      let bundle = Bundle(for: ShiftUIConfig.self)
      guard let url = bundle.url(forResource: "ocraextended", withExtension: "ttf"),
            let fontDataProvider = CGDataProvider(url: url as CFURL),
            let font = CGFont(fontDataProvider) else {
        fatalError("Could not register fonts")
      }
      var error: Unmanaged<CFError>?
      guard CTFontManagerRegisterGraphicsFont(font, &error) else {
        fatalError("Could not register fonts")
      }
    }
  }
}
