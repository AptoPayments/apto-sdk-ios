//
//  ComponentCatalog.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 13/08/2018.
//

import UIKit
import PhoneNumberKit

class ComponentCatalog {

  static func amountBigLabelWith(text: String,
                                 textAlignment: NSTextAlignment = .left,
                                 accessibilityLabel: String? = nil,
                                 uiConfig: ShiftUIConfig) -> UILabel {
    let retVal = UILabel()
    retVal.text = text
    retVal.font = uiConfig.fontProvider.amountBigFont
    retVal.textColor = uiConfig.textPrimaryColor
    retVal.textAlignment = textAlignment
    retVal.accessibilityLabel = accessibilityLabel
    return retVal
  }

  static func amountMediumLabelWith(text: String,
                                    textAlignment: NSTextAlignment = .left,
                                    accessibilityLabel: String? = nil,
                                    uiConfig: ShiftUIConfig) -> UILabel {
    let retVal = UILabel()
    retVal.text = text
    retVal.font = uiConfig.fontProvider.amountMediumFont
    retVal.textColor = uiConfig.textSecondaryColor
    retVal.textAlignment = textAlignment
    retVal.accessibilityLabel = accessibilityLabel
    return retVal
  }

  static func amountSmallLabelWith(text: String,
                                   textAlignment: NSTextAlignment = .left,
                                   accessibilityLabel: String? = nil,
                                   uiConfig: ShiftUIConfig) -> UILabel {
    let retVal = UILabel()
    retVal.text = text
    retVal.font = uiConfig.fontProvider.amountSmallFont
    retVal.textColor = uiConfig.textPrimaryColor
    retVal.textAlignment = textAlignment
    retVal.accessibilityLabel = accessibilityLabel
    return retVal
  }

  static func formLabelWith(text: String,
                            textAlignment: NSTextAlignment = .left,
                            multiline: Bool = false,
                            lineSpacing: CGFloat? = nil,
                            letterSpacing: CGFloat? = nil,
                            accessibilityLabel: String? = nil,
                            uiConfig: ShiftUIConfig) -> UILabel {
    let retVal = UILabel()
    let textColor = uiConfig.uiTheme == .theme1 ? uiConfig.textPrimaryColor : uiConfig.textSecondaryColor
    if let lineSpacing = lineSpacing {
      let paragraphStyle = NSMutableParagraphStyle()
      paragraphStyle.alignment = textAlignment
      paragraphStyle.lineSpacing = lineSpacing
      var textAttributes: [NSAttributedStringKey: Any] = [
        .foregroundColor: textColor,
        .font: uiConfig.fontProvider.formLabelFont,
        .paragraphStyle: paragraphStyle
      ]
      if let letterSpacing = letterSpacing {
        textAttributes[.kern] = letterSpacing
      }
      retVal.attributedText = NSAttributedString(string: text, attributes: textAttributes)
    }
    else {
      retVal.text = text
      retVal.font = uiConfig.fontProvider.formLabelFont
      retVal.textColor = textColor
      retVal.textAlignment = textAlignment
    }
    retVal.accessibilityLabel = accessibilityLabel
    if multiline {
      retVal.numberOfLines = 0
    }
    return retVal
  }

  static func formListLabelWith(text: String,
                                textAlignment: NSTextAlignment = .left,
                                multiline: Bool = false,
                                accessibilityLabel: String? = nil,
                                uiConfig: ShiftUIConfig) -> UILabel {
    let retVal = UILabel()
    retVal.text = text
    retVal.font = uiConfig.fontProvider.formListFont
    retVal.textColor = uiConfig.textSecondaryColor
    retVal.textAlignment = textAlignment
    retVal.accessibilityLabel = accessibilityLabel
    if multiline {
      retVal.numberOfLines = 0
    }
    return retVal
  }

