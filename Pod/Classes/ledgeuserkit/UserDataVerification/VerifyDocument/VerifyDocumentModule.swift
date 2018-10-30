//
//  VerifyDocumentModule.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 22/03/2018.
//
//

import UIKit

protocol VerifyDocumentRouterProtocol {
  func closeTappedInVerifyDocument()
  func nextTappedInVerifyDocumentWith(verification: Verification)
  func retakePicturesTappedInVerifyDocument()
  func retakeSelfieTappedInVerifyDocument()
}

class VerifyDocumentModule: UIModule {
  private var inputDocumentPresenter: InputDocumentPresenter?
  private let workflowObject: WorkflowObject?

  init(serviceLocator: ServiceLocatorProtocol, workflowObject: WorkflowObject?) {
    self.workflowObject = workflowObject

    super.init(serviceLocator: serviceLocator)
  }

  open var onVerificationPassed: ((_ verifyDocumenteModule: VerifyDocumentModule,
                                   _ verificationResult: DocumentVerificationResult) -> Void)?

  override func initialize(completion: @escaping Result<UIViewController, NSError>.Callback) {
    let presenter = InputDocumentPresenter()
    let viewController = InputDocumentViewController(uiConfiguration: uiConfig, eventHandler: presenter)
    presenter.router = self
    inputDocumentPresenter = presenter
    addChild(viewController: viewController, completion: completion)
  }

  fileprivate func showVerifyDocumentViewController(documentImages: [UIImage],
                                                    selfie: UIImage?,
                                                    livenessData: [String: AnyObject]?,
                                                    completion: @escaping Result<Void, NSError>.Callback) {
    let presenter = VerifyDocumentPresenter()
    // swiftlint:disable:next force_unwrapping
    let viewController = VerifyDocumentViewController(uiConfiguration: uiConfig, eventHandler: presenter)
    let interactor = VerifyDocumentInteractor(session: shiftSession,
                                              documentImages: documentImages,
                                              selfie: selfie,
                                              livenessData: livenessData,
                                              workflowObject: workflowObject,
                                              dataReceiver: presenter)
    presenter.router = self
    presenter.interactor = interactor
    self.push(viewController: viewController) {}
  }
}

extension VerifyDocumentModule: InputDocumentRouterProtocol {
  func closeTappedInInputDocument() {
    close()
  }

  func backTappedInInputDocument() {
    back()
  }

  func willShowFirstViewController() {
    self.makeNavigationBarTransparent()
  }

  func inputDocumentViewControllerDocumentsSelected(documentImages: [UIImage], selfie: UIImage?) {
    self.showVerifyDocumentViewController(documentImages: documentImages, selfie: selfie, livenessData: nil) { _ in }
  }
}

extension VerifyDocumentModule: VerifyDocumentRouterProtocol {
  func closeTappedInVerifyDocument() {
    self.restoreNavigationBarFromTransparentState()
    close()
  }

  func retakePicturesTappedInVerifyDocument() {
    guard let presenter = inputDocumentPresenter else {
      return
    }
    presenter.retakePictures()
    self.popViewController {}
  }

  func retakeSelfieTappedInVerifyDocument() {
    guard let presenter = inputDocumentPresenter else {
      return
    }
    presenter.retakeSelfie()
    self.popViewController {}
  }

  func nextTappedInVerifyDocumentWith(verification: Verification) {
    self.restoreNavigationBarFromTransparentState()
    onVerificationPassed?(self, verification.documentVerificationResult!) // swiftlint:disable:this force_unwrapping
    onFinish?(self)
  }
}
