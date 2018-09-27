//
//  DataCollectorInteractor.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 01/02/16.
//
//

import Foundation
import Bond

protocol UserDataCollectorDataReceiver: class {
  func setDataCollectorError(_ error: NSError)
  func showNextStep()
  func showLoadingSpinner()
  func hideLoadingSpinner()
  func set(_ userData: DataPointList,
           missingData: RequiredDataPointList,
           requiredData: RequiredDataPointList,
           skipSteps: Bool,
           mode: UserDataCollectorFinalStepMode,
           availableHousingTypes: [HousingType],
           availableSalaryFrequencies: [SalaryFrequency],
           availableIncomeTypes: [IncomeType],
           availableTimeAtAddressOptions: [TimeAtAddressOption],
           availableCreditScoreOptions: [CreditScoreOption],
           disclaimers: [Content],
           primaryCredentialType: DataPointType,
           secondaryCredentialType: DataPointType,
           googleGeocodingAPIKey: String?)
  func set(maxMonthlyNetIncome: Int)
  func show(error: NSError)
  func userReady(_ user: ShiftUser)
}

class UserDataCollectorInteractor: UserDataCollectorInteractorProtocol {
  private let session: ShiftSession
  private let initialUserData: DataPointList
  private let internalUserData: DataPointList
  private unowned let dataReceiver: UserDataCollectorDataReceiver
  private let config: UserDataCollectorConfig
  private var verifyingSecondaryCredential = false

  init(session: ShiftSession,
       initialUserData: DataPointList,
       config: UserDataCollectorConfig,
       dataReceiver: UserDataCollectorDataReceiver) {
    self.session = session
    self.initialUserData = initialUserData
    self.internalUserData = initialUserData.copy() as! DataPointList // swiftlint:disable:this force_cast
    self.dataReceiver = dataReceiver
    self.config = config
    if let incomeDataPoint = internalUserData.getForcingDataPointOf(type: .income, defaultValue: Income()) as? Income {
      _ = incomeDataPoint.grossAnnualIncome.observeNext { [weak self] income in
        guard let income = income else {
          self?.dataReceiver.set(maxMonthlyNetIncome: 0)
          return
        }
        self?.dataReceiver.set(maxMonthlyNetIncome: income / 12)
      }
    }
  }

  func provideDataCollectorData() {
    // Remove primary credential from the list of user required datapoints
    let requiredData = config.userRequiredData.copy() as! RequiredDataPointList // swiftlint:disable:this force_cast
    requiredData.removeDataPointsOf(type: config.primaryAuthCredential)
    let missingData = requiredData.getMissingDataPoints(internalUserData)

    self.dataReceiver.set(internalUserData,
                          missingData: missingData,
                          requiredData: requiredData,
                          skipSteps: config.skipSteps,
                          mode: config.mode,
                          availableHousingTypes: config.housingTypes,
                          availableSalaryFrequencies: config.salaryFrequencies,
                          availableIncomeTypes: config.incomeTypes,
                          availableTimeAtAddressOptions: config.timeAtAddressOptions,
                          availableCreditScoreOptions: config.availableCreditScoreOptions,
                          disclaimers: config.disclaimers,
                          primaryCredentialType: config.primaryAuthCredential,
                          secondaryCredentialType: config.secondaryAuthCredential,
                          googleGeocodingAPIKey: config.googleGeocodingAPIKey)
  }

  // User data collection

  func allUserDataCollected(_ userData: DataPointList, callback: @escaping Result<ShiftUser, NSError>.Callback) {
    if self.shouldCreateUserAccount() {
      dataReceiver.showLoadingSpinner()
      self.createUser(userData) { result in
        switch result {
        case .failure(let error):
          self.dataReceiver.show(error: error)
        case .success(let newUser):
          self.dataReceiver.hideLoadingSpinner()
          callback(.success(newUser))
        }
      }
    }
    else {
      let differences = initialUserData.modifiedDataPoints(compareWith: userData)
      if !differences.dataPoints.isEmpty {
        dataReceiver.showLoadingSpinner()
        self.updateUser(differences) { result in
          switch result {
          case .failure(let error):
            self.dataReceiver.show(error: error)
          case .success(let updatedUser):
            self.dataReceiver.hideLoadingSpinner()
            callback(.success(updatedUser))
          }
        }
      }
      else {
        self.getCurrentUser(callback)
      }
    }
  }
}

// Navigation Handling

extension UserDataCollectorInteractor {
  func nextStepTapped(fromStep: DataCollectorStep) {
    self.dataReceiver.showNextStep()
  }
}

// User creation, account recovery, update user and get user data

extension UserDataCollectorInteractor {
  fileprivate func shouldCreateUserAccount() -> Bool {
    if session.currentUserToken() != nil {
      return false
    }
    if let primaryCredentialDatapoint = internalUserData.getDataPointsOf(type: config.primaryAuthCredential)?.first,
       let primaryCredentialDatapointVerification = primaryCredentialDatapoint.verification {
      guard let secondaryCredential = internalUserData.getDataPointsOf(type: config.secondaryAuthCredential)?.first,
            secondaryCredential.complete() else {
        return false
      }
      return primaryCredentialDatapointVerification.status == .passed
    }
    else {
      return false
    }
  }

  fileprivate func createUser(_ userData: DataPointList, callback: @escaping Result<ShiftUser, NSError>.Callback) {
    self.session.createUser (userData.filterNonCompletedDataPoints()) { result in
      switch result {
      case .failure(let error):
        callback(.failure(error))
      case .success(let user):
        callback(.success(user))
      }
    }
  }

  fileprivate func updateUser(_ userData: DataPointList, callback: @escaping Result<ShiftUser, NSError>.Callback) {
    self.session.updateUserData (userData.filterNonCompletedDataPoints()) { result in
      switch result {
      case .failure(let error):
        callback(.failure(error))
      case .success (let user):
        callback(.success(user))
      }
    }
  }

  fileprivate func getCurrentUser(_ callback: @escaping Result<ShiftUser, NSError>.Callback) {
    self.session.currentUser(callback: callback)
  }
}
