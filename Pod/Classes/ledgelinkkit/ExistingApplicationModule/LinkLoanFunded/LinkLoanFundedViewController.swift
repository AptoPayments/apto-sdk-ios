//
//  LinkLoanFundedViewController.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 18/11/2016.
//
//

import Foundation
import Bond
import ReactiveKit
import TTTAttributedLabel

protocol LinkLoanFundedEventHandler {
  var viewModel: LinkLoanFundedViewModel { get }
  func viewLoaded()
  func viewShown()
  func closeTapped()
}

class LinkLoanFundedViewController: ShiftViewController, LinkLoanFundedViewProtocol {

  let eventHandler: LinkLoanFundedEventHandler

  init(uiConfiguration: ShiftUIConfig, eventHandler:LinkLoanFundedEventHandler) {
    self.eventHandler = eventHandler
    super.init(uiConfiguration: uiConfiguration)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = "Loan Funded"
    self.view.backgroundColor = self.uiConfiguration.uiBackgroundPrimaryColor
    self.navigationController?.navigationBar.backgroundColor = self.uiConfiguration.uiPrimaryColor
    self.edgesForExtendedLayout = UIRectEdge()
    self.setupUI()
    self.showNavCancelButton(self.uiConfiguration.iconTertiaryColor)
    self.eventHandler.viewLoaded()
  }

  func setupWith(viewModel:LinkLoanFundedViewModel) {
    viewModel.cloudImage.bind(to:self.cloudIcon)
    viewModel.descriptionText.bind(to:self.descriptionLabel.reactive.text)
    let _ = combineLatest(viewModel.showAction, viewModel.actionTitle)
      .observeNext { [weak self] showAction, actionTitle in
        guard showAction == true && actionTitle != "" else {
          self?.hideAction()
          return
        }
        self?.showAction(title: actionTitle, actionHandler: viewModel.actionHandler)
    }
    let _ = combineLatest(viewModel.showSecondaryAction, viewModel.secondaryActionTitle)
      .observeNext { [weak self] showSecondaryAction, secondaryActionTitle in
        guard showSecondaryAction == true && secondaryActionTitle != "" else {
          self?.hideSecondaryAction()
          return
        }
        self?.showSecondaryAction(title: secondaryActionTitle, actionHandler: viewModel.secondaryActionHandler)
    }
  }

  func presentActionSheet(_ actionSheet:UIAlertController) {
    self.present(actionSheet, animated: true, completion: nil)
  }

  // MARK: Private methods

  let loadingView = UIView()
  let loadingLabel = UILabel()

  let errorLabel = UILabel()
  let errorView = UIView()

  let feedbackView = UIView()
  let cloudIcon = UIImageView()
  let descriptionLabel = UILabel()
  var actionButton: UIButton!
  var actionHandler: (()->Void)? = nil
  var secondaryActionButton: UIButton!
  var secondaryActionHandler: (()->Void)? = nil

  fileprivate func setupUI() {

    cloudIcon.contentMode = .scaleAspectFit
    feedbackView.addSubview(cloudIcon)
    cloudIcon.snp.makeConstraints { make in
      make.top.equalTo(feedbackView)
      make.centerX.equalTo(feedbackView)
      make.height.lessThanOrEqualTo(180)
    }
    descriptionLabel.numberOfLines = 0
    descriptionLabel.textAlignment = .center
    feedbackView.addSubview(descriptionLabel)
    descriptionLabel.snp.makeConstraints { make in
      make.top.equalTo(cloudIcon.snp.bottom).offset(30)
      make.left.right.equalTo(feedbackView).inset(15)
    }

    actionButton = ComponentCatalog.buttonWith(title: "verify_phone.submit_button.title".podLocalized(),
                                               accessibilityLabel: "Submit PIN Code",
                                               uiConfig: self.uiConfiguration) { [weak self] in
      self?.actionTapped()
    }
    feedbackView.addSubview(actionButton)
    actionButton.snp.makeConstraints { make in
      make.top.equalTo(descriptionLabel.snp.bottom).offset(30)
      make.centerX.equalTo(feedbackView)
      make.height.equalTo(44)
      make.leading.trailing.equalTo(descriptionLabel)
    }
    actionButton.isHidden = true

    secondaryActionButton = ComponentCatalog.formTextLinkButtonWith(
      title: "verify_phone.resend_button.title".podLocalized(),
      uiConfig: uiConfiguration) { [weak self] in
      self?.secondaryActionTapped()
    }
    feedbackView.addSubview(secondaryActionButton)
    secondaryActionButton.snp.makeConstraints { make in
      make.top.equalTo(actionButton.snp.bottom).offset(30)
      make.centerX.equalTo(feedbackView)
      make.height.equalTo(44)
      make.leading.trailing.equalTo(actionButton)
      make.bottom.equalTo(feedbackView)
    }
    secondaryActionButton.isHidden = true

    view.addSubview(feedbackView)
    feedbackView.snp.makeConstraints { make in
      make.center.equalTo(view)
      make.left.right.equalTo(view).inset(15)
    }

  }

  fileprivate func showAction(title:String, actionHandler:(()->Void)?) {
    self.actionButton.setTitle(title, for: UIControlState())
    self.actionButton.isHidden = false
    self.actionHandler = actionHandler
  }

  fileprivate func hideAction() {
    guard feedbackView.superview != nil else {
      return
    }
    self.actionButton.isHidden = true
    self.actionHandler = nil
  }

  fileprivate func showSecondaryAction(title:String, actionHandler:(()->Void)?) {
    self.secondaryActionButton.setTitle(title, for: UIControlState())
    self.secondaryActionButton.isHidden = false
    self.secondaryActionHandler = actionHandler
  }

  fileprivate func hideSecondaryAction() {
    guard feedbackView.superview != nil else {
      return
    }
    self.secondaryActionButton.isHidden = true
    self.secondaryActionHandler = nil
  }

  func actionTapped() {
    self.actionHandler?()
  }

  func secondaryActionTapped() {
    self.secondaryActionHandler?()
  }

  override func closeTapped() {
    eventHandler.closeTapped()
  }

}
