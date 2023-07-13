//
//  DoubleCoinEntry.swift
//  DoubleCoinWidgetExtension
//
//  Created by 姜權芳 on 2023/7/12.
//

import Foundation
import WidgetKit

struct DoubleCoinEntry: TimelineEntry {
  let date: Date
  let candlesTicks: [CandlesTick]
  let account: Account
  let productStat: ProductStat
  var amounts: String

  static func mockTravelEntry() -> DoubleCoinEntry {
    var amounts = "168,000,000"
    var widget: [CandlesTick] = []
    var time = 1689206400.0
    let firstOpen = Double.random(in: 0..<30)

    for _ in 0..<24 {
      let low = Double.random(in: 0..<30)
      let high = Double.random(in: low..<30)
      let open = widget.last?.open ?? firstOpen
      let close = Double.random(in: low..<high)

      let candle = CandlesTick(time: time, low: low, high: high, open: open, close: close, volume: 0)
      widget.append(candle)

      time += 3600
    }

    let accountData = Account(id: "", currency: "BTC", balance: "168,000", hold: "", available: "0", profileId: "0", tradingEnabled: true)
    let productStat = ProductStat(open: "20", high: "30", low: "10", last: "25", volume: "168000", volume30Day: "168000")
    return DoubleCoinEntry(date: Date(), candlesTicks: widget, account: accountData, productStat: productStat, amounts: amounts)
  }
}
