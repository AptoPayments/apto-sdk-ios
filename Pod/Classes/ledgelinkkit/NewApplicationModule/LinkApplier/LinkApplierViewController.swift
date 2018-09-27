//
//  ApplicationFeedbackViewController.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 19/03/16.
//
//

import Bond
import TTTAttributedLabel

protocol LinkApplierEventHandlerProtocol {
  func viewLoaded()
  func retryTapped()
  func closeTapped()
}

class LinkApplierViewController: ShiftViewController, LinkApplicationFeedbackViewProtocol {

  let eventHandler: LinkApplierEventHandlerProtocol

  init(uiConfiguration: ShiftUIConfig, eventHandler: LinkApplierEventHandlerProtocol) {
    self.eventHandler = eventHandler
    super.init(uiConfiguration: uiConfiguration)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = self.uiConfiguration.backgroundColor
    self.navigationController?.navigationBar.backgroundColor = self.uiConfiguration.uiPrimaryColor
    self.edgesForExtendedLayout = UIRectEdge()
    self.setupLoadingView()
    self.setupErrorView()
    self.eventHandler.viewLoaded()
  }

  func showLoadingState() {
    DispatchQueue.main.async { [weak self] in
      guard let wself = self else {
        return
      }
      self?.showNavCancelButton(self?.uiConfiguration.iconTertiaryColor)
      self?.hideNavNextButton()
      wself.view.fadeIn(animations: {
        for subview in wself.view.subviews {
          subview.removeFromSuperview()
        }
        wself.view.addSubview(wself.loadingView)
        wself.loadingView.snp.makeConstraints { make in
          make.left.right.top.bottom.equalTo(wself.view)
        }
      })
    }
  }

  func showErrorState(_ errorMessage:String) {
    DispatchQueue.main.async { [weak self] in
      guard let wself = self else {
        return
      }
      self?.showNavCancelButton(self?.uiConfiguration.iconTertiaryColor)
      self?.hideNavNextButton()
      wself.view.fadeIn(animations: {
        wself.errorLabel.text = errorMessage
        for subview in wself.view.subviews {
          subview.removeFromSuperview()
        }
        wself.view.addSubview(wself.errorView)
        wself.errorView.snp.makeConstraints { make in
          make.centerX.centerY.equalTo(wself.view)
        }
        }, completion: nil)
    }
  }

  // MARK: Private methods

  let loadingView = UIView()
  let loadingLabel = UILabel()

  let errorLabel = UILabel()
  let errorView = UIView()

  let feedbackView = UIView()
  let cloudIcon = UIImageView()
  let statusLabel = TTTAttributedLabel(frame:CGRect.zero)
  let actionButton = UIButton()
  var uiInitialized = false
  var actionHandler: (()->Void)? = nil
  fileprivate var statusLabelHandler: StatusLabelHandler!

  fileprivate func setupLoadingView() {
    let view = UIView()
    loadingView.addSubview(view)
    view.snp.makeConstraints { make in
      make.centerX.centerY.equalTo(loadingView)
      make.left.right.equalTo(loadingView).inset(40)
    }
    let rocketView = UIView()
    loadingView.addSubview(rocketView)
    rocketView.snp.makeConstraints { make in
      make.centerX.equalTo(view)
      make.top.equalTo(view)
    }
    let rocketImageView = UIImageView(image: UIImage.imageFromPodBundle("rocket.png"))
    rocketView.addSubview(rocketImageView)
    rocketImageView.snp.makeConstraints {make in
      make.left.bottom.equalTo(rocketView)
      make.top.equalTo(rocketView).offset(15)
      make.width.height.equalTo(120)
    }
    let coinImageView = UIImageView(image: UIImage.imageFromPodBundle("dollarCoin.png"))
    rocketView.addSubview(coinImageView)
    coinImageView.snp.makeConstraints {make in
      make.left.equalTo(rocketImageView.snp.right).offset(10)
      make.top.right.equalTo(rocketView)
      make.width.height.equalTo(40)
    }
    let loadingLabel = UILabel()
    loadingLabel.text = "application-feedback.applying-to-offer".podLocalized()
    loadingLabel.numberOfLines = 0
    loadingLabel.textAlignment = .center
    view.addSubview(loadingLabel)
    loadingLabel.snp.makeConstraints { make in
      make.centerX.equalTo(view)
      make.top.equalTo(rocketView.snp.bottom).offset(15)
      make.left.right.equalTo(view).inset(15)
      make.bottom.equalTo(view)
    }
  }

  fileprivate func setupErrorView() {
    let exclamationIcon = UIImageView(image: UIImage.imageFromPodBundle("error_cloud.png"))
    errorView.addSubview(exclamationIcon)
    exclamationIcon.snp.makeConstraints { make in
      make.centerX.equalTo(errorView)
      make.top.equalTo(errorView)
      make.width.height.equalTo(180)
    }
    errorLabel.numberOfLines = 0
    errorLabel.textAlignment = .center
    errorView.addSubview(errorLabel)
    errorLabel.snp.makeConstraints { make in
      make.centerX.equalTo(errorView)
      make.left.right.equalTo(errorView).inset(15)
      make.top.equalTo(exclamationIcon.snp.bottom)
    }
    let retryButton = UIButton.roundedButtonWith("application-feedback.button.retry".podLocalized(), backgroundColor: uiConfiguration.tintColor) { self.eventHandler.retryTapped() }
    errorView.addSubview(retryButton)
    retryButton.snp.makeConstraints { make in
      make.centerX.equalTo(errorView)
      make.top.equalTo(errorLabel.snp.bottom).offset(30)
      make.bottom.equalTo(errorView)
      make.width.equalTo(180)
      make.height.equalTo(44)
    }
  }

  fileprivate func showAction(title:String, actionHandler:(()->Void)?) {
    self.actionButton.setTitle(title, for: UIControlState())
    self.actionButton.isHidden = false
    self.feedbackView.setNeedsUpdateConstraints()
    self.actionHandler = actionHandler
    feedbackView.snp.remakeConstraints { make in
      make.top.equalTo(cloudIcon)
      make.bottom.equalTo(actionButton).offset(-15)
    }
  }

  fileprivate func hideAction() {
    guard uiInitialized == true else {
      return
    }
    self.actionButton.isHidden = true
    self.feedbackView.setNeedsUpdateConstraints()
    self.actionHandler = nil
    feedbackView.snp.remakeConstraints { make in
      make.top.equalTo(cloudIcon)
      make.bottom.equalTo(statusLabel)
    }
  }

  func actionTapped() {
    self.actionHandler?()
  }

  override func closeTapped() {
    eventHandler.closeTapped()
  }

}
