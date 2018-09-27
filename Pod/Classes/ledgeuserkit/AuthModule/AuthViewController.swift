//
//  AuthViewController.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 13/12/2017.
//

import Foundation

typealias AuthViewControllerProtocol = ShiftViewController & AuthViewProtocol

class AuthViewController: AuthViewControllerProtocol {
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

  func show(fields: [FormRowView]) {
    formView.show(rows: fields)
    _ = formView.becomeFirstResponder()
  }

  func update(progress: Float) {
    progressView.currentValue = progress
  }

  // MARK: - Private methods

  override func nextTapped() {
    eventHandler.nextTapped()
  }

  override func closeTapped() {
    eventHandler.closeTapped()
  }

  // MARK: - Setup UI

  private func setUpUI() {
    view.backgroundColor = uiConfiguration.backgroundColor
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
