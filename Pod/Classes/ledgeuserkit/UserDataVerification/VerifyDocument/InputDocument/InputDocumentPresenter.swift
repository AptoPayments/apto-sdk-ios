//
//  VerifyDocumentPresenter.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 22/03 /2018.
//
//

import Bond

protocol InputDocumentRouterProtocol: class {
  func closeTappedInInputDocument()
  func backTappedInInputDocument()
  func willShowFirstViewController()
  func inputDocumentViewControllerDocumentsSelected(documentImages: [UIImage], selfie: UIImage?)
}

public enum InputDocumentState {
  case loading
  case captureFrontPhoto
  case checkFrontPhoto(UIImage)
  case captureBackPhoto
  case checkBackPhoto(UIImage)
  case captureSelfie
  case checkSelfie(UIImage)
}

open class InputDocumentViewModel {
  open var state: Observable<InputDocumentState> = Observable(.loading)
  open var screenTitle: Observable<String?> = Observable(nil)
  open var frameNote: Observable<String?> = Observable(nil)
  open var actionTitle: Observable<String?> = Observable(nil)
  open var actionDescription: Observable<String?> = Observable(nil)
  open var okButtonTitle: Observable<String?> = Observable(nil)
  open var retakeButtonTitle: Observable<String?> = Observable(nil)
  open var canSkip: Observable<Bool> = Observable(false)
}

class InputDocumentPresenter: InputDocumentEventHandler {
  weak var router: InputDocumentRouterProtocol! // swiftlint:disable:this implicitly_unwrapped_optional
  var viewModel: InputDocumentViewModel
  var images: [UIImage] = []
  var selfie: UIImage?

  init() {
    self.viewModel = InputDocumentViewModel()
  }

  func viewLoaded() {
    showCaptureFrontDocument()
  }

  func viewWillAppear() {
    router.willShowFirstViewController()
  }

  public func retakePictures() {
    self.showCaptureFrontDocument()
  }

  public func retakeSelfie() {
    self.showCaptureSelfie()
  }

  func skipTapped() {
    showCaptureSelfie()
  }

  func imageFound(image: UIImage) {
    switch viewModel.state.value {
    case .captureFrontPhoto:
      showCheckFrontDocument(image: image)
    case .captureBackPhoto:
      showCheckBackDocument(image: image)
    case .captureSelfie:
      showCheckSelfieDocument(image: image)
    default:
      break
    }
  }

  func imageChecked(image: UIImage) {
    switch viewModel.state.value {
    case .checkFrontPhoto(let image):
      images.append(image)
      showCaptureBackDocument()
    case .checkBackPhoto(let image):
      images.append(image)
      showCaptureSelfie()
    case .checkSelfie(let image):
      selfie = image
      // All the document images captured. Continue
      router.inputDocumentViewControllerDocumentsSelected(documentImages: images, selfie: selfie)
    default:
      break
    }
  }

  func retakeTapped() {
    switch viewModel.state.value {
    case .checkFrontPhoto:
      showCaptureFrontDocument()
    case .checkBackPhoto:
      showCaptureBackDocument()
    case .checkSelfie:
      showCaptureSelfie()
    default:
      break
    }
  }

  func closeTapped() {
    router.closeTappedInInputDocument()
  }

  func previousTapped() {
    switch viewModel.state.value {
    case .checkFrontPhoto, .captureBackPhoto:
      showCaptureFrontDocument()
    case .checkBackPhoto, .captureSelfie:
      showCaptureBackDocument()
    case .checkSelfie:
      showCaptureSelfie()
    default:
      router.backTappedInInputDocument()
    }
  }

  fileprivate func showCaptureFrontDocument() {
    self.images = []
    configureTexts(screenTitle: "verify-document.title.id-document-authentication".podLocalized(),
                   frameNote: "verify-document.frame-note".podLocalized(),
                   actionTitle: "verify-document.action.front-card.title".podLocalized(),
                   actionDescription: "verify-document.action.front-card.description".podLocalized(),
                   okButtonTitle: "verify-document.ok-button.title".podLocalized(),
                   retakeButtonTitle: "verify-document.retake-button.title".podLocalized())
    viewModel.state.next(.captureFrontPhoto)
    viewModel.canSkip.next(false)
  }

  fileprivate func showCaptureBackDocument() {
    self.images = [self.images.first!] // swiftlint:disable:this force_unwrapping
    configureTexts(screenTitle: "verify-document.title.id-document-authentication".podLocalized(),
                   frameNote: "verify-document.frame-note".podLocalized(),
                   actionTitle: "verify-document.action.back-card.title".podLocalized(),
                   actionDescription: "verify-document.action.back-card.description".podLocalized(),
                   okButtonTitle: "verify-document.ok-button.title".podLocalized(),
                   retakeButtonTitle: "verify-document.retake-button.title".podLocalized())
    viewModel.state.next(.captureBackPhoto)
    viewModel.canSkip.next(true)
  }

  fileprivate func showCaptureSelfie() {
    self.selfie = nil
    configureTexts(screenTitle: "verify-document.title.selfie".podLocalized(),
                   frameNote: nil,
                   actionTitle: nil,
                   actionDescription: "verify-document.action.selfie.description".podLocalized(),
                   okButtonTitle: "verify-document.ok-button-selfie.title".podLocalized(),
                   retakeButtonTitle: "verify-document.retake-button.title".podLocalized())
    viewModel.state.next(.captureSelfie)
    viewModel.canSkip.next(false)
  }

  fileprivate func showCheckFrontDocument(image: UIImage) {
    configureTexts(screenTitle: "verify-document.title.id-document-authentication".podLocalized(),
                   frameNote: nil,
                   actionTitle: "verify-document.action.check-readability.title".podLocalized(),
                   actionDescription: "verify-document.action.check-readability.description".podLocalized(),
                   okButtonTitle: "verify-document.ok-button.title".podLocalized(),
                   retakeButtonTitle: "verify-document.retake-button.title".podLocalized())
    viewModel.state.next(.checkFrontPhoto(image))
  }

  fileprivate func showCheckBackDocument(image: UIImage) {
    configureTexts(screenTitle: "verify-document.title.id-document-authentication".podLocalized(),
                   frameNote: nil,
                   actionTitle: "verify-document.action.check-readability.title".podLocalized(),
                   actionDescription: "verify-document.action.check-readability.description".podLocalized(),
                   okButtonTitle: "verify-document.ok-button.title".podLocalized(),
                   retakeButtonTitle: "verify-document.retake-button.title".podLocalized())
    viewModel.state.next(.checkBackPhoto(image))
  }

  fileprivate func showCheckSelfieDocument(image: UIImage) {
    configureTexts(screenTitle: "verify-document.title.selfie".podLocalized(),
                   frameNote: nil,
                   actionTitle: nil,
                   actionDescription: nil,
                   okButtonTitle: "verify-document.ok-button-selfie.title".podLocalized(),
                   retakeButtonTitle: "verify-document.retake-button.title".podLocalized())
    viewModel.state.next(.checkSelfie(image))
  }

  fileprivate func configureTexts(screenTitle: String?,
                                  frameNote: String?,
                                  actionTitle: String?,
                                  actionDescription: String?,
                                  okButtonTitle: String?,
                                  retakeButtonTitle: String?) {
    viewModel.frameNote.next(frameNote)
    viewModel.screenTitle.next(screenTitle)
    viewModel.actionTitle.next(actionTitle)
    viewModel.actionDescription.next(actionDescription)
    viewModel.okButtonTitle.next(okButtonTitle)
    viewModel.retakeButtonTitle.next(retakeButtonTitle)
  }
}
