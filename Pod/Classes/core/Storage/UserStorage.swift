//
//  UserStorage.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 10/02/16.
//
//

import Foundation
import SwiftyJSON

protocol UserStorageProtocol {
  func createUser(_ apiKey: String, userData: DataPointList, custodianUid: String?,
                  callback: @escaping Result<ShiftUser, NSError>.Callback)
  func loginWith(_ apiKey: String,
                 verifications: [Verification],
                 callback: @escaping Result<ShiftUser, NSError>.Callback)
  func getUserData(_ apiKey: String,
                   userToken: String,
                   availableHousingTypes: [HousingType],
                   availableIncomeTypes: [IncomeType],
                   availableSalaryFrequencies: [SalaryFrequency],
                   filterInvalidTokenResult: Bool,
                   callback: @escaping Result<ShiftUser, NSError>.Callback)
  func updateUserData(_ apiKey: String,
                      userToken: String,
                      userData: DataPointList,
                      callback: @escaping Result<ShiftUser, NSError>.Callback)
  func startPhoneVerification(_ apiKey: String,
                              phone: PhoneNumber,
                              callback: @escaping Result<Verification, NSError>.Callback)
  func startEmailVerification(_ apiKey: String,
                              email: Email,
                              callback: @escaping Result<Verification, NSError>.Callback)
  func startBirthDateVerification(_ apiKey: String,
                                  birthDate: BirthDate,
                                  callback: @escaping Result<Verification, NSError>.Callback)
  func startDocumentVerification(_ apiKey: String,
                                 userToken: String,
                                 documentImages: [UIImage],
                                 selfie: UIImage?,
                                 livenessData: [String: AnyObject]?,
                                 associatedTo workflowObject: WorkflowObject?,
                                 callback: @escaping Result<Verification, NSError>.Callback)
  func documentVerificationStatus(_ apiKey: String,
                                  verificationId: String,
                                  callback: @escaping Result<Verification, NSError>.Callback)
  func completeVerification(_ apiKey: String,
                            verificationId: String,
                            secret: String?,
                            callback: @escaping Result<Verification, NSError>.Callback)
  func verificationStatus(_ apiKey: String,
                          verificationId: String,
                          callback: @escaping Result<Verification, NSError>.Callback)
  func restartVerification(_ apiKey: String,
                           verificationId: String,
                           callback: @escaping Result<Verification, NSError>.Callback)
  func saveOauthData(_ apiKey: String,
                     userToken: String,
                     userData: DataPointList,
                     custodian: Custodian,
                     callback: @escaping Result<OAuthSaveUserDataResult, NSError>.Callback)
  func fetchOauthData(_ apiKey: String,
                      custodian: Custodian,
                      callback: @escaping Result<OAuthUserData, NSError>.Callback)
}

class UserStorage: UserStorageProtocol {
  private let transport: JSONTransport

  init(transport: JSONTransport) {
    self.transport = transport
  }

  func createUser(_ apiKey: String, userData: DataPointList, custodianUid: String?,
                  callback: @escaping Result<ShiftUser, NSError>.Callback) {
    let url = URLWrapper(baseUrl: self.transport.environment.baseUrl(), url: JSONRouter.createUser)
    let auth = JSONTransportAuthorization.accessToken(projectToken: apiKey)
    var data: [String: AnyObject] = ["data_points": userData.jsonSerialize() as AnyObject]
    if let custodianUid = custodianUid {
      data["custodian_uid"] = custodianUid as AnyObject
    }
    self.transport.post(url, authorization: auth, parameters: data, filterInvalidTokenResult: true) { result in
      callback(result.flatMap { json -> Result<ShiftUser, NSError> in
        guard let user = json.user else {
          return .failure(ServiceError(code: .jsonError))
        }
        return .success(user)
      })
    }
  }

  func loginWith(_ apiKey: String,
                 verifications: [Verification],
                 callback: @escaping Result<ShiftUser, NSError>.Callback) {
    guard let firstVerification = verifications.first, let secondVerification = verifications.last else {
      callback(.failure(BackendError(code: .incorrectParameters, reason: nil)))
      return
    }
    let url = URLWrapper(baseUrl: self.transport.environment.baseUrl(), url: JSONRouter.login)
    let auth = JSONTransportAuthorization.accessToken(projectToken: apiKey)
    let verificationsArray = [
      firstVerification.jsonSerialize(),
      secondVerification.jsonSerialize()
    ]
    let verificationsDictionary = [
      "data": verificationsArray
    ]
    let data: [String: AnyObject] = ["verifications": verificationsDictionary as AnyObject]
    self.transport.post(url, authorization: auth, parameters: data, filterInvalidTokenResult: true) { result in
      callback(result.flatMap { json -> Result<ShiftUser, NSError> in
        guard let user = json.user else {
          return .failure(ServiceError(code: .jsonError))
        }
        return .success(user)
      })
    }
  }

