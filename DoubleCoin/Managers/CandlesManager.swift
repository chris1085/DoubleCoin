//
//  CandlesManager.swift
//  DoubleCoin
//
//  Created by 姜權芳 on 2023/7/11.
//

import Foundation

class CandlesDataManager {
  static let shared = CandlesDataManager()

  var candlesDay: [CandlesTick] = []
  var candlesWeek: [CandlesTick] = []
  var candlesMonth: [CandlesTick] = []
  var candlesThreeMonth: [CandlesTick] = []
  var candlesYear: [CandlesTick] = []
  var candlesAll: [CandlesTick] = []

  func setCandlesData(timelineType: String, data: [CandlesTick]) {
    switch timelineType {
    case "1D":
      candlesDay = data
    case "1W":
      candlesWeek = data
    case "1M":
      candlesMonth = data
    case "3M":
      candlesThreeMonth = data
    case "1Y":
      candlesYear = data
    case "All":
      candlesAll = data
    default:
      break
    }
  }

  func getCandlesData(timelineType: String) -> [CandlesTick] {
    switch timelineType {
    case "1D":
      return CandlesDataManager.shared.candlesDay
    case "1W":
      return CandlesDataManager.shared.candlesWeek
    case "1M":
      return CandlesDataManager.shared.candlesMonth
    case "3M":
      return CandlesDataManager.shared.candlesThreeMonth
    case "1Y":
      return CandlesDataManager.shared.candlesYear
    case "All":
      return CandlesDataManager.shared.candlesAll
    default:
      return []
    }
  }
}
