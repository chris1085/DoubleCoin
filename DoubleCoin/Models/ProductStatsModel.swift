//
//  ProductStatsModel.swift
//  DoubleCoin
//
//  Created by 姜權芳 on 2023/6/29.
//

import Foundation

// MARK: - Welcome

struct ProductStat: Codable {
  let open, high, low, last: String
  let volume, volume30Day: String

  enum CodingKeys: String, CodingKey {
    case high, low, last, volume, open
    case volume30Day = "volume_30day"
  }
}
