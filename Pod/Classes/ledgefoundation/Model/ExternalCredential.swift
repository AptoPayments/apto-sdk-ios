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
  init(oauthToken: String, refreshToken: String) {
    self.oauthToken = oauthToken
    self.refreshToken = refreshToken
  }
}
