//
//  ExchangeRateModel.swift
//  DoubleCoin
//
//  Created by 姜權芳 on 2023/7/6.
//

import Foundation

// MARK: - ExchangeRate

struct ExchangeRate: Codable {
  let data: DataClass
}

// MARK: - DataClass

struct DataClass: Codable {
  let currency: String
  let rates: [String: String]
}
