//
//  SelectFinancialAccountTypeViewController.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 18/10/2016.
//
//

import Foundation

protocol SelectFinancialAccountTypeEventHandler {
  func viewLoaded()
  func bankAccountTapped()
  func cardTapped()
  func virtualCardTapped()
  func backTapped()
}

class SelectFinancialAccountTypeViewController: ShiftViewController, SelectFinancialAccountTypeViewProtocol {

  let eventHandler: SelectFinancialAccountTypeEventHandler
  fileprivate var label: UILabel?

  init(uiConfiguration: ShiftUIConfig, eventHandler:SelectFinancialAccountTypeEventHandler) {
    self.eventHandler = eventHandler
    super.init(uiConfiguration: uiConfiguration)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = self.uiConfiguration.backgroundColor
    self.navigationController?.navigationBar.backgroundColor = self.uiConfiguration.uiPrimaryColor
    self.edgesForExtendedLayout = UIRectEdge()
    self.extendedLayoutIncludesOpaqueBars = true
    self.showNavPreviousButton(uiConfiguration.iconTertiaryColor)

    let scrollView = UIScrollView()
    view.addSubview(scrollView)
    scrollView.snp.makeConstraints { make in
      make.left.top.bottom.right.equalTo(view)
    }

    let contentView = UIView()
    scrollView.addSubview(contentView)
    contentView.snp.makeConstraints { make in
      make.left.top.right.bottom.equalTo(scrollView)
      make.width.equalTo(self.view)
    }

    let subtitleLabel = ComponentCatalog.mainItemRegularLabelWith(text: "",
                                                                  textAlignment: .center,
                                                                  uiConfig: uiConfiguration)
    self.label = subtitleLabel
    contentView.addSubview(subtitleLabel)
    subtitleLabel.snp.makeConstraints { make in
      make.left.right.equalTo(contentView)
      make.top.equalTo(contentView).offset(20)
      make.height.equalTo(30)
    }

    let bankAccountTitle = "select-financial-account.bank-deposit.title".podLocalized()
    let bankAccountSubtitle = "select-financial-account.bank-deposit.subtitle".podLocalized()
    let bankAccountView = self.buildTypeViewWith(title: bankAccountTitle,
                                                 subtitle: bankAccountSubtitle,
                                                 iconName: "doc_bank_statement_disabled",
                                                 iconWidth: 67,
                                                 iconHeight: 64,
                                                 topInset: 20,
                                                 accessibilityLabel: "Select Bank Account Button")
    contentView.addSubview(bankAccountView)
    bankAccountView.snp.makeConstraints { make in
      make.top.equalTo(subtitleLabel.snp.bottom).offset(10)
      make.centerX.equalTo(contentView)
      //make.left.right.equalTo(contentView).inset(80)
    }
    bankAccountView.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                action: #selector(self.bankAccountTapped)))

    let cardView = self.buildCardView(accessibilityLabel: "Add Card Button")
    contentView.addSubview(cardView)
    cardView.snp.makeConstraints { make in
      make.top.equalTo(bankAccountView.snp.bottom).offset(10)
      make.centerX.equalTo(bankAccountView)
      make.width.equalTo(bankAccountView)
    }
    cardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.cardTapped)))

    let virtualCardTitle = "select-financial-account.virtual-card.title".podLocalized()
    let virtualCardSubtitle = "select-financial-account.virtual-card.subtitle".podLocalized()
    let virtualCardView = self.buildTypeViewWith(title: virtualCardTitle,
                                                 subtitle: virtualCardSubtitle,
                                                 iconName: "card_virtual",
                                                 topInset: 0,
                                                 subtitleTopInset: 0,
                                                 accessibilityLabel: "Issue Virtual Card Button")
    contentView.addSubview(virtualCardView)
    virtualCardView.snp.makeConstraints { make in
      make.top.equalTo(cardView.snp.bottom).offset(10)
      make.bottom.equalTo(contentView).inset(20)
      make.centerX.equalTo(bankAccountView)
      make.width.equalTo(bankAccountView)
    }
    virtualCardView.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                action: #selector(self.virtualCardTapped)))

    self.eventHandler.viewLoaded()
  }

  fileprivate func buildCardView(accessibilityLabel: String, _ iconWidth:Int? = 96, iconHeight:Int? = 96) -> UIView {
    let cardView = UIView()
    cardView.accessibilityLabel = accessibilityLabel

    cardView.backgroundColor = UIColor.white
    cardView.layer.cornerRadius = 10

    let firstRowView = UIView()
    let visaIcon = UIImageView(image: UIImage.imageFromPodBundle("card_visa"))
    let mastercardIcon = UIImageView(image: UIImage.imageFromPodBundle("card_mastercard"))
    firstRowView.addSubview(visaIcon)
    firstRowView.addSubview(mastercardIcon)
    visaIcon.snp.makeConstraints { make in
      make.top.left.bottom.equalTo(firstRowView)
      make.width.equalTo(iconWidth!)
      make.height.equalTo(iconHeight!)
    }
    mastercardIcon.snp.makeConstraints { make in
      make.top.right.bottom.equalTo(firstRowView)
      make.left.equalTo(visaIcon.snp.right).offset(10)
      make.width.equalTo(iconWidth!)
      make.height.equalTo(iconHeight!)
    }

    cardView.addSubview(firstRowView)
    firstRowView.snp.makeConstraints { make in
      make.top.equalTo(cardView)
      make.centerX.equalTo(cardView)
      make.left.right.greaterThanOrEqualTo(cardView).inset(20)
    }

    let cardSubtitleText = "select-financial-account.card-support.text".podLocalized()
    let cardSubtitle = ComponentCatalog.instructionsLabelWith(text: cardSubtitleText,
                                                              uiConfig: uiConfiguration)
    cardView.addSubview(cardSubtitle)
    cardSubtitle.snp.makeConstraints { make in
      make.top.equalTo(firstRowView.snp.bottom)
      make.centerX.equalTo(cardView)
      make.left.right.equalTo(cardView).inset(20)
      make.bottom.equalTo(cardView).offset(-20)
    }

    return cardView
  }

  fileprivate func buildTypeViewWith(title:String, subtitle:String, iconName:String, iconWidth:Int? = 96, iconHeight:Int? = 96, topInset: Int? = 10, subtitleTopInset: Int? = 20, accessibilityLabel: String) -> UIView {
    let retVal = UIView()
    retVal.accessibilityLabel = accessibilityLabel
    retVal.backgroundColor = UIColor.white
    retVal.layer.cornerRadius = 10

    let firstRowView = UIView()
    let icon = UIImageView(image: UIImage.imageFromPodBundle(iconName))
    let title = ComponentCatalog.mainItemRegularLabelWith(text: title, uiConfig: uiConfiguration)
    title.numberOfLines = 0
    firstRowView.addSubview(icon)
    firstRowView.addSubview(title)
    icon.snp.makeConstraints { make in
      make.top.left.bottom.equalTo(firstRowView)
      make.width.equalTo(iconWidth!)
      make.height.equalTo(iconHeight!)
    }
    title.snp.makeConstraints { make in
      make.left.equalTo(icon.snp.right).offset(20)
      make.right.equalTo(firstRowView)
      make.centerY.equalTo(firstRowView)
      //make.width.equalTo(100)
    }

    retVal.addSubview(firstRowView)
    firstRowView.snp.makeConstraints { make in
      make.top.equalTo(retVal).offset(topInset!)
      make.centerX.equalTo(retVal)
      make.left.right.lessThanOrEqualTo(retVal).inset(20)
    }

    let subtitle = ComponentCatalog.instructionsLabelWith(text: subtitle, uiConfig: uiConfiguration)
    retVal.addSubview(subtitle)
    subtitle.snp.makeConstraints { make in
      make.top.equalTo(firstRowView.snp.bottom).offset(subtitleTopInset!)
      make.left.right.equalTo(retVal).inset(20)
      make.bottom.equalTo(retVal).offset(-20)
    }
    return retVal
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func set(subtitle:String) {
    guard let label = label else {
      return
    }
    label.text = subtitle
  }

  @objc func bankAccountTapped() {
    eventHandler.bankAccountTapped()
  }

  @objc func cardTapped() {
    eventHandler.cardTapped()
  }

  @objc func virtualCardTapped() {
    eventHandler.virtualCardTapped()
  }

  override func previousTapped() {
    eventHandler.backTapped()
  }

  func showLoadingSpinner() {
    showLoadingSpinner(tintColor: uiConfiguration.uiPrimaryColor)
  }
}
