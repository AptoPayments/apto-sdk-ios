//
//  UserTokenCleaner.swift
//  AptoSDK
//
//  Created by Fabio Cuomo on 12/1/21.
//

import Foundation

protocol UserTokenCleanerProtocol {
    func hasTokenStored() -> Bool
    func start()
}

struct UserTokenCleaner: UserTokenCleanerProtocol {
    private let localStorage: UserDefaultsStorageProtocol
    private let keychainStorage: KeychainProtocol
    
    init(localStorage: UserDefaultsStorageProtocol, keychainStorage: KeychainProtocol) {
        self.localStorage = localStorage
        self.keychainStorage = keychainStorage
    }
    
    public func hasTokenStored() -> Bool {
        return keychainStorage.value(for: .tokenKey) != nil
    }
    
    public func start() {
        if localStorage.object(forKey: .firstRunKey) == nil {
            localStorage.set(true, forKey: .firstRunKey)
            keychainStorage.removeValue(for: .tokenKey)
        }
    }
}

public extension String {
  static let firstRunKey = "com.aptopayments.firstRun.key"
}
