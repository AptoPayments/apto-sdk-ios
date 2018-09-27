//
//  AccountSettingsViewController.swift
//  ShiftSDK
//
//  Created by Takeichi Kanzaki on 17/08/2018.
//
//

import UIKit
import SnapKit

class AccountSettingsViewController: AccountSettingsViewProtocol {
  private unowned let presenter: AccountSettingsPresenterProtocol
  private let formView = MultiStepForm()

  init(uiConfiguration: ShiftUIConfig, presenter: AccountSettingsPresenterProtocol) {
    self.presenter = presenter
    super.init(uiConfiguration: uiConfiguration)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    setUpUI()
    presenter.viewLoaded()
  }

  override func previousTapped() {
    presenter.previousTapped()
  }

  override func closeTapped() {
    presenter.closeTapped()
  }

  private func logoutTapped() {
    UIAlertController.confirm(title: "card.settings.logout.dialog.title".podLocalized(),
                              message: "card.settings.logout.dialog.message".podLocalized(),
                              okTitle: "general.button.ok".podLocalized(),
                              cancelTitle: "general.button.cancel".podLocalized()) { [unowned self] action in
      guard action.title != "general.button.cancel".podLocalized() else {
        return
      }
      self.presenter.logoutTapped()
    }
  }
}

// MARK: - Set up UI
private extension AccountSettingsViewController {
  func setUpUI() {
    view.backgroundColor = uiConfiguration.backgroundColor
    setUpNavigationBar()
    setUpFormView()
  }

  func setUpNavigationBar() {
    navigationController?.navigationBar.setUpWith(uiConfig: uiConfiguration)
    edgesForExtendedLayout = UIRectEdge()
    extendedLayoutIncludesOpaqueBars = true
    self.title = "account.settings.title".podLocalized()
  }

  func setUpFormView() {
    view.addSubview(self.formView)
    formView.snp.makeConstraints { make in
      make.top.left.right.bottom.equalToSuperview()
    }
    formView.backgroundColor = view.backgroundColor
    let rows = [
      self.createSupportTitle(),
      self.createSupportButton(),
      self.createLogoutSeparator(),
      self.createLogoutButton()
    ]
    formView.show(rows: rows)
  }

  func createSupportTitle() -> FormRowLabelView {
    return FormBuilder.sectionTitleRowWith(text: "card.settings.support.title".podLocalized(),
                                           textAlignment: .left,
                                           uiConfig: self.uiConfiguration)
  }

  func createSupportButton() -> FormRowTopBottomLabelView {
    return FormBuilder.linkRowWith(title: "card.settings.contact-support.title".podLocalized(),
                                   subtitle: "card.settings.contact-support.subtitle".podLocalized(),
                                   leftIcon: UIImage.imageFromPodBundle("icon-help")?.asTemplate(),
                                   uiConfig: uiConfiguration) { [unowned self] in
      self.presenter.contactTapped()
    }
  }

  func createLogoutSeparator() -> FormRowSeparatorView {
    return FormRowSeparatorView(backgroundColor: uiConfiguration.backgroundColor, height: 40)
  }

  func createLogoutButton() -> FormRowLinkView {
    return FormBuilder.secondaryLinkRowWith(title: "card.settings.logout.button.title".podLocalized(),
                                            leftIcon: UIImage.imageFromPodBundle("icon-signout")?.asTemplate(),
                                            showSplitter: true,
                                            uiConfig: self.uiConfiguration) { [unowned self] in
      self.logoutTapped()
    }
  }
}
