//
//  OauthAttempt.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 04/07/2018.
//
//


public struct OauthAttempt {
  public enum Status: String {
    case pending
    case passed
  }

  public let id: String
  public let status: OauthAttempt.Status
  public let url: URL?
  public let credentials: OauthCredential?
}
