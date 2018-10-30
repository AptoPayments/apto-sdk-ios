//
//  FormBuilder.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 22/08/16.
//

import Foundation
import TTTAttributedLabel
import Bond
import ReactiveKit

class FormBuilder {

  static func sectionTitleRowWith(text: String,
                                  textAlignment: NSTextAlignment = .left,
                                  position: PositionInRow = .bottom,
                                  height: CGFloat = 60,
                                  uiConfig: ShiftUIConfig) -> FormRowLabelView {
    let defaultLabel = ComponentCatalog.sectionTitleLabelWith(text: text,
                                                              textAlignment: textAlignment,
                                                              uiConfig: uiConfig)
    defaultLabel.snp.makeConstraints { make in
      make.height.equalTo(26)
    }
    return FormRowLabelView(label: defaultLabel,
                            showSplitter: false,
                            height: height,
                            position: position)
  }

  static func mainItemRegularRowWith(text: String,
                                     textAlignment: NSTextAlignment = .center,
                                     position: PositionInRow = .center,
                                     multiLine: Bool = false,
                                     uiConfig: ShiftUIConfig) -> FormRowLabelView {
    let label = ComponentCatalog.mainItemRegularLabelWith(text: text,
                                                          textAlignment: textAlignment,
                                                          accessibilityLabel: nil,
                                                          uiConfig: uiConfig)
    if multiLine {
      label.numberOfLines = 0
    }
    return FormRowLabelView(label: label, showSplitter: false, position: position)
  }

  static func itemDescriptionRowWith(text: String,
                                     textAlignment: NSTextAlignment = .center,
                                     position: PositionInRow = .center,
                                     uiConfig: ShiftUIConfig) -> FormRowLabelView {
    let noteLabel = ComponentCatalog.itemDescriptionLabelWith(text: text,
                                                              textAlignment: textAlignment,
                                                              accessibilityLabel: nil,
                                                              uiConfig: uiConfig)
    return FormRowLabelView(label: noteLabel, showSplitter: false, position: position)
  }

  static func richTextNoteRowWith(text: NSAttributedString,
                                  textAlignment: NSTextAlignment = .center,
                                  position: PositionInRow = .center,
                                  multiline: Bool = false,
                                  uiConfig: ShiftUIConfig,
                                  linkHandler: LinkHandler?) -> FormRowRichTextLabelView {
    let attributedLabel = TTTAttributedLabel.init(frame: CGRect.zero)
    attributedLabel.linkAttributes = [
      NSAttributedStringKey.foregroundColor: uiConfig.tintColor,
      kCTUnderlineStyleAttributeName as AnyHashable: false
    ]
    let label = FormRowRichTextLabelView(label: attributedLabel,
                                         showSplitter: false,
                                         position: position,
                                         linkHandler: linkHandler)
    if multiline {
      attributedLabel.numberOfLines = 0
    }
    attributedLabel.enabledTextCheckingTypes = NSTextCheckingAllTypes
    attributedLabel.setText(text)
    attributedLabel.delegate = linkHandler
    label.backgroundColor = uiConfig.noteBackgroundColor
    label.label.backgroundColor = uiConfig.noteBackgroundColor
    return label
  }

  static func instructionsRowWith(text: String,
                                  textAlignment: NSTextAlignment = .center,
                                  position: PositionInRow = .center,
                                  uiConfig: ShiftUIConfig) -> FormRowLabelView {
    let multilineLabel = ComponentCatalog.instructionsLabelWith(text: text,
                                                                textAlignment: textAlignment,
                                                                accessibilityLabel: nil,
                                                                uiConfig: uiConfig)
    return FormRowLabelView(label: multilineLabel, showSplitter: false, position: position)
  }

  static func standardTextInputRowWith(label: String,
                                       placeholder: String,
                                       value: String?,
                                       accessibilityLabel: String? = nil,
                                       validator: DataValidator<String>? = nil,
                                       initiallyReadonly: Bool = false,
                                       firstFormField: Bool = false,
                                       lastFormField: Bool = false,
                                       uiConfig: ShiftUIConfig) -> FormRowTextInputView {
    let uiLabel = ComponentCatalog.formLabelWith(text: label, uiConfig: uiConfig)
    let textField = ComponentCatalog.formFieldWith(placeholder: placeholder,
                                                   value: value,
                                                   accessibilityLabel: accessibilityLabel,
                                                   uiConfig: uiConfig)
    let retVal = FormRowTextInputView(label: uiLabel,
                                      labelWidth: nil,
                                      textField: textField,
                                      initiallyReadOnly: initiallyReadonly,
                                      firstFormField: firstFormField,
                                      lastFormField: lastFormField,
                                      validator: validator,
                                      uiConfig: uiConfig)
    retVal.unfocusedColor = uiConfig.textPrimaryColor
    retVal.focusedColor = uiConfig.textPrimaryColor
    retVal.backgroundColor = uiConfig.backgroundColor
    retVal.showSplitter = false
    return retVal
  }

