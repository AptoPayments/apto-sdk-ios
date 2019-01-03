//
//  UIModuleSpy.swift
//  ShiftSDK
//
// Created by Takeichi Kanzaki on 17/10/2018.
//
//

@testable import ShiftSDK

class UIModuleSpy: UIModule {
  private(set) var initializeCalled = false
  private(set) var lastInitializeCompletion: Result<UIViewController, NSError>.Callback?
  override func initialize(completion: @escaping Result<UIViewController, NSError>.Callback) {
    initializeCalled = true
    lastInitializeCompletion = completion
  }

  private(set) var closeCalled = false
  override func close() {
    closeCalled = true
    super.close()
  }

  private(set) var backCalled = false
  override func back() {
    backCalled = true
    super.back()
  }

  private(set) var nextCalled = false
  override func next() {
    nextCalled = true
    super.next()
  }

  private(set) var pushViewControllerCalled = false
  private(set) var lastViewControllerPushed: UIViewController?
  private(set) var lastViewControllerPushedAnimated: Bool?
  private(set) var lastViewControllerPushedLeftButtonMode: UIViewControllerLeftButtonMode?
  private(set) var lastViewControllerPushedCompletion: (() -> Void)?
  override func push(viewController: UIViewController,
                     animated: Bool,
                     leftButtonMode: UIViewControllerLeftButtonMode,
                     completion: @escaping (() -> Void)) {
    pushViewControllerCalled = true
    lastViewControllerPushed = viewController
    lastViewControllerPushedAnimated = animated
    lastViewControllerPushedLeftButtonMode = leftButtonMode
    lastViewControllerPushedCompletion = completion
  }

  private(set) var popViewControllerCalled = false
  private(set) var lastViewControllerPoppedAnimated: Bool?
  private(set) var lastViewControllerPoppedCompletion: (() -> Void)?
  override func popViewController(animated: Bool,
                                  completion: @escaping (() -> Void)) {
    popViewControllerCalled = true
    lastViewControllerPoppedAnimated = animated
    lastViewControllerPoppedCompletion = completion
  }

  private(set) var presentViewControllerCalled = false
  private(set) var lastViewControllerPresented: UIViewController?
  private(set) var lastViewControllerPresentedAnimated: Bool?
  private(set) var lastViewControllerPresentedCompletion: (() -> Void)?
  override func present(viewController: UIViewController,
                        animated: Bool,
                        completion: @escaping (() -> Void)) {
    presentViewControllerCalled = true
    lastViewControllerPresented = viewController
    lastViewControllerPresentedAnimated = animated
    lastViewControllerPresentedCompletion = completion
  }

  private(set) var pushModuleCalled = false
  private(set) var lastModulePushed: UIModuleProtocol?
  private(set) var lastModulePushedAnimated: Bool?
  private(set) var lastModulePushedLeftButtonMode: UIViewControllerLeftButtonMode?
  private(set) var lastModulePushedCompletion: Result<UIViewController, NSError>.Callback?
  override func push(module: UIModuleProtocol,
                     animated: Bool,
                     leftButtonMode: UIViewControllerLeftButtonMode,
                     completion: @escaping Result<UIViewController, NSError>.Callback) {
    pushModuleCalled = true
    lastModulePushed = module
    lastModulePushedAnimated = animated
    lastModulePushedLeftButtonMode = leftButtonMode
    lastModulePushedCompletion = completion
  }

  private(set) var popModuleCalled = false
  private(set) var lastModulePoppedAnimated: Bool?
  private(set) var lastModulePoppedCompletion: (() -> Void)?
  override func popModule(animated: Bool,
                          completion: @escaping (() -> Void)) {
    popModuleCalled = true
    lastModulePoppedAnimated = animated
    lastModulePoppedCompletion = completion
  }

  private(set) var removeModuleCalled = false
  private(set) var lastModuleRemoved: UIModuleProtocol?
  private(set) var lastModuleRemovedCompletion: (() -> Void)?
  override func remove(module: UIModuleProtocol, completion: @escaping (() -> Void)) {
    removeModuleCalled = true
    lastModuleRemoved = module
    lastModuleRemovedCompletion = completion
  }

