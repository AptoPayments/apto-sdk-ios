//
//  Keychain.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 24/03/2020.
//

import Foundation

protocol KeychainProtocol {
    @discardableResult
    func save(value: Data?, for key: String) -> Bool
    func value(for key: String) -> Data?
    @discardableResult
    func removeValue(for key: String) -> Bool
}

class KeychainOS: KeychainProtocol {
    func save(value: Data?, for key: String) -> Bool {
        var query = buildBasicQuery(for: key)
        // If a value for the given key exists then update it, add new value otherwise.
        if SecItemCopyMatching(query as CFDictionary, nil) == errSecSuccess {
            return SecItemUpdate(query as CFDictionary, [kSecValueData: value] as CFDictionary) == errSecSuccess
        } else {
            query[kSecValueData as String] = value
            return SecItemAdd(query as CFDictionary, nil) == errSecSuccess
        }
    }

    // swiftlint:disable trailing_closure
    func value(for key: String) -> Data? {
        let extras = [
            kSecMatchLimit: kSecMatchLimitOne,
            kSecReturnAttributes: true,
            kSecReturnData: true,
        ] as [String: Any]
        let query = buildBasicQuery(for: key).merging(extras, uniquingKeysWith: { $1 })
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess else { return nil }
        guard let existingItem = item as? [String: Any] else { return nil }
        return existingItem[kSecValueData as String] as? Data
    }

    // swiftlint:enable trailing_closure

    func removeValue(for key: String) -> Bool {
        let query = buildBasicQuery(for: key)
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }

    private func buildBasicQuery(for key: String) -> [String: Any] {
        return [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: key,
            kSecAttrAccessible: kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
        ] as [String: Any]
    }
}
