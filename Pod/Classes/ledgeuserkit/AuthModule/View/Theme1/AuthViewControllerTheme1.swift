//
//  AuthViewControllerTheme1.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 13/12/2017.
//

import Foundation

class AuthViewControllerTheme1: AuthViewControllerProtocol {
  private unowned let eventHandler: AuthEventHandler
  private let formView: MultiStepForm
  private let progressView: ProgressView

  init(uiConfiguration: ShiftUIConfig, eventHandler: AuthEventHandler) {
    self.formView = MultiStepForm()
    self.progressView = ProgressView(maxValue: 100, uiConfig: uiConfiguration)
    self.eventHandler = eventHandler
    super.init(uiConfiguration: uiConfiguration)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    setUpUI()
    eventHandler.viewLoaded()
    progressView.update(progress: 25)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Public methods

  func setTitle(_ title: String) {
    set(title: title)
  }

  func show(fields: [FormRowView]) {
    formView.show(rows: fields)
    _ = formView.becomeFirstResponder()
  }

  func update(progress: Float) {
    progressView.currentValue = progress
  }

  func showCancelButton() {
    showNavCancelButton(uiConfiguration.iconTertiaryColor)
  }

  func showNextButton() {
    showNavNextButton(title: "auth.input_phone.call_to_action.title".podLocalized(),
                      tintColor: uiConfiguration.iconTertiaryColor)
  }

  func activateNextButton() {
    activateNavNextButton(uiConfiguration.iconTertiaryColor)
  }

  func deactivateNextButton() {
    deactivateNavNextButton(uiConfiguration.disabledTextTopBarColor)
  }

  func show(error: NSError) {
    super.show(error: error)
  }

  // MARK: - Private methods

  override func nextTapped() {
    view.endEditing(true)
    eventHandler.nextTapped()
  }

  override func closeTapped() {
    eventHandler.closeTapped()
  }

  // MARK: - Setup UI

  private func setUpUI() {
    view.backgroundColor = uiConfiguration.uiBackgroundPrimaryColor
    setUpNavigationBar()
    edgesForExtendedLayout = .top
    extendedLayoutIncludesOpaqueBars = true
    setUpProgressView()
    setUpFormView()
  }

  private func setUpNavigationBar() {
    navigationController?.navigationBar.setUpWith(uiConfig: uiConfiguration)
  }

  private func setUpProgressView() {
    view.addSubview(progressView)
    progressView.snp.makeConstraints { make in
      make.top.equalTo(topLayoutGuide.snp.bottom)
      make.left.right.equalTo(self.view)
      make.height.equalTo(4)
    }
  }

  private func setUpFormView() {
    view.addSubview(formView)
    formView.snp.makeConstraints { make in
      make.top.equalTo(self.progressView.snp.bottom)
      make.left.right.bottom.equalTo(self.view)
    }
    formView.backgroundColor = UIColor.clear
  }
}
