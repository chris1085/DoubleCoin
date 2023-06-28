//
//  Keychain.swift
//  DoubleCoin
//
//  Created by 姜權芳 on 2023/6/28.
//

import Foundation
import Security

class KeychainManager {
  static let shared = KeychainManager()

  private let service = "com.DoubleC.DoubleCoin"
  private let tokenKey = "authToken"

  func saveToken(_ token: String) -> Bool {
    guard let data = token.data(using: .utf8) else {
      return false
    }

    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: service,
      kSecAttrAccount as String: tokenKey,
      kSecValueData as String: data
    ]

    SecItemDelete(query as CFDictionary)

    let status = SecItemAdd(query as CFDictionary, nil)
    return status == errSecSuccess
  }

  func loadToken() -> String? {
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: service,
      kSecAttrAccount as String: tokenKey,
      kSecMatchLimit as String: kSecMatchLimitOne,
      kSecReturnData as String: true
    ]

    var result: AnyObject?
    let status = SecItemCopyMatching(query as CFDictionary, &result)

    if status == errSecSuccess, let data = result as? Data {
      return String(data: data, encoding: .utf8)
    }

    return nil
  }

  func deleteToken() -> Bool {
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: service,
      kSecAttrAccount as String: tokenKey
    ]

    let status = SecItemDelete(query as CFDictionary)
    return status == errSecSuccess
  }
}
