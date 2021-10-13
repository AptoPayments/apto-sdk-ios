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
  func createUser(_ apiKey: String, userData: DataPointList, custodianUid: String?, metadata: String?,
                  callback: @escaping Result<AptoUser, NSError>.Callback)
  func loginWith(_ apiKey: String,
                 verifications: [Verification],
                 callback: @escaping Result<AptoUser, NSError>.Callback)
  func getUserData(_ apiKey: String, userToken: String, filterInvalidTokenResult: Bool,
                   callback: @escaping Result<AptoUser, NSError>.Callback)
  func updateUserData(_ apiKey: String,
                      userToken: String,
                      userData: DataPointList,
                      callback: @escaping Result<AptoUser, NSError>.Callback)
  func startPhoneVerification(_ apiKey: String,
                              phone: PhoneNumber,
                              callback: @escaping Result<Verification, NSError>.Callback)
  func startEmailVerification(_ apiKey: String,
                              email: Email,
                              callback: @escaping Result<Verification, NSError>.Callback)
  func startBirthDateVerification(_ apiKey: String,
                                  birthDate: BirthDate,
                                  callback: @escaping Result<Verification, NSError>.Callback)
  func startPrimaryVerification(_ apiKey: String,
                                userToken: String,
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
  func fetchStatementsPeriod(_ apiKey: String, userToken: String,
                             callback: @escaping Result<MonthlyStatementsPeriod, NSError>.Callback)
  func fetchStatement(_ apiKey: String, userToken: String, month: Int, year: Int,
                      callback: @escaping Result<MonthlyStatementReport, NSError>.Callback)
}

class UserStorage: UserStorageProtocol { // swiftlint:disable:this type_body_length
  private let transport: JSONTransport

  init(transport: JSONTransport) {
    self.transport = transport
  }

  func createUser(_ apiKey: String, userData: DataPointList, custodianUid: String?, metadata: String?,
                  callback: @escaping Result<AptoUser, NSError>.Callback) {
    let url = URLWrapper(baseUrl: self.transport.environment.baseUrl(), url: JSONRouter.createUser)
    let auth = JSONTransportAuthorization.accessToken(projectToken: apiKey)
    var data: [String: AnyObject] = ["data_points": userData.jsonSerialize() as AnyObject]
    if let custodianUid = custodianUid {
      data["custodian_uid"] = custodianUid as AnyObject
    }
    if let metadata = metadata {
      data["metadata"] = metadata as AnyObject
    }
    self.transport.post(url, authorization: auth, parameters: data, filterInvalidTokenResult: true) { result in
      callback(result.flatMap { json -> Result<AptoUser, NSError> in
        guard let user = json.user else {
          return .failure(ServiceError(code: .jsonError))
        }
        return .success(user)
      })
    }
  }

  func loginWith(_ apiKey: String,
                 verifications: [Verification],
                 callback: @escaping Result<AptoUser, NSError>.Callback) {
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
      callback(result.flatMap { json -> Result<AptoUser, NSError> in
        guard let user = json.user else {
          return .failure(ServiceError(code: .jsonError))
        }
        return .success(user)
      })
    }
  }

  func getUserData(_ apiKey: String, userToken: String, filterInvalidTokenResult: Bool,
                   callback: @escaping Result<AptoUser, NSError>.Callback) {
    let url = URLWrapper(baseUrl: self.transport.environment.baseUrl(), url: JSONRouter.userInfo)
    let auth = JSONTransportAuthorization.accessAndUserToken(projectToken: apiKey,
                                                             userToken: userToken)
    self.transport.get(url,
                       authorization: auth,
                       parameters: nil,
                       headers: nil,
                       acceptRedirectTo: nil,
                       filterInvalidTokenResult: filterInvalidTokenResult) { result in
      callback(result.flatMap { json -> Result<AptoUser, NSError> in
        guard let user = json.user else {
          return .failure(ServiceError(code: .jsonError))
        }
        return .success(user)
      })
    }
  }

  func updateUserData(_ apiKey: String,
                      userToken: String,
                      userData: DataPointList,
                      callback: @escaping Result<AptoUser, NSError>.Callback) {
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
      callback(result.flatMap { json -> Result<AptoUser, NSError> in
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

  func startPrimaryVerification(_ apiKey: String,
                                userToken: String,
                                callback: @escaping Result<Verification, NSError>.Callback) {
    let url = URLWrapper(baseUrl: self.transport.environment.baseUrl(), url: JSONRouter.primaryVerificationStart)
    let auth = JSONTransportAuthorization.accessAndUserToken(projectToken: apiKey, userToken: userToken)
    self.transport.post(url, authorization: auth, parameters: nil, filterInvalidTokenResult: true) { result in
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
    var selfieData: [String: String]?
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
      "provider": custodian.custodianType.lowercased() as AnyObject,
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
      "provider": custodian.custodianType.lowercased() as AnyObject,
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

  func fetchStatementsPeriod(_ apiKey: String, userToken: String,
                             callback: @escaping Result<MonthlyStatementsPeriod, NSError>.Callback) {
    let url = URLWrapper(baseUrl: transport.environment.baseUrl(), url: .monthlyStatementsPeriod)
    let auth = JSONTransportAuthorization.accessAndUserToken(projectToken: apiKey, userToken: userToken)
    transport.get(url, authorization: auth, parameters: nil, headers: nil, acceptRedirectTo: nil,
                  filterInvalidTokenResult: true) { result in
                    switch result {
                    case .failure(let error):
                      callback(.failure(error))
                    case .success(let json):
                      guard let period = json.monthlyStatementsPeriod else {
                        callback(.failure(ServiceError(code: .jsonError)))
                        return
                      }
                      callback(.success(period))
                    }
    }
  }

  func fetchStatement(_ apiKey: String, userToken: String, month: Int, year: Int,
                      callback: @escaping Result<MonthlyStatementReport, NSError>.Callback) {
    let parameters = [
      "month": String(month) as AnyObject,
      "year": String(year) as AnyObject
    ]
    let url = URLWrapper(baseUrl: transport.environment.baseUrl(), url: .monthlyStatements)
    let auth = JSONTransportAuthorization.accessAndUserToken(projectToken: apiKey, userToken: userToken)
    transport.post(url, authorization: auth, parameters: parameters, filterInvalidTokenResult: true) { result in
      switch result {
      case .failure(let error):
        callback(.failure(error))
      case .success(let json):
        guard let statementReport = json.monthlyStatementReport else {
          callback(.failure(ServiceError(code: .jsonError)))
          return
        }
        callback(.success(statementReport))
      }
    }
  }
}
