//
//  FinancialAccountListViewController.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 17/10/2016.
//
//

protocol FinancialAccountListEventHandler {
  func viewLoaded()
  func backTapped()
  func closeTapped()
  func addAccountTapped()
  func refreshListTapped()
  func doneTapped()
  func accountSelectedWith(index:Int)
}

import UIKit

class FinancialAccountListViewController: ShiftViewController, FinancialAccountListViewProtocol {

  let eventHandler: FinancialAccountListEventHandler
  fileprivate let formView: MultiStepForm
  fileprivate var label: FormRowLabelView?

  init(uiConfiguration: ShiftUIConfig, eventHandler:FinancialAccountListEventHandler) {
    self.eventHandler = eventHandler
    self.formView = MultiStepForm()
    super.init(uiConfiguration: uiConfiguration)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = self.uiConfiguration.uiBackgroundPrimaryColor
    self.navigationController?.navigationBar.backgroundColor = self.uiConfiguration.uiPrimaryColor
    self.edgesForExtendedLayout = .top
    self.extendedLayoutIncludesOpaqueBars = true
    self.view.addSubview(self.formView)
    self.formView.snp.makeConstraints { make in
      make.top.left.right.bottom.equalTo(self.view)
    }
    self.formView.backgroundColor = UIColor.clear
    self.label = FormBuilder.mainItemRegularRowWith(text: "",
                                                    textAlignment: .center,
                                                    position: .top,
                                                    multiLine: true,
                                                    uiConfig: uiConfiguration)
    self.eventHandler.viewLoaded()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func set(subtitle:String) {
    guard let label = label else {
      return
    }
    label.label.text = subtitle
  }

  func showNewContents(_ newContents:[FinancialAccount]) {
    let labels = newContents.map { financialAccount -> String in
      return financialAccount.quickDescription()
    }
    let leftIcons = newContents.map { financialAccount -> UIImage? in
      return financialAccount.icon()
    }
    DispatchQueue.main.async {
      self.formView.show(rows: self.setupRows(labels, leftIcons:leftIcons))
    }
  }

  func setupRows(_ labels:[String], leftIcons: [UIImage?]) -> [FormRowView] {
    var values: [Int] = []
    if labels.count > 0 {
      values = Array(0...labels.count - 1)
    }
    let accountSelector = FormBuilder.radioRowWith(labels: labels, values:values, leftIcons:leftIcons, uiConfig: uiConfiguration)
    accountSelector.numberValidator = NonNullIntValidator(failReasonMessage: "credit-score-collector.credit-score.warning.empty".podLocalized())
    let doneButton = FormBuilder.buttonRowWith(title: "Fund Loan", tapHandler: { [weak self] in
      self?.eventHandler.doneTapped()
      }, uiConfig: uiConfiguration)
    let _ = accountSelector.valid.observeNext { [weak self] valid in
      if valid {
        doneButton.button.backgroundColor = self?.uiConfiguration.tintColor
      }
      else {
        doneButton.button.backgroundColor = self?.uiConfiguration.disabledTintColor
      }
    }
    let _ = accountSelector.bndValue.observeNext { [weak self] selectedIdx in
      guard let accountIndex = selectedIdx else {
        return
      }
      self?.eventHandler.accountSelectedWith(index: accountIndex)
    }
    let addAccountButton = FormBuilder.textButtonRowWith(title: "Add Account", accessibilityLabel: "Add Account Button", tapHandler: { [weak self] in
      self?.eventHandler.addAccountTapped()
      }, uiConfig: uiConfiguration)
    guard let label = label else {
      return [accountSelector, doneButton, addAccountButton]
    }
    return [label, accountSelector, doneButton, addAccountButton]
  }

  override func previousTapped() {
    eventHandler.backTapped()
  }

  override func closeTapped() {
    eventHandler.closeTapped()
  }

  func refreshList() {
    eventHandler.refreshListTapped()
  }

}

extension FinancialAccount {
  @objc func icon() -> UIImage? {
    return UIImage()
  }
}

extension Card {
  override func icon() -> UIImage? {
    return cardNetwork?.icon()
  }
}

extension BankAccount {
  override func icon() -> UIImage? {
    return UIImage.imageFromPodBundle("doc_bank_statement_disabled@2x.png")
  }
}

extension CardNetwork {
  func icon() -> UIImage {
    switch self {
    case .visa:
      return UIImage.imageFromPodBundle("card_logo_visa.png")!
    case .mastercard:
      return UIImage.imageFromPodBundle("card_logo_mastercard.png")!
    case .amex:
      return UIImage.imageFromPodBundle("card_logo_amex.png")!
    case .other:
      return UIImage.imageFromPodBundle("card_logo_unknown.png")!
    }
  }
}
