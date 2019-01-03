//
//  AccountSettingsViewControllerTheme1.swift
//  ShiftSDK
//
//  Created by Takeichi Kanzaki on 17/08/2018.
//
//

import UIKit
import SnapKit

class AccountSettingsViewControllerTheme1: AccountSettingsViewProtocol {
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
    UIAlertController.confirm(title: "account_settings.logout.confirm_logout.title".podLocalized(),
                              message: "account_settings.logout.confirm_logout.message".podLocalized(),
                              okTitle: "account_settings.logout.confirm_logout.ok_button".podLocalized(),
                              cancelTitle: "account_settings.logout.confirm_logout.cancel_button".podLocalized()) { [unowned self] action in
      guard action.title != "account_settings.logout.confirm_logout.cancel_button".podLocalized() else {
        return
      }
      self.presenter.logoutTapped()
    }
  }
}

// MARK: - Set up UI
private extension AccountSettingsViewControllerTheme1 {
  func setUpUI() {
    view.backgroundColor = uiConfiguration.uiBackgroundPrimaryColor
    setUpNavigationBar()
    setUpFormView()
  }

  func setUpNavigationBar() {
    navigationController?.navigationBar.setUpWith(uiConfig: uiConfiguration)
    edgesForExtendedLayout = UIRectEdge()
    extendedLayoutIncludesOpaqueBars = true
    self.title = "account_settings.settings.title".podLocalized()
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
    return FormBuilder.sectionTitleRowWith(text: "account_settings.help.title".podLocalized(),
                                           textAlignment: .left,
                                           uiConfig: self.uiConfiguration)
  }

  func createSupportButton() -> FormRowView {
    return FormBuilder.linkRowWith(title: "account_settings.help.contact_support.title".podLocalized(),
                                   subtitle: "account_settings.help.contact_support.description".podLocalized(),
                                   leftIcon: UIImage.imageFromPodBundle("icon-help")?.asTemplate(),
                                   uiConfig: uiConfiguration) { [unowned self] in
      self.presenter.contactTapped()
    }
  }

  func createLogoutSeparator() -> FormRowSeparatorView {
    return FormRowSeparatorView(backgroundColor: uiConfiguration.uiBackgroundPrimaryColor, height: 40)
  }

  func createLogoutButton() -> FormRowLinkView {
    return FormBuilder.secondaryLinkRowWith(title: "account_settings.logout.title".podLocalized(),
                                            leftIcon: UIImage.imageFromPodBundle("icon-signout")?.asTemplate(),
                                            showSplitter: true,
                                            uiConfig: self.uiConfiguration) { [unowned self] in
      self.logoutTapped()
    }
  }
}
