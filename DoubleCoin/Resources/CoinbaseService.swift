//
//  CoinbaseService.swift
//  DoubleCoin
//
//  Created by 姜權芳 on 2023/6/28.
//

import CryptoKit
import Foundation

class CoinbaseService {
  static let shared = CoinbaseService()
  let secret = apiSecret
  let api = apiKey
  let passphrase = apiPpassphrase

  func getTimestampSignature(requestPath: String,
                             method: String,
                             body: String) -> (String, String)
  {
    let date = Date().timeIntervalSince1970
    let cbAccessTimestamp = String(date)
    let secret = secret
    let requestPath = requestPath
    let body = body
    let method = method
    let message = "\(cbAccessTimestamp)\(method)\(requestPath)\(body)"
    
    print(message)

    guard let keyData = Data(base64Encoded: secret) else {
      fatalError("Failed to decode secret as base64")
    }

    let hmac = HMAC<SHA256>.authenticationCode(for: Data(message.utf8), using: SymmetricKey(data: keyData))

    let cbAccessSign = hmac.withUnsafeBytes { macBytes -> String in
      let data = Data(macBytes)
      return data.base64EncodedString()
    }

    return (cbAccessSign, cbAccessTimestamp)
  }

  func createHeaders(requestPath: String, body: String, method: String) -> [String: String] {
    let apiKey = CoinbaseService.shared.api
    let passphrase = CoinbaseService.shared.passphrase
    let timestampSignature = CoinbaseService.shared.getTimestampSignature(requestPath: requestPath,
                                                                          method: method,
                                                                          body: body)

    return [
      "cb-access-key": apiKey,
      "cb-access-passphrase": passphrase,
      "cb-access-sign": timestampSignature.0,
      "cb-access-timestamp": timestampSignature.1
    ]
  }
}
