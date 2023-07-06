//
//  AccountModel.swift
//  DoubleCoin
//
//  Created by 姜權芳 on 2023/6/28.
//

import Foundation

struct Account: Codable {
  let id: String
  let currency: String
  let balance: String
  let hold: String
  let available: String
  let profileId: String
  let tradingEnabled: Bool

  enum CodingKeys: String, CodingKey {
    case id
    case currency
    case balance
    case hold
    case available
    case profileId = "profile_id"
    case tradingEnabled = "trading_enabled"
  }
}

struct AccountNT {
  let twd: String
  let currency: String
  let balance: String
}
