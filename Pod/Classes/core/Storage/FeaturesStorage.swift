//
// FeaturesStorage.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 14/05/2019.
//

import Foundation

protocol FeaturesStorageProtocol {
  func update(features: [FeatureKey: Bool])
  func isFeatureEnabled(_ featureKey: FeatureKey) -> Bool
}

class FeaturesStorage: FeaturesStorageProtocol {
  private var features: [FeatureKey: Bool] = [:]

  func update(features: [FeatureKey: Bool]) {
    self.features.merge(features, uniquingKeysWith: { $1 })
  }

  func isFeatureEnabled(_ featureKey: FeatureKey) -> Bool {
    return features[featureKey] ?? false
  }
}