  static func addressInputRowWith(label: String,
                                  placeholder: String,
                                  value: String?,
                                  accessibilityLabel: String? = nil,
                                  addressManager: AddressManager,
                                  allowedCountries: [Country],
                                  uiConfig: ShiftUIConfig) -> FormRowAddressView {
    let uiLabel = ComponentCatalog.formLabelWith(text: label, uiConfig: uiConfig)
    let textField = ComponentCatalog.formFieldWith(placeholder: placeholder,
                                                   value: value,
                                                   accessibilityLabel: accessibilityLabel,
                                                   uiConfig: uiConfig)
    let retVal = FormRowAddressView(label: uiLabel,
                                    textField: textField,
                                    addressManager: addressManager,
                                    allowedCountries: allowedCountries,
                                    uiConfig: uiConfig)
    retVal.unfocusedColor = uiConfig.textPrimaryColor
    retVal.focusedColor = uiConfig.textPrimaryColor
    retVal.backgroundColor = uiConfig.backgroundColor
    retVal.showSplitter = false
    return retVal
  }

  static func formattedTextInputRowWith(label: String,
                                        placeholder: String,
                                        format: String,
                                        keyboardType: UIKeyboardType,
                                        value: String?,
                                        accessibilityLabel: String? = nil,
                                        validator: DataValidator<String>? = nil,
                                        hiddenText: Bool = false,
                                        initiallyReadOnly: Bool = false,
                                        firstFormField: Bool = false,
                                        lastFormField: Bool = false,
                                        uiConfig: ShiftUIConfig) -> FormRowTextInputView {
    let uiLabel = ComponentCatalog.formLabelWith(text: label, uiConfig: uiConfig)
    let textField = ComponentCatalog.formFormattedFieldWith(placeholder: placeholder,
                                                            value: value,
                                                            format: format,
                                                            accessibilityLabel: accessibilityLabel,
                                                            uiConfig: uiConfig)
    textField.isSecureTextEntry = hiddenText
    let retVal = FormRowTextInputView(label: uiLabel,
                                      labelWidth: nil,
                                      textField: textField,
                                      toggleSecureEntryState: hiddenText,
                                      initiallyReadOnly: initiallyReadOnly,
                                      firstFormField: firstFormField,
                                      lastFormField: lastFormField,
                                      validator: validator,
                                      uiConfig: uiConfig)
    retVal.unfocusedColor = uiConfig.defaultTextColor
    retVal.focusedColor = uiConfig.defaultTextColor
    retVal.showSplitter = false
    return retVal
  }

  static func datePickerRowWith(label: String,
                                placeholder: String,
                                format: FormDateFormat,
                                value: Date?,
                                accessibilityLabel: String? = nil,
                                validator: DataValidator<Date>? = nil,
                                firstFormField: Bool = false,
                                lastFormField: Bool = false,
                                uiConfig: ShiftUIConfig) -> FormRowDatePickerView {
    let uiLabel = ComponentCatalog.formLabelWith(text: label, uiConfig: uiConfig)
    let textField = ComponentCatalog.formFieldWith(placeholder: placeholder,
                                                   value: nil,
                                                   accessibilityLabel: accessibilityLabel,
                                                   uiConfig: uiConfig)
    let retVal = FormRowDatePickerView(label: uiLabel,
                                       labelWidth: nil,
                                       textField: textField,
                                       date: value,
                                       format: format,
                                       firstFormField: firstFormField,
                                       lastFormField: lastFormField,
                                       validator: validator,
                                       uiConfig: uiConfig)
    retVal.unfocusedColor = uiConfig.textPrimaryColor
    retVal.focusedColor = uiConfig.textPrimaryColor
    retVal.backgroundColor = uiConfig.backgroundColor
    return retVal
  }

