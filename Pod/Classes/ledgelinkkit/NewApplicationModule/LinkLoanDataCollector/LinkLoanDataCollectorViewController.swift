//
//  LoanDataCollectorViewController.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 06/03/16.
//
//

import Foundation
import Bond

protocol LinkLoanDataCollectorEventHandler {
  func viewLoaded()
  func nextTapped()
  func previousTapped()
  func closeTapped()
}

class LinkLoanDataCollectorViewController: ShiftViewController, LinkLoanDataCollectorViewProtocol {

  let eventHandler: LinkLoanDataCollectorEventHandler

  fileprivate let formView: MultiStepForm
  fileprivate let progressView: ProgressView

  init(uiConfiguration: ShiftUIConfig, eventHandler:LinkLoanDataCollectorEventHandler) {
    self.formView = MultiStepForm()
    self.progressView = ProgressView(maxValue: 100, uiConfig: uiConfiguration)
    self.eventHandler = eventHandler
    super.init(uiConfiguration: uiConfiguration)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = self.uiConfiguration.backgroundColor
    self.navigationController?.navigationBar.backgroundColor = self.uiConfiguration.uiPrimaryColor
    self.edgesForExtendedLayout = .top
    self.extendedLayoutIncludesOpaqueBars = true
    self.view.addSubview(self.progressView)
    self.progressView.translatesAutoresizingMaskIntoConstraints = false
    self.view.addSubview(self.formView)
    self.formView.backgroundColor = UIColor.clear
    self.eventHandler.viewLoaded()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Public methods

  func show(fields:[FormRowView]) {
    self.formView.show(rows: fields)
  }

  func showNavProfileButton(_ tintColor: UIColor? = nil) {
    self.installNavRightButton(UIImage.imageFromPodBundle("top_profile.png"), tintColor:tintColor, target: self, action: #selector(LinkLoanDataCollectorViewController.nextTapped))
  }

  func showProgressBar() {
    self.progressView.snp.remakeConstraints { make in
      make.top.equalTo(topLayoutGuide.snp.bottom)
      make.left.right.equalTo(self.view)
      make.height.equalTo(4)
    }
    self.formView.snp.remakeConstraints { make in
      make.top.equalTo(self.progressView.snp.bottom)
      make.left.right.bottom.equalTo(self.view)
    }
  }

  func hideProgressBar() {
    self.formView.snp.remakeConstraints { make in
      make.top.equalTo(topLayoutGuide.snp.bottom)
      make.left.right.bottom.equalTo(self.view)
    }
  }


  // MARK: - Private methods

  override func previousTapped() {
    self.eventHandler.previousTapped()
  }

  override func nextTapped() {
    self.eventHandler.nextTapped()
  }

  override func closeTapped() {
    self.eventHandler.closeTapped()
  }

}
