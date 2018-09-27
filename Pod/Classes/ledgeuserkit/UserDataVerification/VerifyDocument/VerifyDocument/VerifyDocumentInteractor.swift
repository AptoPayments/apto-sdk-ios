//
//  VerifyDocumentInteractor.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 22/03/2018.
//
//

import Foundation

protocol VerifyDocumentDataReceiver {
  func startingVerification()
  func verificationReceived(_ verification: Verification)
  func verificationSucceeded(_ verification: Verification)
  func verificationFailed(_ error: Error?)
}

class VerifyDocumentInteractor: VerifyDocumentInteractorProtocol {
  let dataReceiver: VerifyDocumentDataReceiver
  let documentImages: [UIImage]
  let selfie: UIImage?
  let livenessData: [String: AnyObject]?
  let workflowObject: WorkflowObject?
  let session: ShiftSession
  var verification: Verification?
  let checkVerificationStatusInterval: Double = 2.0 // In seconds

  init(session: ShiftSession,
       documentImages: [UIImage],
       selfie: UIImage?,
       livenessData: [String: AnyObject]?,
       workflowObject: WorkflowObject?,
       dataReceiver: VerifyDocumentDataReceiver) {
    self.session = session
    self.dataReceiver = dataReceiver
    self.documentImages = documentImages
    self.selfie = selfie
    self.livenessData = livenessData
    self.workflowObject = workflowObject
  }

  func startVerification() {
    dataReceiver.startingVerification()
    self.session.startDocumentVerification(documentImages,
                                           selfie: selfie,
                                           livenessData: livenessData,
                                           associatedTo: workflowObject) { result in
      switch result {
      case .failure(let error):
        self.dataReceiver.verificationFailed(error)
      case .success(let verification):
        self.verification = verification
        self.dataReceiver.verificationReceived(verification)
        // Check for the verification status periodically
        let delayTime = DispatchTime.now() + Double(Int64(6 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
          self.checkVerificationStatus()
        }
      }
    }
  }

  @objc func checkVerificationStatus() {
    guard let verification = self.verification else {
      return
    }
    self.session.documentVerificationStatus(verification) { result in
      switch result {
      case .failure (let error):
        self.dataReceiver.verificationFailed(error)
      case .success(let verification):
        guard verification.status != .pending else {
          let delay = Double(Int64(self.checkVerificationStatusInterval * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
          let delayTime = DispatchTime.now() + delay
          DispatchQueue.main.asyncAfter(deadline: delayTime) {
            self.checkVerificationStatus()
          }
          return
        }
        guard let userData = verification.documentVerificationResult?.userData else {
          self.dataReceiver.verificationSucceeded(verification)
          return
        }
        self.session.updateUserData(userData) { _ in
          self.dataReceiver.verificationSucceeded(verification)
        }
      }
    }
  }

}