  static func valuePickerRowWith(label: String,
                                 placeholder: String,
                                 labelWidth: CGFloat? = nil,
                                 value: String?,
                                 values: [FormValuePickerValue],
                                 accessibilityLabel: String? = nil,
                                 validator: DataValidator<String>? = nil,
                                 uiConfig: ShiftUIConfig) -> FormRowValuePickerView {
    let uiLabel = ComponentCatalog.formLabelWith(text: label, uiConfig: uiConfig)
    let textField = ComponentCatalog.formFieldWith(placeholder: placeholder,
                                                   value: value,
                                                   accessibilityLabel: accessibilityLabel,
                                                   uiConfig: uiConfig)
    let retVal = FormRowValuePickerView(label: uiLabel,
                                        labelWidth: labelWidth,
                                        textField: textField,
                                        value: value,
                                        values: values,
                                        validator: validator,
                                        uiConfig: uiConfig)
    retVal.unfocusedColor = uiConfig.defaultTextColor
    retVal.focusedColor = uiConfig.defaultTextColor
    retVal.backgroundColor = uiConfig.backgroundColor
    return retVal
  }

  static func emailRowWith(label: String,
                           placeholder: String,
                           value: String?,
                           accessibilityLabel: String? = nil,
                           failReasonMessage: String,
                           uiConfig: ShiftUIConfig) -> FormRowEmailView {
    let uiLabel = ComponentCatalog.formLabelWith(text: label, uiConfig: uiConfig)
    let textField = ComponentCatalog.formFieldWith(placeholder: placeholder,
                                                   value: value,
                                                   accessibilityLabel: accessibilityLabel,
                                                   uiConfig: uiConfig)
    let retVal = FormRowEmailView(label: uiLabel,
                                  labelWidth: nil,
                                  textField: textField,
                                  failReasonMessage: failReasonMessage,
                                  uiConfig: uiConfig)
    retVal.unfocusedColor = uiConfig.textPrimaryColor
    retVal.focusedColor = uiConfig.textPrimaryColor
    retVal.backgroundColor = uiConfig.backgroundColor
    return retVal
  }

  static func phoneTextFieldRow(label: String,
                                allowedCountries: [Country],
                                placeholder: String,
                                value: InternationalPhoneNumber?,
                                accessibilityLabel: String? = nil,
                                uiConfig: ShiftUIConfig) -> FormRowPhoneFieldView {
    let uiLabel = ComponentCatalog.formLabelWith(text: label, uiConfig: uiConfig)
    let phoneField = ComponentCatalog.formPhoneFieldWith(placeholder: placeholder,
                                                         value: value,
                                                         allowedCountries: allowedCountries,
                                                         accessibilityLabel: accessibilityLabel,
                                                         uiConfig: uiConfig)
    return FormRowPhoneFieldView(label: uiLabel, phoneTextField: phoneField)
  }

  static func countryPickerRow(label: String,
                               allowedCountries: [Country],
                               value: Country? = nil,
                               accessibilityLabel: String? = nil,
                               uiConfig: ShiftUIConfig) -> FormRowCountryPickerView {
    let uiLabel = ComponentCatalog.formLabelWith(text: label, uiConfig: uiConfig)
    let textField = ComponentCatalog.formFieldWith(placeholder: "",
                                                   value: nil,
                                                   accessibilityLabel: accessibilityLabel,
                                                   uiConfig: uiConfig)
    return FormRowCountryPickerView(label: uiLabel,
                                    textField: textField,
                                    allowedCountries: allowedCountries,
                                    value: value,
                                    uiConfig: uiConfig)
  }

  static func idDocumentTypePickerRow(label: String,
                                      allowedDocumentTypes: [IdDocumentType],
                                      value: IdDocumentType? = nil,
                                      accessibilityLabel: String? = nil,
                                      uiConfig: ShiftUIConfig) -> FormRowIdDocumentTypePickerView {
    let uiLabel = ComponentCatalog.formLabelWith(text: label, uiConfig: uiConfig)
    let textField = ComponentCatalog.formFieldWith(placeholder: "",
                                                   value: nil,
                                                   accessibilityLabel: accessibilityLabel,
                                                   uiConfig: uiConfig)
    return FormRowIdDocumentTypePickerView(label: uiLabel,
                                           textField: textField,
                                           allowedDocumentTypes: allowedDocumentTypes,
                                           value: value,
                                           uiConfig: uiConfig)
  }

