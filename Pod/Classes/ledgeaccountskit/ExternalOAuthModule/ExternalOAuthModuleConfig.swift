//
//  ExternalOAuthModuleConfig.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 23/06/2018.
//

import UIKit

struct ExternalOAuthModuleConfig {
  let title: String
  let imageName: String? = "coinbase_logo"
  let provider: String = "external-oauth.coinbase.connect".podLocalized()
  let accessDescription: String = "external-oauth.coinbase.access".podLocalized()
  let callToActionTitle: String = "external-oauth.coinbase.action".podLocalized()
  let description: String = "external-oauth.coinbase.description".podLocalized()
}
