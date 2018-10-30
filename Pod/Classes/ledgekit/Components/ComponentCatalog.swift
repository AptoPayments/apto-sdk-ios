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
                            accessibilityLabel: String? = nil,
                            uiConfig: ShiftUIConfig) -> UILabel {
    let retVal = UILabel()
    retVal.text = text
    retVal.font = uiConfig.fontProvider.formLabelFont
    retVal.textColor = uiConfig.textPrimaryColor
    retVal.textAlignment = textAlignment
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
                                 uiConfig: ShiftUIConfig) -> PhoneTextField {
    return PhoneTextField(allowedCountries: allowedCountries,
                          placeholder: placeholder,
                          value: value,
                          accessibilityLabel: accessibilityLabel,
                          uiConfig: uiConfig)
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
                         accessibilityLabel: String? = nil,
                         uiConfig: ShiftUIConfig,
                         tapHandler: @escaping() -> Void) -> UIButton {
    let button = UIButton()
    button.layer.cornerRadius = uiConfig.buttonCornerRadius
    button.backgroundColor = uiConfig.uiPrimaryColor
    button.accessibilityLabel = accessibilityLabel
    button.titleLabel?.font = uiConfig.fontProvider.primaryCallToActionFont
    button.setTitle(title, for: UIControlState())
    button.layer.shadowOffset = CGSize(width: 0, height: 16)
    button.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.16).cgColor
    button.layer.shadowOpacity = 1
    button.layer.shadowRadius = 16
    button.snp.makeConstraints { make in
      make.height.equalTo(50)
    }
    _ = button.reactive.tap.observeNext(with: tapHandler)
    return button
  }

  static func smallButtonWith(title: String,
                              accessibilityLabel: String? = nil,
                              uiConfig: ShiftUIConfig,
                              tapHandler: @escaping() -> Void) -> UIButton {
    let button = UIButton()
    button.layer.cornerRadius = 18
    button.backgroundColor = uiConfig.uiPrimaryColor
    button.accessibilityLabel = accessibilityLabel
    button.titleLabel?.font = uiConfig.fontProvider.primaryCallToActionFontSmall
    button.setTitle(title, for: UIControlState())
    button.layer.shadowOffset = CGSize(width: 0, height: 16)
    button.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.16).cgColor
    button.layer.shadowOpacity = 1
    button.layer.shadowRadius = 16
    button.snp.makeConstraints { make in
      make.height.equalTo(36)
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