  static func formFieldWith(placeholder: String,
                            value: String?,
                            accessibilityLabel: String? = nil,
                            uiConfig: ShiftUIConfig) -> UITextField {
    let retVal = UITextField()
    retVal.placeholder = placeholder
    retVal.text = value
    retVal.keyboardType = .alphabet
    retVal.autocapitalizationType = .none
    retVal.spellCheckingType = .no
    retVal.autocorrectionType = .no
    retVal.clearsOnInsertion = false
    retVal.clearsOnBeginEditing = false
    retVal.returnKeyType = .next
    retVal.enablesReturnKeyAutomatically = true
    retVal.backgroundColor = .clear
    retVal.font = uiConfig.fontProvider.formFieldFont
    retVal.textColor = uiConfig.textSecondaryColor
    retVal.accessibilityLabel = accessibilityLabel
    retVal.tintColor = uiConfig.uiPrimaryColor
    return retVal
  }

  static func formPhoneTextFieldWith(placeholder: String,
                                     value: String?,
                                     accessibilityLabel: String? = nil,
                                     uiConfig: ShiftUIConfig) -> PhoneNumberTextField {
    let retVal = PhoneNumberTextField()
    retVal.placeholder = placeholder
    retVal.text = value
    retVal.keyboardType = .phonePad
    retVal.autocapitalizationType = .none
    retVal.spellCheckingType = .no
    retVal.autocorrectionType = .no
    retVal.clearsOnInsertion = false
    retVal.clearsOnBeginEditing = false
    retVal.returnKeyType = .next
    retVal.enablesReturnKeyAutomatically = true
    retVal.backgroundColor = .clear
    retVal.font = uiConfig.fontProvider.formFieldFont
    retVal.textColor = uiConfig.textSecondaryColor
    retVal.accessibilityLabel = accessibilityLabel
    retVal.tintColor = uiConfig.uiPrimaryColor
    return retVal
  }

  static func formFormattedFieldWith(placeholder: String,
                                     value: String?,
                                     format: String,
                                     accessibilityLabel: String? = nil,
                                     uiConfig: ShiftUIConfig) -> UIFormattedTextField {
    let retVal = UIFormattedTextField()
    retVal.placeholder = placeholder
    retVal.formattingPattern = format
    retVal.text = value
    retVal.keyboardType = .alphabet
    retVal.autocapitalizationType = .none
    retVal.spellCheckingType = .no
    retVal.autocorrectionType = .no
    retVal.clearsOnInsertion = false
    retVal.clearsOnBeginEditing = false
    retVal.returnKeyType = .next
    retVal.enablesReturnKeyAutomatically = true
    retVal.backgroundColor = .clear
    retVal.font = uiConfig.fontProvider.formFieldFont
    retVal.textColor = uiConfig.textSecondaryColor
    retVal.accessibilityLabel = accessibilityLabel
    retVal.tintColor = uiConfig.uiPrimaryColor
    return retVal
  }

  static func formPhoneFieldWith(placeholder: String,
                                 value: InternationalPhoneNumber?,
                                 allowedCountries: [Country],
                                 accessibilityLabel: String? = nil,
                                 uiConfig: ShiftUIConfig) -> PhoneTextFieldView {
    switch uiConfig.uiTheme {
    case .theme1:
      return PhoneTextField(allowedCountries: allowedCountries,
                            placeholder: placeholder,
                            value: value,
                            accessibilityLabel: accessibilityLabel,
                            uiConfig: uiConfig)
    case .theme2:
      return PhoneTextFieldTheme2(allowedCountries: allowedCountries,
                                  placeholder: placeholder,
                                  value: value,
                                  accessibilityLabel: accessibilityLabel,
                                  uiConfig: uiConfig)
    }
  }

  static func formTextLinkButtonWith(title: String,
                                     accessibilityLabel: String? = nil,
                                     uiConfig: ShiftUIConfig,
                                     tapHandler: @escaping() -> Void) -> UIButton {
    let button = UIButton()
    button.backgroundColor = .clear
    button.accessibilityLabel = accessibilityLabel
    let attributes: [NSAttributedStringKey: Any] = [
      NSAttributedStringKey.font: uiConfig.fontProvider.formTextLink,
      NSAttributedStringKey.foregroundColor: uiConfig.textSecondaryColor,
      NSAttributedStringKey.underlineStyle: NSUnderlineStyle.styleSingle.rawValue,
      NSAttributedStringKey.underlineColor: uiConfig.textSecondaryColor
    ]
    let attributedTitle = NSAttributedString(string: title,
                                             attributes: attributes)
    button.setAttributedTitle(attributedTitle, for: UIControlState())
    button.snp.makeConstraints { make in
      make.height.equalTo(50)
    }
    _ = button.reactive.tap.observeNext(with: tapHandler)
    return button
  }

