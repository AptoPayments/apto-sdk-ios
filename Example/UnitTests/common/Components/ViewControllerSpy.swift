//
//  ViewControllerSpy.swift
//  ShiftSDK
//
//  Created by Takeichi Kanzaki on 14/06/2018.
//
//

@testable import ShiftSDK

class ViewControllerSpy: ViewControllerProtocol {

  private(set) var setTitleCalled = false
  private(set) var lastTitle: String?
  func set(title: String) {
    setTitleCalled = true
    lastTitle = title
  }

  private(set) var showNavPreviousButtonCalled = false
  private(set) var lastPreviousButtonTintColor: UIColor?
  func showNavPreviousButton(_ tintColor: UIColor?) {
    showNavPreviousButtonCalled = true
    lastPreviousButtonTintColor = tintColor
  }

  private(set) var showNavNextButtonWithTitleCalled = false
  private(set) var lastNextButtonTitle: String?
  private(set) var lastNextButtonTintColor: UIColor?
  func showNavNextButton(title: String, tintColor: UIColor?) {
    showNavNextButtonWithTitleCalled = true
    lastNextButtonTitle = title
    lastNextButtonTintColor = tintColor
  }

  private(set) var showNavNextButtonWithIconCalled = false
  private(set) var lastNextButtonIcon: UIImage?
  func showNavNextButton(icon: UIImage, tintColor: UIColor?) {
    showNavNextButtonWithIconCalled = true
    lastNextButtonIcon = icon
    lastNextButtonTintColor = tintColor
  }

  private(set) var showNavNextButtonCalled = false
  func showNavNextButton(tintColor: UIColor?) {
    showNavNextButtonCalled = true
    lastNextButtonTintColor = tintColor
  }

  private(set) var hideNavNextButtonCalled = true
  func hideNavNextButton() {
    hideNavNextButtonCalled = true
  }

  private(set) var showNavCancelButtonCalled = false
  private(set) var lastNavCancelButtonTintColor: UIColor?
  func showNavCancelButton(_ tintColor: UIColor?) {
    showNavCancelButtonCalled = true
    lastNavCancelButtonTintColor = tintColor
  }

  private(set) var activateNavNextButtonCalled = false
  private(set) var lastActivateNavNextButtonTintColor: UIColor?
  func activateNavNextButton(_ tintColor: UIColor?) {
    activateNavNextButtonCalled = true
    lastActivateNavNextButtonTintColor = tintColor
  }

  private(set) var deactivateNavNextButtonCalled = false
  private(set) var lastDeactivateNavNextButtonTintColor: UIColor?
  func deactivateNavNextButton(_ deactivatedTintColor: UIColor?) {
    deactivateNavNextButtonCalled = true
    lastDeactivateNavNextButtonTintColor = deactivatedTintColor
  }

  private (set) var configureLeftNavButtonCalled = false
  private (set) var lastConfigureLeftNavButtonMode: UIViewControllerLeftButtonMode?
  private (set) var lastConfigureLeftNavButtonUIConfig: ShiftUIConfig?
  func configureLeftNavButton(mode: UIViewControllerLeftButtonMode?, uiConfig: ShiftUIConfig?) {
    configureLeftNavButtonCalled = true
    lastConfigureLeftNavButtonMode = mode
    lastConfigureLeftNavButtonUIConfig = uiConfig
  }

  private(set) var showErrorCalled = false
  private(set) var lastErrorShown: Error?
  func show(error: Error) {
    showErrorCalled = true
    lastErrorShown = error
  }

  private(set) var showNetworkNotReachableErrorCalled = false
  private(set) var lastNetworkNotReachableErrorConfig: ShiftUIConfig?
  func showNetworkNotReachableError(_ uiConfig: ShiftUIConfig?) {
    showNetworkNotReachableErrorCalled = true
    lastNetworkNotReachableErrorConfig = uiConfig
  }

  private(set) var hideNetworkNotReachableErrorCalled = false
  func hideNetworkNotReachableError() {
    hideNetworkNotReachableErrorCalled = true
  }

  private(set) var showServerMaintenanceErrorCalled = false
  func showServerMaintenanceError() {
    showServerMaintenanceErrorCalled = true
  }

  private(set) var showMessageCalled = false
  private(set) var lastMessageShown: String?
  func showMessage(_ errorMessage: String) {
    showMessageCalled = true
    lastMessageShown = errorMessage
  }

  private(set) var showLoadingSpinnerCalled = false
  func showLoadingSpinner() {
    showLoadingSpinnerCalled = true
  }

  private(set) var hideLoadingSpinnerCalled = false
  func hideLoadingSpinner() {
    hideLoadingSpinnerCalled = true
  }

  var navigationController: UINavigationController?

  private(set) var askPermissionToOpenExternalUrlCalled = false
  private(set) var lastAskPermissionToOpenExternalUrlCompletion: (Result<Bool, NSError>.Callback)?
  func askPermissionToOpenExternalUrl(_ completion: @escaping Result<Bool, NSError>.Callback) {
    askPermissionToOpenExternalUrlCalled = true
    lastAskPermissionToOpenExternalUrlCompletion = completion
  }
}