  static func buttonRowWith(title: String,
                            accessibilityLabel: String? = nil,
                            tapHandler: @escaping() -> Void,
                            uiConfig: ShiftUIConfig) -> FormRowButtonView {
    let button = ComponentCatalog.buttonWith(title: title,
                                             accessibilityLabel: accessibilityLabel,
                                             uiConfig: uiConfig,
                                             tapHandler: tapHandler)
    let retVal = FormRowButtonView(button: button)
    return retVal
  }

  static func textButtonRowWith(title: String,
                                accessibilityLabel: String? = nil,
                                tapHandler: @escaping() -> Void,
                                uiConfig: ShiftUIConfig) -> FormRowButtonView {
    let button = ComponentCatalog.formTextLinkButtonWith(title: title,
                                                         accessibilityLabel: accessibilityLabel,
                                                         uiConfig: uiConfig,
                                                         tapHandler: tapHandler)
    let retVal = FormRowButtonView(button: button)
    return retVal
  }

  static func linkRowWith(title: String,
                          leftIcon: UIImage?,
                          leftIconMargin: CGFloat = 36,
                          showRightIcon: Bool = false,
                          showSplitter: Bool = false,
                          height: CGFloat = 44,
                          uiConfig: ShiftUIConfig,
                          clickHandler: @escaping (() -> Void)) -> FormRowLinkView {
    let label = ComponentCatalog.textLinkLabelWith(text: title, uiConfig: uiConfig)
    var uiImageView: UIImageView? = nil
    if let leftIcon = leftIcon {
      uiImageView = UIImageView(image: leftIcon)
      uiImageView?.tintColor = uiConfig.uiPrimaryColor
    }
    let retVal = FormRowLinkView(label: label,
                                 leftIcon: uiImageView,
                                 leftIconMargin: leftIconMargin,
                                 shadowedLabel: nil,
                                 showSplitter: false,
                                 showRightIcon: false,
                                 height: height,
                                 clickHandler: clickHandler)
    return retVal
  }

  static func secondaryLinkRowWith(title: String,
                                   leftIcon: UIImage?,
                                   leftIconMargin: CGFloat = 0,
                                   showRightIcon: Bool = false,
                                   showSplitter: Bool = false,
                                   height: CGFloat = 44,
                                   uiConfig: ShiftUIConfig,
                                   clickHandler: @escaping (() -> Void)) -> FormRowLinkView {
    let label = ComponentCatalog.mainItemLightLabelWith(text: title, uiConfig: uiConfig)
    label.textColor = uiConfig.textPrimaryColorDisabled
    var uiImageView: UIImageView? = nil
    if let leftIcon = leftIcon {
      uiImageView = UIImageView(image: leftIcon)
      uiImageView?.tintColor = uiConfig.uiPrimaryColorDisabled
    }
    let retVal = FormRowLinkView(label: label,
                                 leftIcon: uiImageView,
                                 leftIconMargin: leftIconMargin,
                                 shadowedLabel: nil,
                                 showSplitter: false,
                                 showRightIcon: false,
                                 height: height,
                                 clickHandler: clickHandler)
    return retVal
  }

  static func linkRowWith(title: String,
                          subtitle: String,
                          leftIcon: UIImage?,
                          height: CGFloat = 66,
                          uiConfig: ShiftUIConfig,
                          clickHandler: @escaping (() -> Void)) -> FormRowTopBottomLabelView {
    let titleLabel = ComponentCatalog.mainItemLightLabelWith(text: title, uiConfig: uiConfig)
    let subtitleLabel = ComponentCatalog.itemDescriptionLabelWith(text: subtitle, uiConfig: uiConfig)
    let imageView: UIImageView?
    if let leftIcon = leftIcon {
      imageView = UIImageView(image: leftIcon)
      imageView?.tintColor = uiConfig.uiPrimaryColor
    }
    else {
      imageView = nil
    }
    return FormRowTopBottomLabelView(titleLabel: titleLabel,
                                     subtitleLabel: subtitleLabel,
                                     leftImageView: imageView,
                                     height: height,
                                     clickHandler: clickHandler)
  }

  static func checkboxRowWith(text: String,
                              uiConfig: ShiftUIConfig) -> FormRowCheckView {
    let checkboxLabel = ComponentCatalog.formLabelWith(text: text, uiConfig: uiConfig)
    return FormRowCheckView(label: checkboxLabel, height: 20)
  }