  static func instructionsLabelWith(text: String,
                                    textAlignment: NSTextAlignment = .center,
                                    accessibilityLabel: String? = nil,
                                    uiConfig: ShiftUIConfig) -> UILabel {
    let retVal = UILabel()
    retVal.text = text
    retVal.font = uiConfig.fontProvider.instructionsFont
    switch uiConfig.uiTheme {
    case .theme1:
      retVal.textColor = uiConfig.textTertiaryColor
    case .theme2:
      retVal.textColor = uiConfig.textSecondaryColor
    }
    retVal.textAlignment = textAlignment
    retVal.accessibilityLabel = accessibilityLabel
    retVal.numberOfLines = 0
    return retVal
  }

  static func emptyCaseLabelWith(text: String,
                                 textAlignment: NSTextAlignment = .center,
                                 accessibilityLabel: String? = nil,
                                 uiConfig: ShiftUIConfig) -> UILabel {
    let retVal = UILabel()
    retVal.text = text
    retVal.font = uiConfig.fontProvider.textLinkFont
    retVal.textColor = uiConfig.textTertiaryColor
    retVal.textAlignment = textAlignment
    retVal.accessibilityLabel = accessibilityLabel
    retVal.numberOfLines = 0
    return retVal
  }

  static func itemDescriptionLabelWith(text: String,
                                       textAlignment: NSTextAlignment = .left,
                                       accessibilityLabel: String? = nil,
                                       uiConfig: ShiftUIConfig) -> UILabel {
    let retVal = UILabel()
    retVal.text = text
    retVal.font = uiConfig.fontProvider.itemDescriptionFont
    retVal.textColor = uiConfig.textTertiaryColor
    retVal.textAlignment = textAlignment
    retVal.accessibilityLabel = accessibilityLabel
    return retVal
  }

  static func mainItemLightLabelWith(text: String,
                                     textAlignment: NSTextAlignment = .left,
                                     accessibilityLabel: String? = nil,
                                     uiConfig: ShiftUIConfig) -> UILabel {
    let retVal = UILabel()
    retVal.text = text
    retVal.font = uiConfig.fontProvider.mainItemLightFont
    retVal.textColor = uiConfig.textPrimaryColor
    retVal.textAlignment = textAlignment
    retVal.accessibilityLabel = accessibilityLabel
    return retVal
  }

  static func mainItemRegularLabelWith(text: String,
                                       textAlignment: NSTextAlignment = .left,
                                       multiline: Bool = false,
                                       accessibilityLabel: String? = nil,
                                       uiConfig: ShiftUIConfig) -> UILabel {
    let retVal = UILabel()
    retVal.text = text
    retVal.font = uiConfig.fontProvider.mainItemRegularFont
    retVal.textColor = uiConfig.textPrimaryColor
    retVal.textAlignment = textAlignment
    retVal.accessibilityLabel = accessibilityLabel
    if multiline {
      retVal.numberOfLines = 0
    }
    return retVal
  }

