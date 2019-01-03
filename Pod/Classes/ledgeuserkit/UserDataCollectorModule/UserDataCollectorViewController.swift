//
//  UserDataCollectorViewController.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 25/01/16.
//  Copyright © 2018 Shift. All rights reserved.
//

import SnapKit
import Bond

protocol UserDataCollectorEventHandler: class {
  func viewLoaded()
  func nextStepTapped()
  func previousStepTapped()
  func closeTapped()
}

class UserDataCollectorViewController: ShiftViewController, UserDataCollectorViewProtocol {
  private unowned let eventHandler: UserDataCollectorEventHandler
  fileprivate let formView: MultiStepForm
  fileprivate let progressView: ProgressView

  init(uiConfiguration: ShiftUIConfig, eventHandler: UserDataCollectorEventHandler) {
    self.formView = MultiStepForm()
    self.progressView = ProgressView(maxValue: 100, uiConfig: uiConfiguration)
    self.eventHandler = eventHandler
    super.init(uiConfiguration: uiConfiguration)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    setUpUI()
    self.eventHandler.viewLoaded()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Public methods

  func show(fields: [FormRowView]) {
    self.formView.show(rows: fields)
  }

  func push(fields: [FormRowView]) {
    self.formView.show(rows: fields, withAnimation: .push)
  }

  func pop(fields: [FormRowView]) {
    self.formView.show(rows: fields, withAnimation: .pop)
  }

  func showNavProfileButton() {
    self.installNavRightButton(UIImage.imageFromPodBundle("top_profile.png"),
                               target: self,
                               action: #selector(UserDataCollectorViewController.nextTapped))
  }

  func update(progress: Float) {
    self.progressView.update(progress: progress)
  }

  // MARK: - Private methods

  override func previousTapped() {
    self.eventHandler.previousStepTapped()
  }

  override func nextTapped() {
    _ = self.formView.resignFirstResponder()
    self.eventHandler.nextStepTapped()
  }

  override func closeTapped() {
    self.eventHandler.closeTapped()
  }
}

private extension UserDataCollectorViewController {
  func setUpUI() {
    view.backgroundColor = self.uiConfiguration.uiBackgroundPrimaryColor
    navigationController?.navigationBar.setUpWith(uiConfig: uiConfiguration)
    edgesForExtendedLayout = .top
    extendedLayoutIncludesOpaqueBars = true
    view.addSubview(progressView)
    view.addSubview(formView)
    progressView.snp.makeConstraints { make in
      make.top.equalTo(topLayoutGuide.snp.bottom)
      make.left.right.equalTo(view)
      make.height.equalTo(4)
    }
    formView.snp.makeConstraints { make in
      make.top.equalTo(progressView.snp.bottom)
      make.left.right.bottom.equalTo(view)
    }
    formView.backgroundColor = UIColor.clear
  }
}
