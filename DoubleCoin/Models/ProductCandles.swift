//
//  ProductCandles.swift
//  DoubleCoin
//
//  Created by 姜權芳 on 2023/6/29.
//

import Foundation

typealias CandlesJSON = [Double]

struct CandlesTick: Identifiable {
  var id = UUID()

  let time: Double
  let low: Double
  let high: Double
  let open: Double
  let close: Double
  let volume: Double
}

enum TimelineType: String {
  case day = "1D"
  case week = "1W"
  case month = "1M"
  case season = "3M"
  case year = "1Y"
  case all = "All"

  var tickType: String {
    switch self {
    case .day:
      return "3600"
    case .week:
      return "21600"
    case .month:
      return "86400"
    case .season:
      return "86400"
    case .year:
      return "86400"
    case .all:
      return "86400"
    }
  }

  var tickNumber: Int {
    switch self {
    case .day:
      return 24
    case .week:
      return 168
    case .month:
      return 30
    case .season:
      return 90
    case .year:
      return 365
    case .all:
      return 365
    }
  }
}
