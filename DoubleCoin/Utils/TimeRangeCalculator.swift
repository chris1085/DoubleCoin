//
//  TimeRangeCalculator.swift
//  DoubleCoin
//
//  Created by 姜權芳 on 2023/7/3.
//

import Foundation

class TimeRangeCalculator {
//  static func fetchMoreCandlesTicks(timelineType: TimelineType, tickType: String, start: String, end: String) {
//    // 實作 fetchMoreCandlesTicks 的邏輯
//    // ...
//  }
//
//  static func calculateStart(from start: String, endIndex: Int, totalTicks: Int, batchSize: Int) -> String {
//    // 實作 calculateStart 的邏輯
//    // ...
//  }
//
//  static func calculateEnd(from end: String, endIndex: Int, totalTicks: Int, batchSize: Int) -> String {
//    // 實作 calculateEnd 的邏輯
//    // ...
//  }
}

enum CandlesTicksHelper {
  static func fetchMoreCandlesTicks(productId: String, timelineType: TimelineType, tickType: String, start: String, end: String, completion: @escaping ([Candlestick]?) -> Void) {
    let batchSize = 300
    let totalTicks = timelineType.tickNumber
    var startIndex = totalTicks - batchSize

    var allCandlesTicks: [Candlestick] = []

    while startIndex >= 0 {
      let calculatedStart = calculateStart(from: start, endIndex: startIndex, totalTicks: totalTicks, batchSize: batchSize)
      let calculatedEnd = calculateEnd(from: end, endIndex: startIndex, totalTicks: totalTicks, batchSize: batchSize)

      ApiManager.shared.getProductCandles(productId: productId, from: calculatedStart, to: calculatedEnd, granularity: tickType) { candlesTicks in
        guard let candlesTicks = candlesTicks else { return }
        allCandlesTicks.append(contentsOf: candlesTicks)
        if allCandlesTicks.count >= totalTicks {
          completion(allCandlesTicks)
        }
      }
      startIndex -= batchSize
    }
  }

  static func calculateStart(from start: String, endIndex: Int, totalTicks: Int, batchSize: Int) -> String {
    let remainingTicks = endIndex + 1
    let ticksToFetch = min(batchSize, remainingTicks)
    let startOffset = totalTicks - remainingTicks

    guard let startDate = DateUtils.date(from: start, format: "yyyy-MM-dd") else { return start }
    let calculatedStartDate = Calendar.current.date(byAdding: .day, value: startOffset - ticksToFetch + 1, to: startDate)

    return DateUtils.string(from: calculatedStartDate, format: "yyyy-MM-dd") ?? start
  }

  static func calculateEnd(from end: String, endIndex: Int, totalTicks: Int, batchSize: Int) -> String {
    let remainingTicks = endIndex + 1
    let startOffset = totalTicks - remainingTicks

    guard let endDate = DateUtils.date(from: end, format: "yyyy-MM-dd") else { return end }
    let calculatedEndDate = Calendar.current.date(byAdding: .day, value: startOffset, to: endDate)

    return DateUtils.string(from: calculatedEndDate, format: "yyyy-MM-dd") ?? end
  }
}

enum DateUtils {
  static func date(from string: String, format: String) -> Date? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = format
    return dateFormatter.date(from: string)
  }

  static func string(from date: Date?, format: String) -> String? {
    guard let date = date else { return nil }

    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = format
    return dateFormatter.string(from: date)
  }
}
