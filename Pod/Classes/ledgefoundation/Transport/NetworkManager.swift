//
//  NetworkManager.swift
//  Pods
//
//  Created by Takeichi Kanzaki on 06/07/2018.
//
//

import Alamofire
import SwiftyJSON
import TrustKit

struct NetworkRequest {
  let url: URLConvertible
  let method: HTTPMethod
  let parameters: [String: Any]?
  let headers: [String: String]
  let filterInvalidTokenResult: Bool
  let callback: Result<JSON, NSError>.Callback
}

protocol NetworkManagerProtocol {
  var delegate: SessionDelegate { get }

  func request(_ networkRequest: NetworkRequest)
  func runPendingRequests()
}

final class NetworkManager: NetworkManagerProtocol {
  private let manager: SessionManager
  private let reachabilityManager: NetworkReachabilityManager?
  private var configuration: URLSessionConfiguration = {
    let configuration = URLSessionConfiguration.default
    configuration.timeoutIntervalForRequest = 180 // seconds
    configuration.timeoutIntervalForResource = 180

    return configuration
  }()

  private var pendingRequests = [NetworkRequest]()

  private static var certPinningConfig: [String: [String: AnyObject]] = [:]
  private static let setupCertPinningConfig: Void = {
    TrustKit.initSharedInstance(withConfiguration: [kTSKPinnedDomains: NetworkManager.certPinningConfig])
    return ()
  }()

  var delegate: SessionDelegate {
    return manager.delegate
  }

  init(baseURL: URL? = nil,
       certPinningConfig: [String: [String: AnyObject]]? = nil,
       allowSelfSignedCertificate: Bool = false) {
    if let baseURL = baseURL, allowSelfSignedCertificate {
      let serverTrustPolicies: [String: ServerTrustPolicy] = [
        "\(baseURL.host!)": .disableEvaluation
      ]
      let serverTrustPolicyManager = ServerTrustPolicyManager(policies: serverTrustPolicies)
      self.manager = SessionManager(
        configuration: self.configuration,
        serverTrustPolicyManager: serverTrustPolicyManager)
      self.reachabilityManager = NetworkReachabilityManager(host: baseURL.absoluteString)
    }
    else {
      self.manager = SessionManager(configuration: configuration)
      self.reachabilityManager = NetworkReachabilityManager()
    }
    self.reachabilityManager?.listener = self.networkStatusChanged
    self.reachabilityManager?.startListening()
    if let certPinningConfig = certPinningConfig {
      self.setupCertificatePinning(certPinningConfig)
    }
  }

  func request(_ request: NetworkRequest) {
    manager.request(request.url,
                    method: request.method,
                    parameters: request.parameters,
                    encoding: JSONEncoding.default,
                    headers: completeHeaders(request.headers))
      .responseJSON { [unowned self] response in
        let processedResponse = self.processResponse(response).map { json -> JSON in JSON(json) }
        switch processedResponse {
        case .failure(_):
          self.processErrorResponse(processedResponse, request: request)
        case .success(_):
          request.callback(processedResponse)
        }
      }
  }

  func runPendingRequests() {
    let requests = pendingRequests
    pendingRequests.removeAll()
    for r in requests {
      request(r)
    }
  }

  private func setupCertificatePinning(_ certPinningConfig: [String: [String: AnyObject]]) {
    NetworkManager.certPinningConfig = certPinningConfig
    _ = NetworkManager.setupCertPinningConfig
  }

  private func completeHeaders(_ headers: [String: String]) -> [String: String] {
    var retVal = headers
    retVal["X-Api-Version"] = "1.0"
    retVal["X-SDK-Version"] = ShiftSDK.version
    retVal["X-Device"] = "iOS"
    retVal["X-Device-Version"] = "\(UIDevice.current.platform) - \(UIDevice.current.systemVersion)"
    return retVal
  }

  private func processResponse(_ response: DataResponse<Any>) -> Result<AnyObject, NSError> {
    if let originalError = response.error {
      ErrorLogger.defaultInstance().log(error: originalError)
    }

    if case .some(500..<600) = response.response?.statusCode {
      let error = BackendError(code: .serviceUnavailable, reason: response.error?.localizedDescription)
      return .failure(error)
    }

    if response.response?.statusCode == 401 {
      let json = JSON(response.value ?? "")
      let error = json.backendError ?? BackendError(code: .invalidSession)
      if error.invalidSessionError() {
        NotificationCenter.default.post(Notification(name: .UserTokenSessionInvalidNotification,
                                                     object: nil,
                                                     userInfo: ["error": error]))
      }
      else if error.sessionExpiredError() {
        NotificationCenter.default.post(Notification(name: .UserTokenSessionExpiredNotification,
                                                     object: nil,
                                                     userInfo: ["error": error]))
      }
      ErrorLogger.defaultInstance().log(error: error)
      return .failure(error)
    }

    if case .some(400..<500) = response.response?.statusCode {
      let json = JSON(response.value ?? "")
      let error = json.backendError ?? BackendError(code: .incorrectParameters)
      return .failure(error)
    }

    if response.result.error != nil {
      debugPrint(response)
    }

    switch response.result {
    case .success(let value):
      return .success(value as AnyObject)
    case .failure(let error):
      return .failure(error as NSError)
    }
  }

  private func processErrorResponse(_ response: Result<JSON, NSError>, request: NetworkRequest) {
    if response.isNetworkNotReachableError() {
      self.pendingRequests.append(request)
      NotificationCenter.default.post(Notification(name: .NetworkNotReachableNotification))
    }
    else if response.isServerMaintenanceError() {
      self.pendingRequests.append(request)
      NotificationCenter.default.post(Notification(name: .ServerMaintenanceNotification))
    }
    else if response.isSessionExpiredError() {
      if !request.filterInvalidTokenResult {
        request.callback(response)
      }
    }
    else if response.isSDKDeprecatedError() {
      NotificationCenter.default.post(Notification(name: .SDKDeprecatedNotification))
    }
    else {
      request.callback(response)
    }
  }
}

// Handle reachability changes
extension NetworkManager {
  private func networkStatusChanged(_ status: NetworkReachabilityManager.NetworkReachabilityStatus) {
    switch status {
    case .reachable(_):
      NotificationCenter.default.post(Notification(name: .NetworkReachableNotification))
      runPendingRequests()
    default:
      break
    }
  }
}

extension Result {
  func isSessionExpiredError() -> Bool {
    switch self {
    case .failure(let error):
      if let backendError = error as? BackendError {
        return backendError.sessionExpiredError()
      }
      return false
    default:
      return false
    }
  }

  func isServerMaintenanceError() -> Bool {
    switch self {
    case .failure(let error):
      return ((error as NSError).code == BackendError.ErrorCodes.serverMaintenance.rawValue)
    default:
      return false
    }
  }

  func isNetworkNotReachableError() -> Bool {
    switch self {
    case .failure(let error):
      return ((error as NSError).code == BackendError.ErrorCodes.networkNotAvailable.rawValue)
    default:
      return false
    }
  }

  func isSDKDeprecatedError() -> Bool {
    switch self {
    case .failure(let error):
      if let backendError = error as? BackendError {
        return backendError.sdkDeprecated()
      }
      return false
    default:
      return false
    }
  }
}

extension Notification.Name {
  static let NetworkReachableNotification = Notification.Name("NetworkReachableNotification")
  static let NetworkNotReachableNotification = Notification.Name("NetworkNotReachableNotification")
  static let ServerMaintenanceNotification = Notification.Name("ServerMaintenanceNotification")
  static let SDKDeprecatedNotification = Notification.Name("SDKDeprecatedNotification")
}
