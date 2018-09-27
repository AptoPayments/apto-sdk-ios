//
//  OauthAttempt.swift
//  Pods
//
//  Created by Takeichi Kanzaki on 04/07/2018.
//
//


struct OauthAttempt {
  enum Status: String {
    case pending
    case passed
  }

  let id: String
  let status: OauthAttempt.Status
  let url: URL?
  let credentials: OauthCredential?
}