  func getUserData(_ apiKey: String,
                   userToken: String,
                   availableHousingTypes: [HousingType],
                   availableIncomeTypes: [IncomeType],
                   availableSalaryFrequencies: [SalaryFrequency],
                   filterInvalidTokenResult: Bool,
                   callback: @escaping Result<ShiftUser, NSError>.Callback) {
    let url = URLWrapper(baseUrl: self.transport.environment.baseUrl(), url: JSONRouter.userInfo)
    let auth = JSONTransportAuthorization.accessAndUserToken(projectToken: apiKey,
                                                             userToken: userToken)
    self.transport.get(url,
                       authorization: auth,
                       parameters: nil,
                       headers: nil,
                       acceptRedirectTo: nil,
                       filterInvalidTokenResult: filterInvalidTokenResult) { result in
      callback(result.flatMap { json -> Result<ShiftUser, NSError> in
        guard let user = json.user else {
          return .failure(ServiceError(code: .jsonError))
        }
        if let housingList = user.userData.getDataPointsOf(type: .housing) as? [Housing] {
          for housing in housingList {
            let originalHousing = availableHousingTypes.filter {
              $0.housingTypeId == housing.housingType.value!.housingTypeId // swiftlint:disable:this force_unwrapping
            }
            if let first = originalHousing.first {
              housing.housingType.send(first)
            }
          }
        }
        if let incomeSourceList = user.userData.getDataPointsOf(type: .incomeSource) as? [IncomeSource] {
          for incomeSource in incomeSourceList {
            let originalIncomeType = availableIncomeTypes.filter {
              $0.incomeTypeId == incomeSource.incomeType.value!.incomeTypeId // swiftlint:disable:this force_unwrapping
            }
            if let first = originalIncomeType.first {
              incomeSource.incomeType.send(first)
            }
            let originalSalaryFrequency = availableSalaryFrequencies.filter {
              // swiftlint:disable:next force_unwrapping
              $0.salaryFrequencyId == incomeSource.salaryFrequency.value!.salaryFrequencyId
            }
            if let first = originalSalaryFrequency.first {
              incomeSource.salaryFrequency.send(first)
            }
          }
        }
        return .success(user)
      })
    }
  }

  func updateUserData(_ apiKey: String,
                      userToken: String,
                      userData: DataPointList,
                      callback: @escaping Result<ShiftUser, NSError>.Callback) {
    let url = URLWrapper(baseUrl: self.transport.environment.baseUrl(), url: JSONRouter.updateUserInfo)
    let auth = JSONTransportAuthorization.accessAndUserToken(projectToken: apiKey,
                                                             userToken: userToken)
    let dataPointList = DataPointList()
    for dataPointBag in userData.dataPoints.values {
      for dataPoint in dataPointBag {
        dataPointList.add(dataPoint: dataPoint)
      }
    }
    if let ssnDataPoint = dataPointList.getDataPointsOf(type: .idDocument)?.first as? IdDocument {
      if let notSpecified = ssnDataPoint.notSpecified {
        if !notSpecified {
          if ssnDataPoint.value.value == SSNTextValidator.unknownValidSSN {
            dataPointList.removeDataPointsOf(type: .idDocument)
          }
        }
      }
      else {
        if ssnDataPoint.value.value == SSNTextValidator.unknownValidSSN {
          dataPointList.removeDataPointsOf(type: .idDocument)
        }
      }
    }
    let data: [String: AnyObject] = ["data_points": dataPointList.jsonSerialize() as AnyObject]
    self.transport.put(url, authorization: auth, parameters: data, filterInvalidTokenResult: true) { result in
      callback(result.flatMap { json -> Result<ShiftUser, NSError> in
        guard let user = json.user else {
          return .failure(ServiceError(code: .jsonError))
        }
        return .success(user)
      })
    }
  }

  func startPhoneVerification(_ apiKey: String,
                              phone: PhoneNumber,
                              callback: @escaping Result<Verification, NSError>.Callback) {
    let url = URLWrapper(baseUrl: self.transport.environment.baseUrl(), url: JSONRouter.verificationStart)
    let auth = JSONTransportAuthorization.accessToken(projectToken: apiKey)
    let data = [
      "datapoint_type": "phone" as AnyObject,
      "show_verification_secret": true as AnyObject,
      "datapoint": [
        "country_code": phone.countryCode.value as AnyObject,
        "phone_number": phone.phoneNumber.value as AnyObject
      ] as [String: AnyObject]
    ] as [String: AnyObject]
    self.transport.post(url, authorization: auth, parameters: data, filterInvalidTokenResult: true) { result in
      callback(result.flatMap { json -> Result<Verification, NSError> in
        guard let verification = json.verification else {
          return .failure(ServiceError(code: .jsonError))
        }
        AutomationStorage.verificationSecret = verification.secret
        return .success(verification)
      })
    }
  }

