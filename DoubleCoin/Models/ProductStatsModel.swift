//
//  ProductStatsModel.swift
//  DoubleCoin
//
//  Created by 姜權芳 on 2023/6/29.
//

import Foundation
import UIKit

// MARK: - Welcome

struct ProductStat: Codable {
  let open, high, low, last: String
  let volume, volume30Day: String?

  enum CodingKeys: String, CodingKey {
    case high, low, last, volume, open
    case volume30Day = "volume_30day"
  }
}

struct ProductTableStat {
  let name: String
  let productStat: ProductStat
}

enum ProductInfo {
  case bitcoin
  case tether
  case bitcoinCash
  case link

  var name: String {
    switch self {
    case .bitcoin:
      return "BTC"
    case .tether:
      return "USDT"
    case .bitcoinCash:
      return "BCH"
    case .link:
      return "LINK"
    }
  }

  var chtName: String {
    switch self {
    case .bitcoin:
      return "比特幣"
    case .tether:
      return "泰達幣"
    case .bitcoinCash:
      return "比特幣現金"
    case .link:
      return "Chainlink"
    }
  }

  var image: UIImage? {
    switch self {
    case .bitcoin:
      return UIImage(named: "btc")
    case .tether:
      return UIImage(named: "usdt")
    case .bitcoinCash:
      return UIImage(named: "bch")
    case .link:
      return UIImage(named: "link")
    }
  }

  static func fromTableStatName(_ name: String) -> ProductInfo? {
    if name == "BTC-USD" {
      return .bitcoin
    } else if name == "USDT-USD" {
      return .tether
    } else if name == "BCH-USD" {
      return .bitcoinCash
    } else if name == "LINK-USD" {
      return .link
    } else {
      return nil
    }
  }
}