  static func radioRowWith(labels: [String],
                           values: [Int],
                           leftIcons: [UIImage?]? = [],
                           uiConfig: ShiftUIConfig) -> FormRowRadioView {
    let creditLabels: [UILabel] = labels.map { label -> UILabel in
      let uiLabel = ComponentCatalog.formLabelWith(text: label, uiConfig: uiConfig)
      uiLabel.font = uiConfig.fontProvider.formFieldFont
      uiLabel.textColor = uiConfig.textSecondaryColor
      return uiLabel
    }
    let retVal = FormRowRadioView(labels: creditLabels,
                                  values: values,
                                  leftIcons: leftIcons,
                                  onImage: nil,
                                  flashColor: uiConfig.iconPrimaryColor)
    retVal.tickImageView?.tintColor = uiConfig.iconPrimaryColor
    retVal.backgroundColor = uiConfig.backgroundColor
    return retVal
  }

  static func balanceRadioRowWith(balances: [FormRowBalanceRadioViewValue],
                                  values: [Int],
                                  uiConfig: ShiftUIConfig) -> FormRowBalanceRadioView {
    let retVal = FormRowBalanceRadioView(items: balances,
                                         values: values,
                                         flashColor: uiConfig.uiPrimaryColor,
                                         uiConfig: uiConfig)
    retVal.tickImageView.tintColor = uiConfig.iconPrimaryColor
    retVal.backgroundColor = uiConfig.backgroundColor
    return retVal
  }

  static func valuePickerRow(title: String,
                             selectedValue: String? = nil,
                             values: [FormValuePickerValue],
                             placeholder: String,
                             accessibilityLabel: String? = nil,
                             validator: DataValidator<String>? = nil,
                             uiConfig: ShiftUIConfig) -> FormRowValuePickerView {
    let uiLabel = ComponentCatalog.formLabelWith(text: title, uiConfig: uiConfig)
    let textField = ComponentCatalog.formFieldWith(placeholder: "",
                                                   value: selectedValue,
                                                   accessibilityLabel: accessibilityLabel,
                                                   uiConfig: uiConfig)
    let retVal = FormRowValuePickerView(label: uiLabel,
                                        labelWidth: nil,
                                        textField: textField,
                                        value: selectedValue,
                                        values: values,
                                        validator: validator,
                                        uiConfig: uiConfig)
    retVal.unfocusedColor = uiConfig.textPrimaryColor
    retVal.focusedColor = uiConfig.textPrimaryColor
    retVal.backgroundColor = uiConfig.backgroundColor
    retVal.showSplitter = false
    return retVal
  }

  static func sliderRowWith(text: String,
                            minimumValue: Int,
                            maximumValue: Int,
                            textPattern: String,
                            validator: DataValidator<Int>? = nil,
                            accessibilityLabel: String? = nil,
                            uiConfig: ShiftUIConfig) -> FormRowNumericSliderView {
    let uiLabel = ComponentCatalog.amountBigLabelWith(text: text,
                                                      uiConfig: uiConfig)
    return FormRowNumericSliderView(valueLabel: uiLabel,
                                    minimumValue: minimumValue,
                                    maximumValue: maximumValue,
                                    textPattern: textPattern,
                                    validator: validator,
                                    accessibilityLabel: accessibilityLabel,
                                    uiConfig: uiConfig)
  }

  static func radioButtonRowWith(title: String,
                                 tapHandler: @escaping() -> Void,
                                 uiConfig: ShiftUIConfig) -> FormRowButtonView {
    let button = ComponentCatalog.formTextLinkButtonWith(title: title, uiConfig: uiConfig, tapHandler: tapHandler)
    let retVal = FormRowButtonView(button: button)
    return retVal
  }

  static func labelSwitchRowWith(title: String,
                                 labelWidth: CGFloat,
                                 showSplitter: Bool = true,
                                 height: CGFloat = 44,
                                 onChange: ((UISwitch) -> Void)? = nil,
                                 uiConfig: ShiftUIConfig) -> FormRowSwitchView {
    let label = ComponentCatalog.formLabelWith(text: title, uiConfig: uiConfig)
    let switcher = UISwitch()
    if let onChange = onChange {
      switcher.setOnChnageListener(action: onChange)
    }
    switcher.onTintColor = uiConfig.uiPrimaryColor
    let retVal = FormRowSwitchView(label: label,
                                   labelWidth: labelWidth,
                                   switcher: switcher,
                                   showSplitter: showSplitter,
                                   height: height)
    return retVal
  }

