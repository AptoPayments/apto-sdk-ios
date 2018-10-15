//
//  ExternalCredential.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 05/03/2018.
//

import UIKit

public enum ExternalCredential {
  case oauth (OauthCredential)
  case none
}

public class OauthCredential {
  let oauthToken: String
  let refreshToken: String
  let userData: DataPointList?

  init(oauthToken: String, refreshToken: String, userData: DataPointList? = nil) {
    self.oauthToken = oauthToken
    self.refreshToken = refreshToken
    self.userData = userData
  }
}
