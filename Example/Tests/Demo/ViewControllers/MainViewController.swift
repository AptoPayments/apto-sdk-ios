//
//  MainViewController.swift
//  LedgeLink
//
//  Created by Ivan Oliver Martínez on 31/10/2016.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation

import UIKit
import LedgeLink
import Bond

class MainViewController: UIViewController {

  private struct Params {
    static let labelWidth: CGFloat = 120
    static let blueColor: UIColor = UIColor(red: 0.0, green: 0.45, blue: 0.94, alpha: 1.0)
  }

  private var rows: [FormRowView]? = nil
  private var manager: LedgeLink!
  private var applicationData = LoanApplication()
  private var flowConfiguration = LedgeLinkFlowConfig()
  private let flatView = UIImageView(image: UIImage(named: "BackgroundImage"))

  @IBOutlet weak var explanationLabel: UILabel!
  @IBOutlet weak var versionLabel: UILabel!

  override func viewDidLoad() {

    super.viewDidLoad()

    flowConfiguration.uiConfig.formLabelTextFocusedColor = colorize(0x006837)
    flowConfiguration.uiConfig.formAuxiliarViewBackgroundColor = colorize(0xfafafa)
    flowConfiguration.uiConfig.formSliderHighlightedTrackColor = colorize(0x006837)
    flowConfiguration.uiConfig.formSliderValueTextColor = colorize(0x006837)
    flowConfiguration.uiConfig.tintColor = colorize(0x17a94f)
    flowConfiguration.uiConfig.offerApplyButtonTextColor = colorize(0x17a94f)
    flowConfiguration.uiConfig.disabledTintColor = colorize(0xa9a9a9)
    flowConfiguration.uiConfig.offerListStyle = .Carousel

    // Behavior configuration
    flowConfiguration.strictAddressValidation = true
    flowConfiguration.GoogleGeocodingAPIKey = "AIzaSyChG61EnKGAlmhP5tdd4RtE5s8Hpi8EOII"
    flowConfiguration.maxAmount = 25000
    flowConfiguration.amountIncrements = 500
    flowConfiguration.confirmCloseAction = true
    flowConfiguration.skipDisclaimer = true

    let settingsButton = UIButton(type: .Custom)
    let image = UIImage(named: "SettingsIcon")?.imageWithRenderingMode(.AlwaysTemplate)
    settingsButton.setImage(image, forState: .Normal)
    settingsButton.tintColor = self.colorize(0x006837)

    self.view.addSubview(settingsButton)
    settingsButton.snp_makeConstraints { make in
      make.right.equalTo(self.view)
      make.top.equalTo(self.view).offset(20)
      make.width.height.equalTo(44)
    }
    settingsButton.bnd_tap.observe {
      self.showSettingsScreen()
    }

    let getOffersButton = self.buttonWith(title: "Get Started", uiConfig: flowConfiguration.uiConfig)
    self.view.addSubview(getOffersButton)
    getOffersButton.snp_makeConstraints { make in
      make.left.right.equalTo(self.view).inset(20)
      make.bottom.equalTo(versionLabel.snp_top).offset(-20)
    }
    getOffersButton.bnd_tap.observe {
      self.showLinkSDK()
    }

    // SDK initialization
    manager = LedgeLink.defaultManager()

    var devKey: String = ""
    let sandbox = false
    var local = false
    var development = false
    if ALPHA_BUILD {
      devKey = "rLDJkiHwo4/Kji7US65nL97KXqxOKLKl7Hq5QzQ9Ph7Qsx+6oLcgmBf/3WNY3Nvw"
      development = true
      local = false
    }
    else if BETA_BUILD {
      //devKey = "H5E2bhKJv/59b3ydTkAvH3yGrJufI1axxzanAvH79dCCoNwmaxDRIRwuej4SPXle"
      devKey = "B2gZ5ha+81Uwj2Ga+jNu40iqTfmqTi/tO80GLVtAs5PbbI9WuFyogQ2WhGyjnrg9" // staging Creditshop only
      development = true
      local = false
    }
    else if RELEASE_BUILD {
      devKey = "H5E2bhKJv/59b3ydTkAvH3yGrJufI1axxzanAvH79dCCoNwmaxDRIRwuej4SPXle"
      development = false
      local = false
    }
    else {
      devKey = "AE+sTVIjtQ312AqtlXRlfY9HhoraVjeoB5X6lnNEjoCBUs4oSY10cLoixrC6iKfH" // CreditShop only
      local = true
    }
    devKey = "rLDJkiHwo4/Kji7US65nL97KXqxOKLKl7Hq5QzQ9Ph7Qsx+6oLcgmBf/3WNY3Nvw"
    development = true
    local = false
    manager.initializeWithDeveloperKey(devKey,
                                       sandbox: sandbox,
                                       development: development,
                                       local: local,
                                       setupCertPinning: false)
    // UI Setup
    var buildType = "Dev"
    if ALPHA_BUILD {
      buildType = "Alpha"
    }
    else if BETA_BUILD {
      buildType = "Beta"
    }
    else if RELEASE_BUILD {
      buildType = ""
    }
    self.explanationLabel.text = "CreditShop is dedicated to providing consumers with convenient personal loans at fair prices."
    self.versionLabel.text = "Ledge Demo App (\(buildType))\nversion \(BuildInformation.version!), build \(BuildInformation.build!)"

  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }

  private func colorize (hex: Int, alpha: Double = 1.0) -> UIColor {
    let red = Double((hex & 0xFF0000) >> 16) / 255.0
    let green = Double((hex & 0xFF00) >> 8) / 255.0
    let blue = Double((hex & 0xFF)) / 255.0
    return UIColor( red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha:CGFloat(alpha) )
  }

  private func buttonWith(title title:String, uiConfig:LedgeLinkFlowUIConfig) -> UIButton {
    let button = UIButton()
    button.layer.masksToBounds = true
    button.layer.cornerRadius = 5
    button.clipsToBounds = true
    button.backgroundColor = uiConfig.tintColor
    button.snp_makeConstraints { make in
      make.height.equalTo(44)
    }
    button.setTitle(title, forState: .Normal)
    return button
  }

  private func showSettingsScreen() {
    let nc = UINavigationController(rootViewController: SettingsViewController(manager:self.manager, applicationData:applicationData, flowConfiguration: flowConfiguration))
    self.presentViewController(nc, animated:true, completion:nil)
  }

  private func showLinkSDK() {
    flowConfiguration.uiConfig.formLabelTextFocusedColor = colorize(0x006837)
    flowConfiguration.uiConfig.formAuxiliarViewBackgroundColor = colorize(0xfafafa)
    flowConfiguration.uiConfig.formSliderHighlightedTrackColor = colorize(0x006837)
    flowConfiguration.uiConfig.formSliderValueTextColor = colorize(0x006837)
    flowConfiguration.uiConfig.tintColor = colorize(0x17a94f)
    flowConfiguration.uiConfig.offerApplyButtonTextColor = colorize(0x17a94f)
    flowConfiguration.uiConfig.disabledTintColor = colorize(0xa9a9a9)
    flowConfiguration.uiConfig.offerListStyle = .Carousel

    // Behavior configuration
    flowConfiguration.strictAddressValidation = true
    flowConfiguration.GoogleGeocodingAPIKey = "AIzaSyChG61EnKGAlmhP5tdd4RtE5s8Hpi8EOII"
    flowConfiguration.maxAmount = 25000
    flowConfiguration.amountIncrements = 500
    flowConfiguration.confirmCloseAction = true
    flowConfiguration.skipDisclaimer = true

    manager.uiDelegate = self
    manager.launchProcess(initialData: applicationData, flowConfiguration: flowConfiguration)
  }

}

extension MainViewController: LedgeLinkUIDelegate {

  func didFailShowingUserInterface(error:NSError) {
    hideBackgroundView()
    self.showError(error)
  }

  func didShowUserInterface() {
    showBackgroundView()
  }

  func didCloseUserInterface() {

    hideBackgroundView()

    if flowConfiguration.confirmCloseAction {

      LedgeLink.defaultManager().clearUserToken()
      applicationData = LoanApplication()
      flowConfiguration = LedgeLinkFlowConfig()

      flowConfiguration.uiConfig.formLabelTextFocusedColor = colorize(0x006837)
      flowConfiguration.uiConfig.formAuxiliarViewBackgroundColor = colorize(0xfafafa)
      flowConfiguration.uiConfig.formSliderHighlightedTrackColor = colorize(0x006837)
      flowConfiguration.uiConfig.formSliderValueTextColor = colorize(0x006837)
      flowConfiguration.uiConfig.tintColor = colorize(0x17a94f)
      flowConfiguration.uiConfig.offerApplyButtonTextColor = colorize(0x17a94f)
      flowConfiguration.uiConfig.disabledTintColor = colorize(0xa9a9a9)
      flowConfiguration.uiConfig.offerListStyle = .Carousel

      // Behavior configuration
      flowConfiguration.strictAddressValidation = true
      flowConfiguration.GoogleGeocodingAPIKey = "AIzaSyChG61EnKGAlmhP5tdd4RtE5s8Hpi8EOII"
      flowConfiguration.maxAmount = 25000
      flowConfiguration.amountIncrements = 500
      flowConfiguration.confirmCloseAction = true
      flowConfiguration.skipDisclaimer = true
    }

  }

  private func showBackgroundView() {
    self.flatView.alpha = 0
    self.view.addSubview(self.flatView)
    self.flatView.snp_makeConstraints { make in
      make.left.right.top.bottom.equalTo(self.view)
    }
    UIView.animateWithDuration(1.5, animations: { () -> Void in
      self.flatView.alpha = 1
    })
  }

  private func hideBackgroundView() {
    UIView.animateWithDuration(0.3, animations: {
      self.flatView.alpha = 0
    }) { completed in
      self.flatView.removeFromSuperview()
    }
  }

  private func showError(error:NSError) {
    let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .Alert)
    alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler:nil))
    self.presentViewController(alertController, animated: true, completion: nil)
  }

}