  func startEmailVerification(_ apiKey: String,
                              email: Email,
                              callback: @escaping Result<Verification, NSError>.Callback) {
    let url = URLWrapper(baseUrl: self.transport.environment.baseUrl(), url: JSONRouter.verificationStart)
    let auth = JSONTransportAuthorization.accessToken(projectToken: apiKey)
    let data = [
      "datapoint_type": "email" as AnyObject,
      "show_verification_secret": true as AnyObject,
      "datapoint": [
        "email": email.email.value as AnyObject
      ] as [String: AnyObject]
    ] as [String: AnyObject]
    self.transport.post(url, authorization: auth, parameters: data, filterInvalidTokenResult: true) { result in
      callback(result.flatMap { json -> Result<Verification, NSError> in
        guard let verification = json.verification else {
          return .failure(ServiceError(code: .jsonError))
        }
        AutomationStorage.verificationSecret = verification.secret
        return .success(verification)
      })
    }
  }

  func startBirthDateVerification(_ apiKey: String,
                                  birthDate: BirthDate,
                                  callback: @escaping Result<Verification, NSError>.Callback) {
    let url = URLWrapper(baseUrl: self.transport.environment.baseUrl(), url: JSONRouter.verificationStart)
    let auth = JSONTransportAuthorization.accessToken(projectToken: apiKey)
    let data = [
      "datapoint_type": "birthDate" as AnyObject,
      "show_verification_secret": true as AnyObject,
      "datapoint": [
        "date": birthDate.date.value?.formatForJSONAPI() as AnyObject? ?? NSNull()
      ] as [String: AnyObject]
    ] as [String: AnyObject]
    self.transport.post(url, authorization: auth, parameters: data, filterInvalidTokenResult: true) { result in
      callback(result.flatMap { json -> Result<Verification, NSError> in
        guard let verification = json.verification else {
          return .failure(ServiceError(code: .jsonError))
        }
        AutomationStorage.verificationSecret = verification.secret
        return .success(verification)
      })
    }
  }

  func startDocumentVerification(_ apiKey: String,
                                 userToken: String,
                                 documentImages: [UIImage],
                                 selfie: UIImage?,
                                 livenessData: [String: AnyObject]?,
                                 associatedTo workflowObject: WorkflowObject?,
                                 callback: @escaping Result<Verification, NSError>.Callback) {
    let url = URLWrapper(baseUrl: self.transport.environment.baseUrl(), url: JSONRouter.documentOCR)
    let auth = JSONTransportAuthorization.accessAndUserToken(projectToken: apiKey,
                                                             userToken: userToken)
    let imagesData = documentImages.map { image -> [String: String] in
      return ["image_array": image.toBase64()]
    }
    var selfieData: [String: String]? = nil
    if let selfie = selfie {
      selfieData = ["image_array": selfie.toBase64()]
    }
    var data = [
      "datapoint_type": "AU10TIX" as AnyObject,
      "datapoint": [
        "document_images": imagesData as AnyObject,
        "selfie": selfieData as AnyObject,
        "liveness_data": livenessData as AnyObject
      ] as [String: AnyObject]
    ] as [String: AnyObject]
    if let workflowId = workflowObject?.workflowObjectId {
      data["workflow_object_id"] = workflowId as AnyObject
    }
    self.transport.post(url, authorization: auth, parameters: data, filterInvalidTokenResult: true) { result in
      callback(result.flatMap { json -> Result<Verification, NSError> in
        guard let verification = json.verification else {
          return .failure(ServiceError(code: .jsonError))
        }
        AutomationStorage.verificationSecret = verification.secret
        return .success(verification)
      })
    }
  }

  func documentVerificationStatus(_ apiKey: String,
                                  verificationId: String,
                                  callback: @escaping Result<Verification, NSError>.Callback) {
    let url = URLWrapper(baseUrl: self.transport.environment.baseUrl(),
                         url: JSONRouter.documentOCRStatus,
                         urlParameters: [":verificationId": verificationId])
    let auth = JSONTransportAuthorization.accessToken(projectToken: apiKey)
    self.transport.get(url,
                       authorization: auth,
                       parameters: nil,
                       headers: nil,
                       acceptRedirectTo: nil,
                       filterInvalidTokenResult: true) { result in
      callback(result.flatMap { json -> Result<Verification, NSError> in
        guard let verification = json.verification else {
          return .failure(ServiceError(code: .jsonError))
        }
        return .success(verification)
      })
    }
  }

