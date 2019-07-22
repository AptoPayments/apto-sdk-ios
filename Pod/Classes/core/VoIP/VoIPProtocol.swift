//
// VoIPProtocol.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 17/06/2019.
//

import Foundation
import SwiftyJSON

public enum VoIPActionSource: String {
  case getPin = "listen_pin"
  case customerSupport = "customer_support"
}

public struct VoIPToken {
  public let accessToken: String
  public let requestToken: String
  public let provider: String
}

public struct VoIPDigits {
  public let digits: String

  public init(digits: String ) {
    self.digits = digits
  }
}

public protocol VoIPCallProtocol: class {
  var isMuted: Bool { get set }
  var isOnHold: Bool { get set }
  var timeElapsed: TimeInterval { get }

  func call(_ destination: VoIPToken, callback: @escaping Result<Void, NSError>.Callback)
  func sendDigits(_ digits: VoIPDigits)
  func disconnect()
}

extension JSON {
  var voIPToken: VoIPToken? {
    guard let accessToken = self["access_token"].string, let requestToken = self["request_token"].string, 
          let provider = self["provider"].string else {
      ErrorLogger.defaultInstance().log(error: ServiceError(code: ServiceError.ErrorCodes.jsonError,
                                                            reason: "Can't parse VoIPToken \(self)"))
      return nil
    }
    return VoIPToken(accessToken: accessToken, requestToken: requestToken, provider: provider)
  }
}
