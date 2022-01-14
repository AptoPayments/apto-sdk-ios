//
// FeaturesStorage.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 14/05/2019.
//

import Foundation

protocol FeaturesStorageProtocol {
    var currentPCIAuthType: PCIAuthType { get }
    func update(features: [FeatureKey: Bool])
    func isFeatureEnabled(_ featureKey: FeatureKey) -> Bool
    func isAuthenticationTypeEquals(to type: PCIAuthType) -> Bool
    func updateAuthenticationType(_ type: PCIAuthType)
}

class FeaturesStorage: FeaturesStorageProtocol {
    private var features: [FeatureKey: Bool] = [:]
    private var authenticateOnPCI: PCIAuthType = .none
    public var currentPCIAuthType: PCIAuthType {
        authenticateOnPCI
    }

    func update(features: [FeatureKey: Bool]) {
        self.features.merge(features) { $1 }
    }

    func isFeatureEnabled(_ featureKey: FeatureKey) -> Bool {
        return features[featureKey] ?? false
    }

    func isAuthenticationTypeEquals(to type: PCIAuthType) -> Bool {
        authenticateOnPCI == type
    }

    func updateAuthenticationType(_ type: PCIAuthType) {
        authenticateOnPCI = type
    }
}
