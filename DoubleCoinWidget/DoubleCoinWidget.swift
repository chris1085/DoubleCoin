//
//  DoubleCoinWidget.swift
//  DoubleCoinWidget
//
//  Created by 姜權芳 on 2023/7/12.
//

import SwiftUI
import WidgetKit

struct Provider: TimelineProvider {
  func placeholder(in context: Context) -> DoubleCoinEntry {
    return DoubleCoinEntry.mockTravelEntry()
  }

  func getSnapshot(in context: Context, completion: @escaping (DoubleCoinEntry) -> ()) {
    ApiManager.shared.getAccounts { accounts in
      // Call ApiManager to get product stats data
      ApiManager.shared.getProductsStats(productId: "BTC-USD") { productStat in
        // Call ApiManager to get product candles data
        let calendar = Calendar.current
        let today = Date()
        let dateFormatter = DateFormatter()
        let startDate = calendar.date(byAdding: .day, value: -1, to: today)!
        let start = dateFormatter.string(from: startDate)
        let end = dateFormatter.string(from: today)
        let account = accounts.filter { $0.currency == "BTC" }.first!

        ApiManager.shared.getProductCandles(productId: "BTC-USD", from: start, to: end, granularity: "3600") { candlesTicks in

          ApiManager.shared.getExchangeDollars(
            dollars: account.currency, dateTime: end, completion: { exchangeRates in
              let accountBalance = Double(account.balance)!

              guard let exchangeRate = exchangeRates?.data.rates["TWD"],
                    let rate = Double(exchangeRate)
              else {
                return
              }

              let amounts = accountBalance * rate
              let amountsText = amounts.formatNumber(amounts, max: 4, min: 4, isAddSep: true)

              let entry = DoubleCoinEntry(date: Date(), candlesTicks: candlesTicks ?? [], account: account, productStat: productStat!, amounts: amountsText!)
              let timeline = Timeline(entries: [entry], policy: .never)
              completion(entry)
            })
//          let entry = DoubleCoinEntry(date: Date(), candlesTicks: candlesTicks ?? [], account: account, productStat: productStat!)
//          completion(entry)
        }
      }
    }
//    completion(entry)
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<DoubleCoinEntry>) -> ()) {
    ApiManager.shared.getAccounts { accounts in
      // Call ApiManager to get product stats data
      ApiManager.shared.getProductsStats(productId: "BTC-USD") { productStat in
        // Call ApiManager to get product candles data
        let calendar = Calendar.current
        let today = Date()
        let startDate = calendar.date(byAdding: .day, value: -1, to: today)!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"
        dateFormatter.timeZone = TimeZone(identifier: "GMT+8")
        let start = dateFormatter.string(from: startDate)
        let end = dateFormatter.string(from: today)
        let account = accounts.filter { $0.currency == "BTC" }.first!

        ApiManager.shared.getProductCandles(productId: "BTC-USD", from: start, to: end, granularity: "3600") { candlesTicks in

          ApiManager.shared.getExchangeDollars(
            dollars: account.currency, dateTime: end, completion: { exchangeRates in
              let accountBalance = Double(account.balance)!

              guard let exchangeRate = exchangeRates?.data.rates["TWD"],
                    let rate = Double(exchangeRate)
              else {
                return
              }

              let amounts = accountBalance * rate
              let amountsText = amounts.formatNumber(amounts, max: 0, min: 0, isAddSep: true)

              let entry = DoubleCoinEntry(date: Date(), candlesTicks: candlesTicks ?? [], account: account, productStat: productStat!, amounts: amountsText!)
              let timeline = Timeline(entries: [entry], policy: .never)
              completion(timeline)
            })
        }
      }
    }
  }
}

struct DoubleCoinWidgetEntryView: View {
  var entry: Provider.Entry

  @Environment(\.widgetFamily) var family

  @ViewBuilder
  var body: some View {
    switch family {
    case .systemSmall:
      DoubleCoinSmallView(candlesTicks: entry.candlesTicks, account: entry.account, productStat: entry.productStat)

    case .systemMedium:
      DoubleCoinMediumView(candlesTicks: entry.candlesTicks, account: entry.account, productStat: entry.productStat, amounts: entry.amounts)

    case .systemLarge:
      DoubleCoinLargeView(candlesTicks: entry.candlesTicks, account: entry.account, productStat: entry.productStat)

    default:
      fatalError()
    }
  }
}

struct DoubleCoinWidget: Widget {
  let kind: String = "DoubleCoinWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: Provider()) { entry in
      DoubleCoinWidgetEntryView(entry: entry)
    }
    .configurationDisplayName("DoubleCoin")
    .description("一手掌握24小時內的趨勢變化")
    .supportedFamilies([.systemSmall, .systemMedium])
  }
}

struct DoubleCoinWidget_Previews: PreviewProvider {
  static var previews: some View {
    DoubleCoinWidgetEntryView(entry: DoubleCoinEntry.mockTravelEntry())
      .previewContext(WidgetPreviewContext(family: .systemMedium))
  }
}
