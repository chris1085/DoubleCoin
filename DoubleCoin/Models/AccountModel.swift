//
//  AccountModel.swift
//  DoubleCoin
//
//  Created by 姜權芳 on 2023/6/28.
//

import Foundation

// MARK: - Account

struct Account: Codable {
  let description: String
  let schema: Schema
}

// MARK: - Schema

struct Schema: Codable {
  let type: String
  let items: Items
}

// MARK: - Items

struct Items: Codable {
  let type: String
  let example: Example
  let properties: Properties
  let itemsRequired: [String]

  enum CodingKeys: String, CodingKey {
    case type, example, properties
    case itemsRequired = "required"
  }
}

// MARK: - Example

struct Example: Codable {
  let id, currency, balance, hold: String
  let available, profileID: String
  let tradingEnabled: Bool

  enum CodingKeys: String, CodingKey {
    case id, currency, balance, hold, available
    case profileID = "profile_id"
    case tradingEnabled = "trading_enabled"
  }
}

// MARK: - Properties

struct Properties: Codable {
  let id, currency, balance, hold: Available
  let available, profileID, tradingEnabled: Available

  enum CodingKeys: String, CodingKey {
    case id, currency, balance, hold, available
    case profileID = "profile_id"
    case tradingEnabled = "trading_enabled"
  }
}