  private(set) var presentModuleCalled = false
  private(set) var lastModulePresented: UIModuleProtocol?
  private(set) var lastModulePresentedAnimated: Bool?
  private(set) var lastModulePresentedLeftButtonMode: UIViewControllerLeftButtonMode?
  private(set) var lastModulePresentedEmbedInNavigationController: Bool?
  private(set) var lastModulePresentedCompletion: Result<UIViewController, NSError>.Callback?
  override func present(module: UIModuleProtocol,
                        animated: Bool,
                        leftButtonMode: UIViewControllerLeftButtonMode,
                        embedInNavigationController: Bool = true,
                        completion: @escaping Result<UIViewController, NSError>.Callback) {
    presentModuleCalled = true
    lastModulePresented = module
    lastModulePresentedAnimated = animated
    lastModulePresentedLeftButtonMode = leftButtonMode
    lastModulePresentedEmbedInNavigationController = embedInNavigationController
    lastModulePresentedCompletion = completion
  }

  private(set) var dismissViewControllerCalled = false
  private(set) var lastViewControllerDismissedAnimated: Bool?
  private(set) var lastViewControllerDismissedCompletion: (() -> Void)?
  override func dismissViewController(animated: Bool, completion: @escaping (() -> Void)) {
    dismissViewControllerCalled = true
    lastViewControllerDismissedAnimated = animated
    lastViewControllerDismissedCompletion = completion
  }

  private(set) var dismissModuleCalled = false
  private(set) var lastModuleDismissedAnimated: Bool?
  private(set) var lastModuleDismissedCompletion: (() -> Void)?
  override func dismissModule(animated: Bool, completion: @escaping (() -> Void)) {
    dismissModuleCalled = true
    lastModuleDismissedAnimated = animated
    lastModuleDismissedCompletion = completion
  }

  private(set) var addChildModuleCalled = false
  private(set) var lastChildModuleAdded: UIModuleProtocol?
  private(set) var lastChildModuleLeftButtonMode: UIViewControllerLeftButtonMode?
  private(set) var lastChildModuleAddedCompletion: Result<UIViewController, NSError>.Callback?
  override func addChild(module: UIModuleProtocol,
                         leftButtonMode: UIViewControllerLeftButtonMode,
                         completion: @escaping Result<UIViewController, NSError>.Callback) {
    addChildModuleCalled = true
    lastChildModuleAdded = module
    lastChildModuleLeftButtonMode = leftButtonMode
    lastChildModuleAddedCompletion = completion
  }

  private(set) var addChildViewControllerCalled = false
  private(set) var lastChildViewControllerAdded: UIViewController?
  private(set) var lastChildViewControllerLeftButtonMode: UIViewControllerLeftButtonMode?
  private(set) var lastChildViewControllerCompletion: Result<UIViewController, NSError>.Callback?
  override func addChild(viewController: UIViewController,
                         leftButtonMode: UIViewControllerLeftButtonMode,
                         completion: @escaping Result<UIViewController, NSError>.Callback) {
    addChildViewControllerCalled = true
    lastChildViewControllerAdded = viewController
    lastChildViewControllerLeftButtonMode = leftButtonMode
    lastChildViewControllerCompletion = completion
  }

  private(set) var showLoadingSpinnerCalled = false
  private(set) var loadingSpinnerPosition: SubviewPosition?
  override func showLoadingSpinner(position: SubviewPosition = .center) {
    showLoadingSpinnerCalled = true
    loadingSpinnerPosition = position
  }

  private(set) var hidLoadingSpinnerCalled = false
  override func hideLoadingSpinner() {
    hidLoadingSpinnerCalled = true
  }

  private(set) var showErrorCalled = false
  private(set) var lastErrorShown: Error?
  override func show(error: Error) {
    showErrorCalled = true
    lastErrorShown = error
  }

  private(set) var showMessageCalled = false
  private(set) var lastMessageShown: String?
  private(set) var lastMessageTitleShown: String?
  private(set) var lastMessageShownIsError: Bool?
  override func show(message: String, title: String, isError: Bool) {
    showMessageCalled = true
    lastMessageShown = message
    lastMessageTitleShown = title
    lastMessageShownIsError = isError
  }
}
