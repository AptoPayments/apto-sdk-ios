//
//  VerifyDocumentPresenter.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 22/03 /2018.
//
//

import Bond

protocol VerifyDocumentInteractorProtocol {
  func startVerification()
  func checkVerificationStatus()
}

public enum VerifyDocumentState {
  case processing
  case success
  case error(String?)
  case selfieDoNotMatch(String)
}

open class VerifyDocumentViewModel {
  open var state: Observable<VerifyDocumentState> = Observable(.processing)
}

class VerifyDocumentPresenter: VerifyDocumentEventHandler, VerifyDocumentDataReceiver {

  var interactor: VerifyDocumentInteractorProtocol!
  var router: VerifyDocumentRouterProtocol!
  var viewModel: VerifyDocumentViewModel
  var verification: Verification?
  
  init() {
    self.viewModel = VerifyDocumentViewModel()
  }
  
  func viewLoaded() {
    self.interactor.startVerification()
  }
  
  func closeTapped() {
    router.closeTappedInVerifyDocument()
  }
  
  func startingVerification() {
    viewModel.state.next(.processing)
  }
  
  func verificationFailed(_ error: Error?) {
    viewModel.state.next(.error("verify_document.explanation.error".podLocalized()))
  }
  
  func verificationReceived(_ verification:Verification) {
    viewModel.state.next(.processing)
  }
  
  func verificationSucceeded(_ verification:Verification) {
    self.verification = verification
    guard let documentVerificationResult = verification.documentVerificationResult, documentVerificationResult.docCompletionStatus == .ok else {
      viewModel.state.next(.error("Can't verify Document"))
      return
    }
    guard documentVerificationResult.docAuthenticity == .authentic else {
      viewModel.state.next(.error("Invalid Document: \(documentVerificationResult.docAuthenticity.description())"))
      return
    }
    guard documentVerificationResult.faceComparisonResult == .faceMatch else {
      viewModel.state.next(.selfieDoNotMatch(documentVerificationResult.faceComparisonResult.description()))
      return
    }
    viewModel.state.next(.success)
  }
  
  func continueTapped() {
    if let verification = verification {
      router.nextTappedInVerifyDocumentWith(verification: verification)
    }
  }
  
  func retakePicturesTapped() {
    router.retakePicturesTappedInVerifyDocument()
  }
  
  func retakeSelfieTapped() {
    router.retakeSelfieTappedInVerifyDocument()
  }
  
}
