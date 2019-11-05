//
//  OauthAttempt.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 04/07/2018.
//
//

public struct OauthAttempt: Equatable {
  public enum Status: String {
    case pending
    case passed
    case failed
  }

  public let id: String
  public let status: OauthAttempt.Status
  public let url: URL?
  public let credentials: OauthCredential?
  public let error: String?
  public let errorMessage: String?
}