  static func buttonWith(title: String,
                         showShadow: Bool = true,
                         accessibilityLabel: String? = nil,
                         uiConfig: ShiftUIConfig,
                         tapHandler: @escaping() -> Void) -> UIButton {
    let button = UIButton()
    button.layer.cornerRadius = uiConfig.buttonCornerRadius
    button.backgroundColor = uiConfig.uiPrimaryColor
    button.accessibilityLabel = accessibilityLabel
    button.titleLabel?.font = uiConfig.fontProvider.primaryCallToActionFont
    button.setTitle(title, for: UIControlState())
    if showShadow {
      button.layer.shadowOffset = CGSize(width: 0, height: 16)
      button.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.16).cgColor
      button.layer.shadowOpacity = 1
      button.layer.shadowRadius = 16
    }
    button.snp.makeConstraints { make in
      make.height.equalTo(uiConfig.buttonHeight)
    }
    _ = button.reactive.tap.observeNext(with: tapHandler)
    return button
  }

  static func smallButtonWith(title: String,
                              accessibilityLabel: String? = nil,
                              showShadow: Bool = true,
                              uiConfig: ShiftUIConfig,
                              tapHandler: @escaping() -> Void) -> UIButton {
    let button = UIButton()
    button.layer.cornerRadius = uiConfig.smallButtonCornerRadius
    button.backgroundColor = uiConfig.uiPrimaryColor
    button.accessibilityLabel = accessibilityLabel
    button.titleLabel?.font = uiConfig.fontProvider.primaryCallToActionFontSmall
    button.setTitle(title, for: UIControlState())
    if showShadow {
      button.layer.shadowOffset = CGSize(width: 0, height: 16)
      button.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.16).cgColor
      button.layer.shadowOpacity = 1
      button.layer.shadowRadius = 16
    }
    button.snp.makeConstraints { make in
      make.height.equalTo(uiConfig.smallButtonHeight)
    }
    _ = button.reactive.tap.observeNext(with: tapHandler)
    return button
  }

  static func sectionTitleLabelWith(text: String,
                                    textAlignment: NSTextAlignment = .left,
                                    accessibilityLabel: String? = nil,
                                    uiConfig: ShiftUIConfig) -> UILabel {
    let retVal = UILabel()
    retVal.text = text
    retVal.font = uiConfig.fontProvider.sectionTitleFont
    retVal.textColor = uiConfig.textSecondaryColor
    retVal.textAlignment = textAlignment
    retVal.accessibilityLabel = accessibilityLabel
    return retVal
  }

  static func starredSectionTitleLabelWith(text: String,
                                           textAlignment: NSTextAlignment = .left,
                                           accessibilityLabel: String? = nil,
                                           uiConfig: ShiftUIConfig) -> UILabel {
    let retVal = UILabel()
    let textColor = uiConfig.textTopBarColor.withAlphaComponent(0.7)
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = textAlignment
    paragraphStyle.lineSpacing = 1.17
    let textAttributes: [NSAttributedStringKey: Any] = [
      .foregroundColor: textColor,
      .font: uiConfig.fontProvider.starredSectionTitleFont,
      .paragraphStyle: paragraphStyle,
      .kern: 2
    ]
    retVal.attributedText = NSAttributedString(string: text.uppercased(), attributes: textAttributes)
    retVal.accessibilityLabel = accessibilityLabel
    return retVal
  }

  static func boldMessageLabelWith(text: String,
                                   textAlignment: NSTextAlignment = .left,
                                   accessibilityLabel: String? = nil,
                                   multiline: Bool = true,
                                   uiConfig: ShiftUIConfig) -> UILabel {
    let retVal = UILabel()
    retVal.text = text
    retVal.font = uiConfig.fontProvider.boldMessageFont
    retVal.textColor = uiConfig.textPrimaryColor
    retVal.textAlignment = textAlignment
    retVal.accessibilityLabel = accessibilityLabel
    if multiline {
      retVal.numberOfLines = 0
    }
    return retVal
  }

  static func subcurrencyLabelWith(text: String,
                                   textAlignment: NSTextAlignment = .left,
                                   accessibilityLabel: String? = nil,
                                   uiConfig: ShiftUIConfig) -> UILabel {
    let retVal = UILabel()
    retVal.text = text
    retVal.font = uiConfig.fontProvider.subCurrencyFont
    retVal.textColor = uiConfig.textPrimaryColor
    retVal.textAlignment = textAlignment
    retVal.accessibilityLabel = accessibilityLabel
    return retVal
  }

  static func timestampLabelWith(text: String,
                                 textAlignment: NSTextAlignment = .left,
                                 accessibilityLabel: String? = nil,
                                 uiConfig: ShiftUIConfig) -> UILabel {
    let retVal = UILabel()
    retVal.text = text
    retVal.font = uiConfig.fontProvider.timestampFont
    retVal.textColor = uiConfig.textTertiaryColor
    retVal.textAlignment = textAlignment
    retVal.accessibilityLabel = accessibilityLabel
    return retVal
  }

  static func textLinkLabelWith(text: String,
                                textAlignment: NSTextAlignment = .left,
                                accessibilityLabel: String? = nil,
                                uiConfig: ShiftUIConfig) -> UILabel {
    let retVal = UILabel()
    retVal.text = text
    retVal.font = uiConfig.fontProvider.textLinkFont
    retVal.textColor = uiConfig.textLinkColor
    retVal.textAlignment = textAlignment
    retVal.accessibilityLabel = accessibilityLabel
    return retVal
  }

  static func topBarAmountLabelWith(text: String,
                                    textAlignment: NSTextAlignment = .center,
                                    accessibilityLabel: String? = nil,
                                    uiConfig: ShiftUIConfig) -> UILabel {
    let retVal = UILabel()
    retVal.text = text
    retVal.font = uiConfig.fontProvider.topBarAmountFont
    retVal.textColor = uiConfig.textTopBarColor
    retVal.textAlignment = textAlignment
    retVal.accessibilityLabel = accessibilityLabel
    return retVal
  }

  static func topBarTitleLabelWith(text: String,
                                   textAlignment: NSTextAlignment = .center,
                                   accessibilityLabel: String? = nil,
                                   uiConfig: ShiftUIConfig) -> UILabel {
    let retVal = UILabel()
    retVal.text = text
    retVal.font = uiConfig.fontProvider.topBarTitleFont
    retVal.textColor = uiConfig.textTopBarColor
    retVal.textAlignment = textAlignment
    retVal.accessibilityLabel = accessibilityLabel
    return retVal
  }

  static func topBarTitleBigLabelWith(text: String,
                                      textAlignment: NSTextAlignment = .center,
                                      accessibilityLabel: String? = nil,
                                      uiConfig: ShiftUIConfig) -> UILabel {
    let retVal = UILabel()
    retVal.text = text
    retVal.font = uiConfig.fontProvider.topBarTitleBigFont
    retVal.textColor = uiConfig.textTopBarColor
    retVal.textAlignment = textAlignment
    retVal.accessibilityLabel = accessibilityLabel
    return retVal
  }

  static func largeTitleLabelWith(text: String,
                                  textAlignment: NSTextAlignment = .left,
                                  multiline: Bool = true,
                                  accessibilityLabel: String? = nil,
                                  uiConfig: ShiftUIConfig) -> UILabel {
    let retVal = UILabel()
    retVal.text = text
    retVal.font = uiConfig.fontProvider.largeTitleFont
    retVal.textColor = uiConfig.textPrimaryColor
    retVal.textAlignment = textAlignment
    retVal.accessibilityLabel = accessibilityLabel
    if multiline {
      retVal.numberOfLines = 0
    }
    return retVal
  }

  static func errorTitleLabel(text: String,
                              textAlignment: NSTextAlignment = .center,
                              multiline: Bool = false,
                              accessibilityLabel: String? = nil,
                              uiConfig: ShiftUIConfig) -> UILabel {
    let retVal = UILabel()
    retVal.text = text
    retVal.font = uiConfig.fontProvider.errorTitleFont
    retVal.textColor = uiConfig.textPrimaryColor
    retVal.textAlignment = textAlignment
    retVal.accessibilityLabel = accessibilityLabel
    if multiline {
      retVal.numberOfLines = 0
    }
    return retVal
  }

  static func errorMessageLabel(text: String,
                                textAlignment: NSTextAlignment = .center,
                                multiline: Bool = true,
                                accessibilityLabel: String? = nil,
                                uiConfig: ShiftUIConfig) -> UILabel {
    let retVal = UILabel()
    retVal.text = text
    retVal.font = uiConfig.fontProvider.errorMessageFont
    retVal.textColor = uiConfig.textPrimaryColor
    retVal.textAlignment = textAlignment
    retVal.accessibilityLabel = accessibilityLabel
    if multiline {
      retVal.numberOfLines = 0
    }
    return retVal
  }
}