  static func titleSubtitleSwitchRowWith(title: String,
                                         subtitle: String,
                                         height: CGFloat = 66,
                                         uiConfig: ShiftUIConfig,
                                         onChange: ((UISwitch) -> Void)? = nil) -> FormRowSwitchTitleSubtitleView {
    let titleLabel = ComponentCatalog.mainItemLightLabelWith(text: title, uiConfig: uiConfig)
    let subtitleLabel = ComponentCatalog.itemDescriptionLabelWith(text: subtitle, uiConfig: uiConfig)
    let switcher = UISwitch()
    if let onChange = onChange {
      switcher.setOnChnageListener(action: onChange)
    }
    switcher.onTintColor = uiConfig.uiPrimaryColor
    return FormRowSwitchTitleSubtitleView(titleLabel: titleLabel,
                                          subtitleLabel: subtitleLabel,
                                          switcher: switcher,
                                          height: height)
  }

  static func labelLabelRowWith(leftText: String,
                                rightText: String?,
                                labelWidth: CGFloat? = 120,
                                textAlignment: NSTextAlignment = .right,
                                showSplitter: Bool = true,
                                backgroundColor: UIColor? = nil,
                                uiConfig: ShiftUIConfig) -> FormRowLeftRightLabelView {
    let rightLabel = ComponentCatalog.mainItemLightLabelWith(text: rightText ?? "",
                                                             textAlignment: .right,
                                                             uiConfig: uiConfig)
    rightLabel.textColor = uiConfig.textSecondaryColor
    let retVal = FormRowLeftRightLabelView(
      label: ComponentCatalog.mainItemRegularLabelWith(text: leftText, uiConfig: uiConfig),
      rightLabel: rightLabel,
      labelWidth: labelWidth,
      showSplitter: showSplitter
    )
    guard let color = backgroundColor else {
      return retVal
    }
    retVal.backgroundColor = color
    retVal.snp.makeConstraints { make in
      make.height.equalTo(44)
    }
    return retVal
  }

  static func imageLabelRowWith(imageView: UIImageView?,
                                rightText: String?,
                                textAlignment: NSTextAlignment = .right,
                                multiLine: Bool = false,
                                uiConfig: ShiftUIConfig) -> FormRowLeftImageRightLabelView {
    let rightLabel = ComponentCatalog.mainItemLightLabelWith(text: rightText ?? "",
                                                             textAlignment: textAlignment,
                                                             uiConfig: uiConfig)
    if multiLine {
      rightLabel.numberOfLines = 0
    }
    return FormRowLeftImageRightLabelView(imageView: imageView,
                                          rightLabel: rightLabel)
  }

  static func screenSubtitleRowWith(text: String, uiConfig: ShiftUIConfig, height: CGFloat = 44) -> FormRowLabelView {
    let label = FormRowLabelView(label: UILabel(), showSplitter: false, height: height)
    label.label.text = text
    label.label.textColor = uiConfig.formSubtitleColor
    label.label.font = uiConfig.fonth4
    label.label.textAlignment = .center
    label.backgroundColor = uiConfig.formSubtitleBackgroundColor
    label.label.backgroundColor = uiConfig.formSubtitleBackgroundColor
    label.label.numberOfLines = 0
    return label
  }

  static func separatorRow(height: CGFloat) -> FormRowSeparatorView {
    return FormRowSeparatorView(backgroundColor: .clear, height: height, showTopLine: false, showBottomLine: false)
  }

  static func topSeparatorRow() -> FormRowSeparatorView {
    return FormRowSeparatorView(backgroundColor: .clear, height: 1, showTopLine: false, showBottomLine: true)
  }

  static func bottomSeparatorRow() -> FormRowSeparatorView {
    return FormRowSeparatorView(backgroundColor: .clear, height: 1, showTopLine: true, showBottomLine: false)
  }

  static func formLabelRowWith(text: String, uiConfig: ShiftUIConfig) -> FormRowLabelView {
    let label = ComponentCatalog.formLabelWith(text: text, uiConfig: uiConfig)
    return FormRowLabelView(label: label, showSplitter: false, height: 40, position: .bottom)
  }

  static func formAnswerRowWith(text: String, uiConfig: ShiftUIConfig) -> FormRowMultilineLabelView {
    let label = UILabel()
    label.text = text
    label.textColor = uiConfig.textSecondaryColor
    label.font = uiConfig.fontProvider.formFieldFont
    label.numberOfLines = 0
    label.textAlignment = .left
    return FormRowMultilineLabelView(label: label)
  }
}
