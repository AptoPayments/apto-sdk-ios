//
//  OfferLoaderViewController.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 12/02/16.
//
//

import UIKit

protocol LinkOfferLoaderEventHandler: NavigationMenuListener {
  func viewLoaded()
  func viewShown()
  func retryTapped()
  func updateRequestTapped()
  func closeTapped()
}

class LinkOfferLoaderViewController: ShiftViewController, LinkOfferLoaderViewProtocol {

  let eventHandler: LinkOfferLoaderEventHandler
  let loadingView = UIView()
  let errorView = UIView()
  let emptyCaseView = UIView()
  fileprivate var navigationMenu: NavigationMenu?

  init(uiConfiguration: ShiftUIConfig, eventHandler:LinkOfferLoaderEventHandler) {
    self.eventHandler = eventHandler
    super.init(uiConfiguration: uiConfiguration)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = self.uiConfiguration.backgroundColor
    self.title = "offer-loader.title".podLocalized()
    self.setupLoadingView()
    self.setupErrorView()
    self.setupEmptyCaseView()
    self.showNavCancelButton(self.uiConfiguration.iconTertiaryColor)
    self.navigationMenu = NavigationMenu(viewController: self, uiConfiguration: self.uiConfiguration, menuListener: eventHandler)
    self.navigationMenu?.install()
    self.hideNavNextButton()
    self.eventHandler.viewLoaded()
    self.edgesForExtendedLayout = .top
    self.extendedLayoutIncludesOpaqueBars = true
  }

  override func viewDidAppear(_ animated: Bool) {
    self.eventHandler.viewShown()
  }

  func showLoadingState() {
    DispatchQueue.main.async { [weak self] in
      guard let wself = self else {
        return
      }
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

      self?.animateRocket()

    }
  }

  func showEmptyCaseState() {
    DispatchQueue.main.async { [weak self] in
      guard let wself = self else {
        return
      }
      wself.navigationMenu?.install()
      wself.view.fadeIn(animations: {
        for subview in wself.view.subviews {
          subview.removeFromSuperview()
        }
        wself.view.addSubview(wself.emptyCaseView)
        wself.emptyCaseView.snp.makeConstraints { make in
          make.centerX.centerY.equalTo(wself.view)
        }
        }, completion: nil)
    }
  }

  func showErrorState(_ errorMessage:String) {
    DispatchQueue.main.async { [weak self] in
      guard let wself = self else {
        return
      }
      wself.navigationMenu?.install()
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

  // MARK: - Private methods

  fileprivate var rocketImageView: UIImageView!
  fileprivate var coinImageView: UIImageView!

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
    self.rocketImageView = UIImageView(image: UIImage.imageFromPodBundle("rocket.png"))
    rocketView.addSubview(rocketImageView)
    rocketImageView.snp.makeConstraints {make in
      make.left.bottom.equalTo(rocketView)
      make.top.equalTo(rocketView).offset(15)
      make.width.height.equalTo(120)
    }
    self.coinImageView = UIImageView(image: UIImage.imageFromPodBundle("dollarCoin.png"))
    rocketView.addSubview(coinImageView)
    coinImageView.snp.makeConstraints {make in
      make.left.equalTo(rocketImageView.snp.right).offset(10)
      make.top.right.equalTo(rocketView).offset(-10)
      make.width.height.equalTo(40)
    }
    let loadingLabel = UILabel()
    loadingLabel.text = "offer-loader.loading-offers".podLocalized()
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

  fileprivate func animateRocket() {
    let anim = CAKeyframeAnimation (keyPath: "transform")
    anim.values = [
      NSValue( caTransform3D:CATransform3DMakeTranslation(-5, -5, 0 ) ),
      NSValue( caTransform3D:CATransform3DMakeTranslation( 5, 5, 0 ) )
    ]
    anim.autoreverses = true
    anim.repeatCount = Float.infinity
    anim.duration = 1.6
    anim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
    rocketImageView.layer.add( anim, forKey:nil )
  }

  fileprivate let errorLabel = UILabel()

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
    let retryButton = UIButton.roundedButtonWith("Retry", backgroundColor: uiConfiguration.tintColor) { self.eventHandler.retryTapped() }
    errorView.addSubview(retryButton)
    retryButton.snp.makeConstraints { make in
      make.centerX.equalTo(errorView)
      make.top.equalTo(errorLabel.snp.bottom).offset(30)
      make.bottom.equalTo(errorView)
      make.width.equalTo(180)
      make.height.equalTo(44)
    }
  }

  fileprivate func setupEmptyCaseView() {
    let emptyCaseIcon = UIImageView(image: UIImage.imageFromPodBundle("sad_cloud.png"))
    emptyCaseView.addSubview(emptyCaseIcon)
    emptyCaseIcon.snp.makeConstraints { make in
      make.centerX.equalTo(emptyCaseView)
      make.top.equalTo(emptyCaseView)
      make.width.height.equalTo(180)
    }
    let emptyCaseLabel = UILabel()
    emptyCaseLabel.numberOfLines = 0
    emptyCaseLabel.textAlignment = .center
    emptyCaseLabel.text = "offer-loader.text.no-offers-found".podLocalized()
    emptyCaseView.addSubview(emptyCaseLabel)
    emptyCaseLabel.snp.makeConstraints { make in
      make.centerX.equalTo(emptyCaseView)
      make.left.right.equalTo(emptyCaseView).inset(15)
      make.top.equalTo(emptyCaseIcon.snp.bottom)
    }
    let retryButton = UIButton.roundedButtonWith("offer-loader.button.update-loan-request".podLocalized(), backgroundColor: uiConfiguration.tintColor) { self.eventHandler.updateRequestTapped() }
    emptyCaseView.addSubview(retryButton)
    retryButton.snp.makeConstraints { make in
      make.centerX.equalTo(emptyCaseView)
      make.top.equalTo(emptyCaseLabel.snp.bottom).offset(30)
      make.bottom.equalTo(emptyCaseView)
      make.width.equalTo(220)
      make.height.equalTo(44)
    }
  }

  override func closeTapped() {
    self.eventHandler.closeTapped()
  }

}
