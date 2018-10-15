//
//  MainViewController.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 31/10/2016.
//
//

import Foundation

import UIKit
import ShiftSDK
import Bond

class MainViewController: UIViewController {
  fileprivate struct Params {
    static let labelWidth: CGFloat = 120
    static let blueColor: UIColor = UIColor(red: 0.0, green: 0.45, blue: 0.94, alpha: 1.0)
  }

  fileprivate var launchLinkFlowButton: UIButton!
  fileprivate var launchCardFlowButton: UIButton!
  private let shiftSession = ShiftSession()

  @IBOutlet weak var brandingView: UIView!
  @IBOutlet weak var bottomView: UIView!
  @IBOutlet weak var projectLogo: UIImageView!
  @IBOutlet weak var explanationLabel: UILabel!
  @IBOutlet weak var versionLabel: UILabel!

  override func viewDidLoad() {
    super.viewDidLoad()

    launchCardFlowButton = self.buttonWith(title: "launcher.launch-card-flow-button.title".localized(),
                                           tintColor: colorize(0x17a94f))
    self.bottomView.addSubview(launchCardFlowButton)
    launchCardFlowButton.snp.makeConstraints { make in
      make.left.right.bottom.equalTo(self.bottomView).inset(20)
    }
    let _ = launchCardFlowButton.reactive.tap.observeNext { [unowned self] in
      self.showCardSDK()
    }

    launchLinkFlowButton = self.buttonWith(title: "launcher.launch-link-flow-button.title".localized(),
                                           tintColor: colorize(0x17a94f))
    self.bottomView.addSubview(launchLinkFlowButton)
    launchLinkFlowButton.snp.makeConstraints { make in
      make.left.right.equalTo(self.bottomView).inset(20)
      make.bottom.equalTo(self.launchCardFlowButton.snp.top).offset(-20)
    }
    let _ = launchLinkFlowButton.reactive.tap.observeNext {
      self.showLinkSDK()
    }

    var buildType = ""
    if LOCAL_BUILD.boolValue {
      buildType = "Local"
    }
    else if DEV_BUILD.boolValue {
      buildType = "Dev"
    }
    else if STG_BUILD.boolValue {
      buildType = "Staging"
    }
    else if SBX_BUILD.boolValue {
      buildType = "Sandbox"
    }
    else if PRD_BUILD.boolValue {
      buildType = ""
    }

    self.explanationLabel.text = "Shift SDK Demo App"
    self.versionLabel.text = "Shift SDK Demo App (\(buildType))\nversion \(BuildInformation.version!), build \(BuildInformation.build!)"

    ShiftPlatform.defaultManager().delegate = self
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }

  fileprivate func colorize(_ hex: Int, alpha: Double = 1.0) -> UIColor {
    let red = Double((hex & 0xFF0000) >> 16) / 255.0
    let green = Double((hex & 0xFF00) >> 8) / 255.0
    let blue = Double((hex & 0xFF)) / 255.0
    return UIColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: CGFloat(alpha))
  }

  fileprivate func buttonWith(title: String, tintColor: UIColor) -> UIButton {
    let button = UIButton()
    button.layer.masksToBounds = true
    button.layer.cornerRadius = 5
    button.clipsToBounds = true
    button.backgroundColor = tintColor
    button.snp.makeConstraints { make in
      make.height.equalTo(44)
    }
    button.setTitle(title, for: UIControlState())
    return button
  }

  fileprivate func showLinkSDK() {
    // Launch Link Flow
    self.showLoadingSpinner(tintColor: .white, position: .bottomCenter)
    shiftSession.startLinkFlow(from: self) { [weak self] result in
      self?.hideLoadingSpinner()
      switch result {
      case .failure(let error):
        self?.show(error: error)
      case .success:
        break
      }
    }
  }

  fileprivate func showCardSDK() {
    // Launch Card Flow
    self.showLoadingSpinner(tintColor: .white, position: .bottomCenter)
    shiftSession.startCardFlow(from: self, mode: .standalone) { [weak self] result in
      self?.hideLoadingSpinner()
      switch result {
      case .failure(let error):
        self?.show(error: error)
      case .success:
        break
      }
    }
  }
}

extension MainViewController: ShiftPlatformDelegate {

  func shiftSDKInitialized(apiKey: String) {
    print ("shiftSDKInitialized")
  }

  func sdkDeprecated() {
    print ("sdkDeprecated")
  }

  func newUserTokenReceived(_ userToken: String?) {
    print ("newUserTokenReceived")
  }

}