  func completeVerification(_ apiKey: String,
                            verificationId: String,
                            secret: String?,
                            callback: @escaping Result<Verification, NSError>.Callback) {
    let url = URLWrapper(baseUrl: self.transport.environment.baseUrl(),
                         url: JSONRouter.verificationFinish,
                         urlParameters: [":verificationId": verificationId])
    let auth = JSONTransportAuthorization.accessToken(projectToken: apiKey)
    let data = [
      "secret": secret as AnyObject
    ]
    self.transport.post(url, authorization: auth, parameters: data, filterInvalidTokenResult: true) { result in
      callback(result.flatMap { json -> Result<Verification, NSError> in
        guard let verification = json.verification else {
          return .failure(ServiceError(code: .jsonError))
        }
        return .success(verification)
      })
    }
  }

  func verificationStatus(_ apiKey: String,
                          verificationId: String,
                          callback: @escaping Result<Verification, NSError>.Callback) {
    let url = URLWrapper(baseUrl: self.transport.environment.baseUrl(),
                         url: JSONRouter.verificationStatus,
                         urlParameters: [":verificationId": verificationId])
    let auth = JSONTransportAuthorization.accessToken(projectToken: apiKey)
    self.transport.get(url,
                       authorization: auth,
                       parameters: nil,
                       headers: nil,
                       acceptRedirectTo: nil,
                       filterInvalidTokenResult: true) { result in
      callback(result.flatMap { json -> Result<Verification, NSError> in
        guard let verification = json.verification else {
          return .failure(ServiceError(code: .jsonError))
        }
        return .success(verification)
      })
    }
  }

  func restartVerification(_ apiKey: String,
                           verificationId: String,
                           callback: @escaping Result<Verification, NSError>.Callback) {
    let url = URLWrapper(baseUrl: self.transport.environment.baseUrl(),
                         url: JSONRouter.verificationRestart,
                         urlParameters: [":verificationId": verificationId])
    let auth = JSONTransportAuthorization.accessToken(projectToken: apiKey)
    let parameters = ["show_verification_secret": true as AnyObject]
    self.transport.post(url, authorization: auth, parameters: parameters, filterInvalidTokenResult: true) { result in
      callback(result.flatMap { json -> Result<Verification, NSError> in
        guard let verification = json.verification else {
          return .failure(ServiceError(code: .jsonError))
        }
        return .success(verification)
      })
    }
  }

  func saveOauthData(_ apiKey: String,
                     userToken: String,
                     userData: DataPointList,
                     custodian: Custodian,
                     callback: @escaping Result<OAuthSaveUserDataResult, NSError>.Callback) {
    guard let credentials = custodian.externalCredentials, case let .oauth(oauthCredentials) = credentials else {
      callback(.failure(BackendError(code: .incorrectParameters)))
      return
    }
    let url = URLWrapper(baseUrl: transport.environment.baseUrl(), url: .saveOauthUserData)
    let auth = JSONTransportAuthorization.accessAndUserToken(projectToken: apiKey, userToken: userToken)
    let parameters = [
      "data_points": userData.jsonSerialize() as AnyObject,
      "provider": custodian.custodianType.name().lowercased() as AnyObject,
      "oauth_token_id": oauthCredentials.oauthTokenId as AnyObject
    ]
    transport.post(url, authorization: auth, parameters: parameters, filterInvalidTokenResult: true) { result in
       callback(result.flatMap { json -> Result<OAuthSaveUserDataResult, NSError> in
         guard let saveUserResult = json.oauthSaveUserDataResult else {
           return .failure(ServiceError(code: .jsonError))
         }
         return .success(saveUserResult)
       })
    }
  }

  func fetchOauthData(_ apiKey: String,
                      custodian: Custodian,
                      callback: @escaping Result<OAuthUserData, NSError>.Callback) {
    guard let credentials = custodian.externalCredentials, case let .oauth(oauthCredentials) = credentials else {
      callback(.failure(BackendError(code: .incorrectParameters)))
      return
    }
    let url = URLWrapper(baseUrl: transport.environment.baseUrl(), url: .fetchOauthUserData)
    let auth = JSONTransportAuthorization.accessToken(projectToken: apiKey)
    let parameters = [
      "provider": custodian.custodianType.name().lowercased() as AnyObject,
      "oauth_token_id": oauthCredentials.oauthTokenId as AnyObject
    ]
    transport.post(url, authorization: auth, parameters: parameters, filterInvalidTokenResult: true) { result in
      callback(result.flatMap { json -> Result<OAuthUserData, NSError> in
        guard let oauthUserData = json.oauthUserData else {
          return .failure(ServiceError(code: .jsonError))
        }
        return .success(oauthUserData)
      })
    }
  }
}
